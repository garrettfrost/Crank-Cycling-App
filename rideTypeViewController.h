//
//  rideTypeViewController.h
//  ui testing
//
//  Created by Garrett on 7/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RideTypeDelegate

@required
-(void)hasChosenType : (NSString*)name;

@end

@interface rideTypeViewController : UITableViewController

@property(nonatomic, strong) id <RideTypeDelegate> delegate;

@end
