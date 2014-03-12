//
//  segmentOverviewViewController.h
//  ui testing
//
//  Created by Garrett on 19/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "segment.h"
#import "GCDAsyncSocket.h"
#import <CommonCrypto/CommonDigest.h>
#import "settings.h"

@interface segmentOverviewViewController : UIViewController<NSXMLParserDelegate, UIAlertViewDelegate>

@property(weak, nonatomic)IBOutlet UILabel *segmentNameLabel;
@property(weak, nonatomic)IBOutlet UILabel *distanceNumberLabel;
@property(weak, nonatomic)IBOutlet UILabel *bestTimeLabel;
@property(weak, nonatomic)IBOutlet UILabel *standingLabel;
@property(weak, nonatomic)IBOutlet UILabel *distanceSubtitle;
@property(weak, nonatomic)IBOutlet UILabel *bestTimeSubtitle;
@property(weak, nonatomic)IBOutlet UILabel *standingSubtitle;
@property(weak, nonatomic)IBOutlet UILabel *segmentSubtitle;
@property(weak, nonatomic)IBOutlet UIActivityIndicatorView *loadingIndicator;

@property(retain, nonatomic)NSString *userName, *password, *getSegmentString, *xmlString, *readString;
@property(retain, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSMutableString *currentElementValue;

@property(weak, nonatomic)IBOutlet GMSMapView *mapView;
@property(retain, nonatomic)segment *segment;
@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@property(retain, nonatomic)ridePoint *point;
@property(retain, nonatomic)leaderboardEntry *leaderboard;
@property(retain, nonatomic)settings *userSettings;

-(NSString *) md5:(NSString *) input;
-(void)putLocationsOnMap;
-(void)setUpGUI;


@end