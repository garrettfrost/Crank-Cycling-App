//
//  personalAchievementViewController.h
//  ui testing
//
//  Created by Garrett on 16/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "KeychainItemWrapper.h"
#import "personalAchievement.h"
#import <CommonCrypto/CommonDigest.h>

@interface personalAchievementViewController : UITableViewController<NSXMLParserDelegate>

@property(weak, nonatomic)IBOutlet UIActivityIndicatorView *loadingIndicator;
@property(nonatomic)IBOutlet UIBarButtonItem *sidebarButton;

@property(retain, nonatomic)NSMutableArray *personalAchievements;
@property(retain, nonatomic)NSString *userName, *password, *getAchievementsString, *readString, *xmlString;
@property(strong, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSMutableString *currentElementValue;

@property(retain, nonatomic)personalAchievement *pAchiev;
@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;

-(void)setRequestString;
- (NSString *) md5:(NSString *) input;

@end
