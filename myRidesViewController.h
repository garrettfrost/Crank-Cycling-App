//
//  myRidesViewController.h
//  ui testing
//
//  Created by Garrett on 21/08/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "allRides.h"
#import "rideOverviewViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface myRidesViewController : UITableViewController<NSXMLParserDelegate, UIAlertViewDelegate>

@property(nonatomic)IBOutlet UIBarButtonItem *sidebarButton;
@property(weak, nonatomic)IBOutlet UIActivityIndicatorView *loadIndicator;

@property(retain, nonatomic)NSMutableArray *thisWeek, *lastWeek, *older;
@property(retain, nonatomic)NSString *getRidesString, *readString, *xmlString, *password, *userName;
@property(retain, nonatomic)NSMutableString *currentElementValue;
@property(strong, nonatomic)NSXMLParser *xmlParserObject;

@property(retain, nonatomic)allRides *ride, *displayRide;
@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;

-(void)setUpParseObject;
-(void)connect;

@end
