//
//  ride.h
//  ui testing
//
//  Created by Garrett on 7/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ride : NSObject

@property int rID, rDura, mTime;
@property float rDist, avgSpd, avgMoveSpeed, maxSpd, hEle, lEle, gain, hClimb;
@property(retain, nonatomic)NSDate *rTime;
@property(retain, nonatomic)NSString *name, *type;
@property float distance;
@property NSMutableArray *pointArray, *segmentArray, *personalAchievementsArray, *baselineAchievementsArray;

-(id)init;
-(id)initWith : (NSString*)name andType: (NSString*)type;
+ (id)sharedManager;

@end
