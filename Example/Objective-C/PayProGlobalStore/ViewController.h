//
//  ViewController.h
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 11/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import PPGAppKit;

@interface ViewController : NSViewController

@property (strong) id<PayProGlobal> payproGlobal;
@property (weak) IBOutlet NSView *container;

@end

