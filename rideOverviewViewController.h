//
//  rideOverviewViewController.h
//  ui testing
//
//  Created by Garrett on 16/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "allRides.h"
#import "segment.h"
#import "baselineAchievement.h"
#import "ridePoint.h"
#import "ride.h"
#import "settings.h"
#import "personalAchievement.h"
#import "GCDAsyncSocket.h"
#import <CommonCrypto/CommonDigest.h>

@interface rideOverviewViewController : UIViewController<NSXMLParserDelegate,UIAlertViewDelegate>

@property(weak, nonatomic)IBOutlet UILabel *rideNameLabel;
@property(weak, nonatomic)IBOutlet UILabel *rideTypeLabel;
@property(weak, nonatomic)IBOutlet UILabel *distanceNumberLabel;
@property(weak, nonatomic)IBOutlet UILabel *averageSpeedLabel;
@property(weak, nonatomic)IBOutlet UILabel *dateAndTimeLabel;
@property(weak, nonatomic)IBOutlet UILabel *rideTimeLabel;
@property(weak, nonatomic)IBOutlet UILabel *distanceSubtitle;
@property(weak, nonatomic)IBOutlet UILabel *dateSubtitle;
@property(weak, nonatomic)IBOutlet UILabel *speedSubtitle;
@property(weak, nonatomic)IBOutlet UILabel *rideTimeSubtitle;
@property(weak, nonatomic)IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(retain, nonatomic)NSMutableString *currentElementValue;
@property(strong, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSString *getRideString, *xmlString, *readString, *rideID, *result, *userName, *password;

@property(retain, nonatomic)IBOutlet GMSMapView *mapView;
@property(retain, nonatomic)allRides *rideSingleton;
@property(retain, nonatomic)ride *ride;
@property(retain, nonatomic)baselineAchievement *bAchiev;
@property(retain, nonatomic)personalAchievement *pAchiev;
@property(retain, nonatomic)segment *seg;
@property(retain, nonatomic)ridePoint *point;
@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@property(retain, nonatomic)settings *userSettings;

@property bool isReadyToParse;

-(void)setUpParseObject;
-(void)setUpGUI;
-(void)putLocationsOnMap;


@end
