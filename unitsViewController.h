//
//  unitsViewController.h
//  ui testing
//
//  Created by Garrett on 6/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "settings.h"

@interface unitsViewController : UITableViewController

@property(retain, nonatomic)settings *userSettings;
@property(retain, nonatomic)NSString *units;
@end
