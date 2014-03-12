//
//  localSegmentsViewController.h
//  ui testing
//
//  Created by Garrett on 19/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CommonCrypto/CommonDigest.h>
#import "KeychainItemWrapper.h"
#import "GCDAsyncSocket.h"
#import "segment.h"
#import "segmentOverviewViewController.m"

@interface localSegmentsViewController : UIViewController<CLLocationManagerDelegate, NSXMLParserDelegate, GMSMapViewDelegate, UIAlertViewDelegate>

@property(strong, nonatomic)IBOutlet UIBarButtonItem *sidebarButton;

@property(retain, nonatomic)CLLocationManager *locationManager;
@property(retain, nonatomic)NSString *locationString, *getSegmentString, *xmlString, *readString;
@property(retain, nonatomic)NSMutableString *currentElementValue;
@property(retain, nonatomic)CLGeocoder *geocoder;
@property(retain, nonatomic)NSXMLParser *xmlParserObject;
@property(retain, nonatomic)NSString *userName, *password;
@property(retain, nonatomic)NSMutableArray *localSegments;
@property CLLocationCoordinate2D userLocation;
@property CLPlacemark *placemark;

@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@property(retain, nonatomic)GCDAsyncSocket *socket;
@property(retain, nonatomic)segment *seg;
@property GMSMapView *mapView;

@property double lat, lon;
@property int segID;

-(void)setRequestString;
-(NSString *) md5:(NSString *) input;
-(void)addSegmentsToMap;

@end
