//
//  PayProWebView.swift
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 11/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

import Foundation
import WebKit
import PDFKit

public enum PayProError : Error {
    case invoiceDownload(underlying:NSError?)
}

internal class PayProWebView : NSObject{

    private let configuration:Configuration
    private var invoiceDownloadInProgress = false {
        didSet {
            refreshProgress()
        }
    }
    
//    private var invoiceHeaders:Dictionary<String,Any>?
    
    lazy private var webView: WKWebView = {
          
        let configuration : WKWebViewConfiguration = {
            let configuration = WKWebViewConfiguration()
            let script = WKUserScript(source: "window.print = function() { window.webkit.messageHandlers.print.postMessage('print') }", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
            configuration.userContentController.addUserScript(script)
            configuration.userContentController.add(self, name: "print")

            return configuration
        }()
        
        let defaultWebViewFrame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let webView = WKWebView(frame: defaultWebViewFrame, configuration: configuration)
        webView.addSubview(progressView)

        let progressFrame:CGRect = {
            let progressViewSize = CGSize(width: 32, height: 32)
            let x = (webView.bounds.width - progressViewSize.width) * 0.5
            let y = (webView.bounds.height - progressViewSize.height) * 0.5
            let rect = CGRect(x: x, y: y, width: progressViewSize.width, height: progressViewSize.height)
            return rect
        }()
    
        progressView.frame = progressFrame
        progressView.isDisplayedWhenStopped = false

        return webView
    }()
    
    lazy private var progressView:NSProgressIndicator = {
        let progressView = NSProgressIndicator()
        progressView.style = .spinning
        progressView.controlSize = .regular
        progressView.autoresizingMask = [.minYMargin,.minXMargin,.maxXMargin,.maxYMargin]
        return progressView
    }()
    
    var pdfView:PDFView?

    var didFail: ErrorCallback?
    
    var didStartPaymentViewLoad:(()->())?
    
    var didFinishPaymentViewLoad:(()->())?
    
    var didCompletedOrder:((Dictionary<String, Any>?)->())?
   
    var urlCredential: ((@escaping URLCredentialCallback) -> ())?
    
    private var authenticationChallenge:((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)?

    init(configuration:Configuration) {
        self.configuration = configuration
        super.init()
        load()
    }
    
    private func load(){
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: configuration.url)!))
        refreshProgress()
    }
    
    private func refreshProgress(){
        if webView.isLoading || invoiceDownloadInProgress == true {
            progressView.startAnimation(self)
            return
        }
        progressView.stopAnimation(self)
    }

}

extension PayProWebView {
    static internal let javaScriptCommands = JavaScriptCommands();
    static internal let pathParameter = PathParameter();
    static internal let payProPath = PayProPath();

    internal struct JavaScriptCommands {
        let print = "print"
    }
    
    internal struct PathParameter {
        let download = "DownloadPdf=true"
    }

    internal struct PayProPath{
        let invoice = "/Invoice";
    }
}

extension PayProWebView : WKScriptMessageHandler {
   
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "print", let validURL = webView.url{
            let url = validURL.URLbyAppending(parameter: PayProWebView.pathParameter.download)
            
            download(invoice: url,didFinish: { [weak self] (path) in
                self?.printDocument(at: path)
           })
        }
    }
    
    private func printDocument(at path:String){
        let document  =  PDFDocument(url: URL(fileURLWithPath: path));
        pdfView = PDFView()
        pdfView?.document = document
        webView.addSubview(pdfView!)
        pdfView?.print(with: NSPrintInfo.shared, autoRotate: false)
    }
}

extension PayProWebView  : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error){
        didFail?(error)
        refreshProgress()
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void){
        handleAuthentication(with: completionHandler,challenge:challenge)
    }
    
    private func handleAuthentication(with handler:@escaping(URLSession.AuthChallengeDisposition, URLCredential?)->Void,challenge:URLAuthenticationChallenge){
        switch challenge.protectionSpace.authenticationMethod {
            case NSURLAuthenticationMethodDefault,NSURLAuthenticationMethodHTTPDigest,NSURLAuthenticationMethodHTTPBasic:
                authenticationChallenge = handler
                urlCredential?(credential)
            default:
                handler(.performDefaultHandling,nil)
        }
    }
    
    private func credential(credential:URLCredential?) {
        defer {
            authenticationChallenge = nil
        }
        
        guard let validCredential = credential else {
            authenticationChallenge?(.cancelAuthenticationChallenge,nil)
            return
        }
        
        authenticationChallenge?(.useCredential,validCredential)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        didFail?(error)
        refreshProgress()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStartPaymentViewLoad?()
        refreshProgress()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        didFinishPaymentViewLoad?()
        refreshProgress()
    }
    
    private func processHeaders(for navigationAction:WKNavigationAction){
        if let validURL = navigationAction.request.url, validURL.path.contains(PayProWebView.payProPath.invoice) /*, invoiceHeaders == nil*/ {
            didCompletedOrder?(navigationAction.request.allHTTPHeaderFields)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let validURL = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
             
        processHeaders(for: navigationAction);
        
        if validURL.absoluteString.contains(PayProWebView.pathParameter.download)  {
            decisionHandler(.cancel)
            download(invoice: validURL,didFinish: { (path) in
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
            })
            return
        }
        
        decisionHandler(.allow)

    }
    
    private func download(invoice:URL,didFinish:@escaping(String)->()){
        guard  invoiceDownloadInProgress == false else { return }
        
        invoiceDownloadInProgress = true
        fileDownload(at:invoice, destinationFileName:"Invoice.pdf") { [weak self] (path, error) in
            defer {
                self?.invoiceDownloadInProgress = false
            }
            
            if let validError = error  {
                self?.didFail?(validError)
                return
            }
            
            guard let validPath = path else {
                self?.didFail?(PayProError.invoiceDownload(underlying: nil))
                return
            }
            
            didFinish(validPath)
        }
    }

}

extension PayProWebView : PayProGlobal {
    var url: URL? {
        webView.url
    }
    
    var paymentView: View {
        webView
    }
    
    func reload() {
        load()
//        invoiceHeaders = nil
    }
}


extension URL {
    func URLbyAppending(parameter:String) -> URL {
        var urlString = absoluteString

        urlString.append(contentsOf: "&")
        urlString.append(contentsOf: parameter)
        let appendedURL = URL(string: urlString )!
        return appendedURL
    }
}
