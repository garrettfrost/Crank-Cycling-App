//
//  homeScreenViewController.h
//  ui testing
//
//  Created by Garrett on 13/08/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "baselineAchievement.h"
#import "personalAchievement.h"
#import "settings.h"
#import "goal.h"
#import <CommonCrypto/CommonDigest.h>

@interface MainViewController : UIViewController<NSXMLParserDelegate, UIAlertViewDelegate>

@property(weak, nonatomic)IBOutlet UILabel *userName;
@property(weak, nonatomic)IBOutlet UILabel *distanceNum;
@property(weak, nonatomic)IBOutlet UILabel *distanceLabel;
@property(weak, nonatomic)IBOutlet UILabel *rideTimeLabel;
@property(weak, nonatomic)IBOutlet UILabel *personalAchievments;
@property(weak, nonatomic)IBOutlet UILabel *baselineAchievments;
@property(weak, nonatomic)IBOutlet UILabel *goalProgress;
@property(weak, nonatomic)IBOutlet UILabel *goalName;
@property(weak, nonatomic)IBOutlet UILabel *goalAmount;
@property(weak, nonatomic)IBOutlet UILabel *totalRideTime;

@property(weak, nonatomic)IBOutlet UIButton *personalAchievOne;
@property(weak, nonatomic)IBOutlet UIButton *personalAchievTwo;
@property(weak, nonatomic)IBOutlet UIButton *personalAchievThree;
@property(weak, nonatomic)IBOutlet UIButton *baselineAchievOne;
@property(weak, nonatomic)IBOutlet UIButton *baselineAchievTwo;
@property(weak, nonatomic)IBOutlet UIButton *baselineAchievThree;
@property(weak, nonatomic)IBOutlet UIProgressView *progressBar;
@property(weak, nonatomic)IBOutlet UIBarButtonItem *sidebarButton;
@property(weak, nonatomic)IBOutlet UINavigationBar *navigationBar;
@property(retain, nonatomic)IBOutlet UIActivityIndicatorView *loginActivityIndicator;

@property(weak, nonatomic) UIColor *textColour;
@property(weak, nonatomic) UIColor *greyTextColour;

@property(retain, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSString *resultString, *xmlString, *getHomeString, *readString, *firstName, *lastName, *uName, *pWord;
@property(retain, nonatomic)NSMutableString *currentElementValue;
@property(retain, nonatomic)NSMutableArray *baselineAchievements, *personalAchievements;
@property float dist, rt;
@property bool shouldLogOut;

@property(retain, nonatomic)personalAchievement *personalAchiev;
@property(retain, nonatomic)baselineAchievement *baselineAchiev;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@property(retain, nonatomic)settings *userSettings;
@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)goal *goal;

- (IBAction)achievmentPressed:(id)sender;
-(void)setUpGUI;
- (NSString *) md5:(NSString *)input;
-(void)setRequestString;

@end
