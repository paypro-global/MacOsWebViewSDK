//
//  AppDelegate.swift
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 11/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

import Foundation
import WebKit

public typealias View = NSView
public typealias ErrorCallback = (Error) -> ()
public typealias URLCredentialCallback = (URLCredential?)->()


@objc
public protocol PayProGlobal {
    var url : URL? { get }
    var paymentView : View { get }
    func reload()
    var didFail: ErrorCallback? { get set }
    var didStartPaymentViewLoad:(()->())?{ get set}
    var didFinishPaymentViewLoad:(()->())?{ get set}
    var didCompletedOrder:((Dictionary<String, Any>?)->())? { get set }
    var urlCredential:((@escaping URLCredentialCallback)->())? { get set}
}

@objc
public class Configuration : NSObject {
    let url:String // Construct the URL as mentioned in https://payproglobal.com/knowledge-base/developer-tools/url-parameters/
    
    @objc
    public init(url:String) {
        self.url = url
    }
}

@objc
public class PPGAppKit : NSObject {
    private override init() {
        
    }
    
    @objc
    public static func create(configuration:Configuration)-> PayProGlobal {
        return PayProWebView.init(configuration: configuration)
    }
}


