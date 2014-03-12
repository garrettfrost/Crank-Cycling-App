//
//  rideResultsViewController.h
//  ui testing
//
//  Created by Garrett on 17/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ride.h"
#import "personalAchievement.h"
#import "baselineAchievement.h"
#import "segment.h"

@interface rideResultsViewController : UITableViewController<UIAlertViewDelegate>

@property(nonatomic, retain)ride *singleRideSingleton;
@property(retain, nonatomic)segment *segment;
@end