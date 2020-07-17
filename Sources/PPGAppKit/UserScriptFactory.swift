//
//  UserScriptFactory.swift
//  PPGAppKit
//
//  Created by Srinivas Prabhu G on 17/07/20.
//

import Foundation
import WebKit

internal struct UserScriptFactory {
    private init(){
        
    }
    
    enum ScriptName: String {
        case print
        case orderCompleted
    }

    static var orderCompleted : WKUserScript = {
        
        let script = """
        $( document ).ajaxSuccess(function( event, response, settings )  {
            var headers = response.getAllResponseHeaders();
            callNativeApp (headers);
        });

        function callNativeApp (data) {
            try {
                webkit.messageHandlers.orderCompleted.postMessage(data);
            }
            catch(err) {
                console.log('The native context does not exist yet');
            }
        }
        """
        
        return WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
    }()
    
    static var print : WKUserScript = {
        let script = "window.print = function() { window.webkit.messageHandlers.print.postMessage('print') }"
        
        return WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
    }()
}


