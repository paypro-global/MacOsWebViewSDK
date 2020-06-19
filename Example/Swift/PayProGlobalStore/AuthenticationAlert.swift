//
//  AuthenticationAlert.swift
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 19/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

import Cocoa

struct Credential {
    let username:String
    let password:String
}

class AuthenticationAlert: NSWindowController {
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet weak var url: NSTextField!
    
    var didSignin : ((Credential) -> ())?
    var didCancel : (()->())?
    
    override func windowDidLoad() {
        print("did load")
    }
    
    override var windowNibName: NSNib.Name? {
        return "AuthenticationAlert"
    }
    
    @IBAction func signin(_ sender: Any) {
        didSignin?(Credential(username: username.stringValue, password: password.stringValue))
    }
    
    @IBAction func cancel(_ sender: Any) {
        didCancel?()
    }

}
