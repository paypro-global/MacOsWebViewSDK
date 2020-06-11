//
//  ViewController.m
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 11/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

#import "ViewController.h"

@import PPGAppKit;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self load];
}

- (void)load {
    Configuration *configuration = [[Configuration alloc] initWithUrl:@"https://store.payproglobal.com/checkout?products[1][id]=59421&use-test-mode=true&secret-key=gEcP!-xp9M"];
    self.payproGlobal = [PPGAppKit createWithConfiguration:configuration];
    
    self.payproGlobal.didStartPaymentViewLoad = ^(){
        NSLog(@"Did start");
    };
    
    self.payproGlobal.didFinishPaymentViewLoad = ^(){
        NSLog(@"Did Finish");
    };
    
    self.payproGlobal.didFail = ^(NSError * error) {
        NSLog(@"Did Fail");
    };
    
    NSView *paymentView = [self.payproGlobal paymentView];
    [paymentView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.container addSubview:paymentView];
    [self.container addConstraints:[self paymentViewConstraints]];
}

- (NSArray*)paymentViewConstraints{
    NSMutableArray *constraints =  [NSMutableArray array];
    NSView *paymentView = [self.payproGlobal paymentView];

    [constraints addObject:[NSLayoutConstraint constraintWithItem:paymentView
                                                        attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.container attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:paymentView
                                                           attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.container attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:paymentView
                                                           attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.container attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:paymentView
                                                           attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.container attribute:NSLayoutAttributeRight multiplier:1.0f constant:0]];
    return constraints;
}


@end
