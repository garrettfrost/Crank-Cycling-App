//
//  rideNameViewController.h
//  ui testing
//
//  Created by Garrett on 7/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RideNameDelegate

@required
-(void)hasEnteredRideName : (NSString*)rideName;

@end

@interface rideNameViewController : UIViewController <UITextFieldDelegate>

@property(nonatomic, strong) id <RideNameDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *rideName;

@end

