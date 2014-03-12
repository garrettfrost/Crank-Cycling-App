//
//  rideViewController.h
//  ui testing
//
//  Created by Garrett on 13/08/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rideDetailsViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *rideNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *rideNameTextField;
@property (weak, nonatomic) IBOutlet UITableView *rideType;
@property (weak, nonatomic) IBOutlet UITableView *rideTerrain;

- (IBAction)startButtonPressed:(id)sender;

@end
