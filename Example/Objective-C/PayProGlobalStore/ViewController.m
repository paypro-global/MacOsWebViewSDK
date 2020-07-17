//
//  ViewController.m
//  PayProGlobalStore
//
//  Created by Srinivas Prabhu G on 11/06/20.
//  Copyright © 2020 PayPro Global Inc. All rights reserved.
//

#import "ViewController.h"
#import "PayProGlobalStore-Swift.h"
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
    
    self.payproGlobal.didFail  = ^(NSError * error) {
        NSLog(@"Did Fail");
    };
    
    self.payproGlobal.didCompletedOrder = ^(NSDictionary<NSString *,id> * orderInfo) {
        NSLog(@"did Complete Order %@",orderInfo);
    };
    
    __weak ViewController *weakSelf = self;

    self.payproGlobal.urlCredential = ^(void (^ callback)(NSURLCredential * _Nullable)) {
        [weakSelf showAlert:callback];
    };
    
    NSView *paymentView = [self.payproGlobal paymentView];
    [paymentView setTranslatesAutoresizingMaskIntoConstraints:false];
    [self.container addSubview:paymentView];
    [self.container addConstraints:[self paymentViewConstraints]];
}

- (void)showAlert:(void (^ )(NSURLCredential * _Nullable))callback {
    self.authenticationAlert = [[AuthenticationAlert alloc] init];
    __weak ViewController *weakSelf = self;
    
    self.authenticationAlert.didSignin = ^(Credential * credential) {
        callback([[NSURLCredential alloc] initWithUser:[credential username] password:[credential password] persistence:NSURLCredentialPersistenceForSession]);
        [weakSelf removeAuthenticationAlert];
    };
    
    self.authenticationAlert.didCancel = ^{
        callback(nil);
        [weakSelf removeAuthenticationAlert];
    };
    
    NSString *host = [[self.payproGlobal url] host];
    [self.authenticationAlert showWindow:self];
    [[self.authenticationAlert url] setStringValue:host];

}

- (void)removeAuthenticationAlert{
    [[self.authenticationAlert window] orderOut:self];
    self.authenticationAlert = nil;
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
