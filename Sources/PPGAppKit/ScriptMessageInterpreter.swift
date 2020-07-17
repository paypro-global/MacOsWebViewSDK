//
//  ScriptMessageInterpreter.swift
//  PPGAppKit
//
//  Created by Srinivas Prabhu G on 17/07/20.
//

import Foundation
import WebKit

internal struct ScriptMessageInterpreter {
    
    var orderCompleted:((Dictionary<String,Any>)->())
    private var orderCompleteHeaders:Dictionary<String,Any>? = nil
    var initiatePrint:(URL)->()
    
    init(orderCompleted:@escaping((Dictionary<String,Any>)->()),initiatePrint:@escaping(URL)->()) {
        self.orderCompleted = orderCompleted
        self.initiatePrint = initiatePrint
    }
    
    mutating func interpret(message:WKScriptMessage){
        switch message.name {
            case UserScriptFactory.ScriptName.orderCompleted.rawValue:
                notifyOrderCompleted(headers: message.body as? String)
            case UserScriptFactory.ScriptName.print.rawValue:
                notifyPrint()
            default:
            print("unknown")
        }
    }
    
    private mutating func notifyOrderCompleted(headers:String?){
        guard let validHeaders = headers else { return }
        let headersArray = validHeaders.components(separatedBy: "\r\n")
        var headersMap:Dictionary<String,Any> = [:]
        
        headersArray.forEach { (header) in
            let parts = String(header).components(separatedBy: ": ")
            if let key = parts.first, let value = parts.last, key != "" {
                headersMap[key] = value
            }
        }

        let ppgHeaders = headersMap.filter { (key, _) -> Bool in
            return key.starts(with: "ppg")
        }
        guard ppgHeaders.count > 0 else { return }
        
        self.orderCompleteHeaders = ppgHeaders
        orderCompleted(ppgHeaders)
    }
    
    private func notifyPrint(){
        guard let validPrintURLString = orderCompleteHeaders?["ppg-invoice-url"] as? String , let printURL = URL(string: validPrintURLString) else { return  }
        initiatePrint(printURL.URLbyAppending(parameter: PayProWebView.pathParameter.download))
    }
    
}
