//
//  rideViewController.m
//  ui testing
//
//  Created by Garrett on 13/08/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import "rideDetailsViewController.h"

@interface rideDetailsViewController ()

@end

@implementation rideDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.rideNameLabel setTextColor:[UIColor whiteColor]];
    [self.rideNameLabel setFont:[UIFont fontWithName:@"Aero" size:18.0]];
    [self.rideNameLabel setText:@"Ride Name"];
    
    self.rideNameTextField.delegate = self;
    self.rideTerrain.delegate = self;
    self.rideType.delegate = self;
    
    [self addSubView:self.rideTerrain];
    [self addSubView:self.rideType];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.rideNameTextField resignFirstResponder];
    
    return YES;
}

- (IBAction)startButtonPressed:(id)sender {
}
@end
