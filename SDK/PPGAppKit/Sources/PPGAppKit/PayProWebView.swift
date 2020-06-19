//
//  File.swift
//  
//
//  Created by Srinivas Prabhu G on 11/06/20.
//

import Foundation
import WebKit

internal class PayProWebView : NSObject{
    
    private let configuration:Configuration
    
    lazy private var webView: WKWebView = {
        let webView = WKWebView()
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
    
    var didFail: ErrorCallback?
    
    var didStartPaymentViewLoad:(()->())?
    
    var didFinishPaymentViewLoad:(()->())?
   
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
        if webView.isLoading {
            progressView.startAnimation(self)
            return
        }
        progressView.stopAnimation(self)
    }

}

extension PayProWebView  : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation \(error)")
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
    }
}
