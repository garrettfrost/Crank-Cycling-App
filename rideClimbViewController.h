//
//  rideClimbViewController.h
//  ui testing
//
//  Created by Garrett on 17/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ride.h"
#import "ridePoint.h"
#import "settings.h"
#import <ShinobiCharts/ShinobiChart.h>

@interface rideClimbViewController : UIViewController<SChartDatasource>

@property(weak, nonatomic)IBOutlet UILabel *rideNameLabel;
@property(weak, nonatomic)IBOutlet UILabel *climbAmount;
@property(weak, nonatomic)IBOutlet UILabel *climbLabel;
@property(weak, nonatomic)IBOutlet UILabel *startAmount;
@property(weak, nonatomic)IBOutlet UILabel *startLabel;
@property(weak, nonatomic)IBOutlet UILabel *gainAmount;
@property(weak, nonatomic)IBOutlet UILabel *gainLabel;
@property(weak, nonatomic)IBOutlet UIView *chartView;

@property(retain, nonatomic)settings *userSettings;
@property(retain, nonatomic)ride* ride;
@property(retain, nonatomic)ShinobiChart *chart;

-(void)setUpGUI;

@end
