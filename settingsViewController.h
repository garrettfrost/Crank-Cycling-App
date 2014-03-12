//
//  settingsViewController.h
//  ui testing
//
//  Created by Garrett on 5/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "unitsViewController.h"
#import "settings.h"
#import "KeychainItemWrapper.h"
#import "GPXFile.h"
#import "GCDAsyncSocket.h"
#import "loginViewController.h"
#import "MainViewController.h"

@interface settingsViewController : UITableViewController<NSXMLParserDelegate, UIAlertViewDelegate>

@property(weak, nonatomic)IBOutlet UIBarButtonItem *sidebarButton;
@property(weak, nonatomic)IBOutlet UIBarButtonItem *saveButton;

@property(retain, nonatomic)NSString *fName, *lName, *dob, *units, *gender, *userName, *password, *readString, *xmlString, *resultString;
@property(retain, nonatomic)NSArray *usersRides, *menuItems;;
@property(retain, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSMutableString *currentElementValue;

@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@property(retain, nonatomic)settings *userSettings;
@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)GPXFile *gpxToUpload;

@property (nonatomic) BOOL areSettings;

-(IBAction)saveButtonPressed:(id)sender;
-(IBAction)uploadButtonPressed:(id)sender;
-(void)connect;

@end
