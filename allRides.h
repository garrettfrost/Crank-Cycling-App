//
//  allRidesRide.h
//  ui testing
//
//  Created by Garrett on 8/10/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface allRides : NSObject

@property int rID, dura;
@property(retain, nonatomic) NSString *name;
@property(retain, nonatomic) NSDate *sTime;
@property float dist;

+ (id)sharedManager;

@end
