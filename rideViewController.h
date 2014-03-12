//
//  rideViewController.h
//  ui testing
//
//  Created by Garrett on 15/08/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ride.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "mapWhileRidingViewController.h"
#import "settings.h"
#import "GCDAsyncSocket.h"
#import "MainViewController.h"
#import "KeychainItemWrapper.h"
#import "GPXFile.h"
#import <CommonCrypto/CommonDigest.h>

@interface rideViewController : UIViewController<CLLocationManagerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSStreamDelegate, NSXMLParserDelegate, UIAlertViewDelegate>

@property(weak, nonatomic)IBOutlet UILabel *timeSubtitle;
@property(weak, nonatomic)IBOutlet UILabel *timeNumber;
@property(weak, nonatomic)IBOutlet UILabel *averageSpeedSubtitle;
@property(weak, nonatomic)IBOutlet UILabel *averageSpeedNumber;
@property(weak, nonatomic)IBOutlet UILabel *distanceNumber;
@property(weak, nonatomic)IBOutlet UILabel *distanceSubtitle;
@property(weak, nonatomic)IBOutlet UIButton *pauseButton;
@property IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *uploadingIndicator;

@property(retain, nonatomic)UIImagePickerController *imagePicker;
@property(retain, nonatomic)NSString *distance, *avgSpeed, *userName, *password, *rideName, *rideType, *xmlString, *readString, *gpx, *pointString;
@property(retain, nonatomic)NSMutableArray *locations, *messages, *locationHistory, *speedHistory;
@property(retain, nonatomic)NSMutableString *currentElementValue;
@property(retain, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSTimer *stopWatchTimer;
@property(retain, nonatomic)NSDate *startDate, *pausedDate, *startTime;

@property double totalSpeed;
@property int timePassed, pauseInterval;
@property bool shouldBeUpdating, shouldLogOut;
@property float numSeconds, avgSpeedValue;

@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)settings *userSettings;
@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@property(retain, nonatomic)ride *ride;

@property NSTimeInterval lastDistanceCalculation;
@property CLLocationManager *locationManager;
@property CLLocationDistance totalDistance;
-(IBAction)pauseButtonPressed:(id)sender;
-(IBAction)showCamera:(id)sender;
-(void)updateTimer;
-(void)createGPX;
-(NSString *) md5:(NSString *) input;
-(void)saveRideAndAlert;


@end
