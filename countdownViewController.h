//
//  countdownViewController.h
//  ui testing
//
//  Created by cs321kw1a on 9/10/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ride.h"
#import "rideViewController.h"

@interface countdownViewController : UIViewController<CLLocationManagerDelegate>

@property(retain, nonatomic) IBOutlet UILabel *progress;
@property(retain, nonatomic)NSTimer *timer;
@property CLLocationManager *locationManager;

@property(retain, nonatomic) ride *ride;

@property int currMinute;
@property int currSeconds;

@end
