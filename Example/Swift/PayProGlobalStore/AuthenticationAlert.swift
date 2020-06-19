//
//  AuthenticationAlert.swift
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 19/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

import Cocoa

@objc
class Credential : NSObject {
    @objc
    public let username:String
    @objc
    public let password:String
    init(username:String,password:String) {
        self.username = username
        self.password = password
    }
}

class AuthenticationAlert: NSWindowController {
    @IBOutlet weak var username: NSTextField!
    @IBOutlet weak var password: NSSecureTextField!
    @IBOutlet weak var url: NSTextField!
   
    @objc
    public var didSignin : ((Credential) -> ())?
    @objc
    public var didCancel : (()->())?
    
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
