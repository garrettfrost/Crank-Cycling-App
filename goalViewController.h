//
//  goalViewController.h
//  ui testing
//
//  Created by Garrett on 16/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "KeychainItemWrapper.h"
#import "goal.h"
#import <CommonCrypto/CommonDigest.h>

@interface goalViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate, UIAlertViewDelegate>

@property(weak, nonatomic)IBOutlet UILabel *goalNameLabel;
@property(weak, nonatomic)IBOutlet UILabel *goalProgressLabel;
@property(weak, nonatomic)IBOutlet UILabel *goalHeadingLabel;
@property(weak, nonatomic)IBOutlet UIProgressView *goalProgress;
@property(weak, nonatomic)IBOutlet UITableView *previousGoalsTable;
@property(weak, nonatomic)IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(nonatomic)IBOutlet UIBarButtonItem *sidebarButton;

@property(retain, nonatomic)NSMutableArray *previousGoals;
@property(retain, nonatomic)NSString *userName, *password, *getAchievementsString, *readString, *xmlString;
@property(strong, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSMutableString *currentElementValue;

@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@property(retain, nonatomic)goal *goal, *currentGoal;

-(void)setRequestString;
-(NSString *) md5:(NSString *) input;

@end
