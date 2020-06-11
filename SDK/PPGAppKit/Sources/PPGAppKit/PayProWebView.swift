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
    
    lazy private var webView: WKWebView = WKWebView()
    
    var didFail: ErrorCallback?
    
    var didStartPaymentViewLoad:(()->())?
    
    var didFinishPaymentViewLoad:(()->())?

    init(configuration:Configuration) {
        self.configuration = configuration
        super.init()
        load()
    }
    
    private func load(){
        webView.navigationDelegate = self
        webView.load(URLRequest(url: URL(string: configuration.url)!))
    }

}

extension PayProWebView  : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation \(error)")
        didFail?(error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didErrror \(error)")
        didFail?(error)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStartPaymentViewLoad?()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        didFinishPaymentViewLoad?()
    }
}

extension PayProWebView : PayProGlobal {
    var paymentView: View {
        webView
    }
    
    func reload() {
        load()
    }
}
