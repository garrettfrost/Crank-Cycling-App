//
//  loginViewController.h
//  ui testing
//
//  Created by Garrett on 7/10/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <dispatch/dispatch.h>
#import "GCDAsyncSocket.h"
#import <CommonCrypto/CommonDigest.h>
#import "GPXFile.h"

@interface loginViewController : UIViewController<UITextFieldDelegate, NSXMLParserDelegate, UIAlertViewDelegate>

@property(weak, nonatomic)IBOutlet UILabel *loginLabel;
@property(weak, nonatomic)IBOutlet UITextField *usernameTextfield;
@property(weak, nonatomic)IBOutlet UITextField *passwordTextfield;
@property(weak, nonatomic)IBOutlet UIButton *loginButton;
@property(retain, nonatomic)IBOutlet UIActivityIndicatorView *loginActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *signUpView;

@property(retain, nonatomic) NSString *username, *password, *requestString, *readString, *xmlString, *resultString, *unencryptedPassword;
@property(retain, nonatomic)NSMutableString *currentElementValue;
@property(retain, nonatomic)NSArray *previousRides;
@property(strong, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSData *readInData;

@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;

@property(nonatomic)BOOL hasPassword, hasUsername, loggedIn;

-(IBAction)loginButtonPressed:(id)sender;
-(void)checkLogin;
-(void)setUpParseObject;
-(void)connect;
-(void)autoLogin;

@end
