//
//  baselineAchievementViewController.h
//  ui testing
//
//  Created by Garrett on 16/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "KeychainItemWrapper.h"
#import "baselineAchievement.h"
#import <CommonCrypto/CommonDigest.h>

@interface baselineAchievementViewController : UITableViewController<NSXMLParserDelegate, UIAlertViewDelegate>

@property(nonatomic)IBOutlet UIBarButtonItem *sidebarButton;
@property(weak, nonatomic)IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(retain, nonatomic)NSMutableArray *baselineAchievements, *incompleteAchievs;
@property(retain, nonatomic)NSString *userName, *password, *getAchievementsString, *readString, *xmlString;
@property(strong, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSMutableString *currentElementValue;

@property(retain, nonatomic)baselineAchievement *bAchiev;
@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;

-(void)setRequestString;
-(NSString *) md5:(NSString *) input;

@end
