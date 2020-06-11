//
//  ViewController.swift
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 11/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

import Cocoa
import PPGAppKit

class ViewController: NSViewController {

    @IBOutlet weak var container: NSView!
    
    lazy var payproGlobal: PayProGlobal = {
        return PPGAppKit.create(configuration: Configuration(url: "https://store.payproglobal.com/checkout?products[1][id]=59421&use-test-mode=true&secret-key=gEcP!-xp9M"))
    }()
    
    private var paymentViewConstraints:[NSLayoutConstraint]  {
        let topConstraint = NSLayoutConstraint(item: payproGlobal.paymentView, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: payproGlobal.paymentView, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: payproGlobal.paymentView, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: payproGlobal.paymentView, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: 0)
        
        return [topConstraint,bottomConstraint,leadingConstraint,trailingConstraint]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
    }
    
    private func load(){
        let paymentView = payproGlobal.paymentView

        payproGlobal.didFail = { (error) in
            print("Did Fail \(error)")
        }
        
        payproGlobal.didStartPaymentViewLoad = {
            print("didStartPaymentViewLoad ")
        }
        
        payproGlobal.didFinishPaymentViewLoad = {
            print("didFinishPaymentViewLoad ")
        }
        
        paymentView.translatesAutoresizingMaskIntoConstraints = false
        container.addConstraints(paymentViewConstraints)
        container.addSubview(paymentView)
    }

    @IBAction func reload(_ sender: Any) {
        payproGlobal.reload()
    }
    
}

