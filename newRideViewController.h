//
//  newRideViewController.h
//  ui testing
//
//  Created by Garrett on 7/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "rideNameViewController.h"
#import "rideTypeViewController.h"
#import "ride.h"
#import "countdownViewController.h"

@interface newRideViewController : UITableViewController<RideNameDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *playButtonPressed;

@property NSString *rideName, *rideType;

@property ride *rideToSend;

- (IBAction)playButtonPressed:(id)sender;
@end
