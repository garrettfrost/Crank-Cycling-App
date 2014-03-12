//
//  segmentClimbViewController.h
//  ui testing
//
//  Created by Garrett on 19/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "segment.h"
#import "settings.h"
#import "ridePoint.h"
#import <ShinobiCharts/ShinobiChart.h>

@interface segmentClimbViewController : UIViewController<SChartDatasource>

@property(weak, nonatomic)IBOutlet UIView *graphView;
@property(weak, nonatomic)IBOutlet UILabel *segmentNameLabel;
@property(weak, nonatomic)IBOutlet UILabel *climbAmount;
@property(weak, nonatomic)IBOutlet UILabel *climbLabel;
@property(weak, nonatomic)IBOutlet UILabel *startAmount;
@property(weak, nonatomic)IBOutlet UILabel *startLabel;
@property(weak, nonatomic)IBOutlet UILabel *gainAmount;
@property(weak, nonatomic)IBOutlet UILabel *gainLabel;
@property(weak, nonatomic)IBOutlet UILabel *segmentSubtitle;
@property (weak, nonatomic) IBOutlet UIView *chartView;

@property(retain, nonatomic)segment *segment;
@property(retain, nonatomic)settings *userSettings;
@property(retain, nonatomic)ShinobiChart *chart;

@end
