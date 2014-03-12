//
//  mapWhileRidingViewController.h
//  ui testing
//
//  Created by Garrett on 19/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface mapWhileRidingViewController : UIViewController

@property GMSMapView *mapView;
@property NSMutableArray *mapLocations;

- (void)putLocationsOnMap;
- (IBAction)doneButtonPressed:(id)sender;

@end
