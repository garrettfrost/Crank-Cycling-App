//
//  segment.h
//  ui testing
//
//  Created by cs321kw1a on 9/10/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ridePoint.h"
#import "leaderboardEntry.h"

@interface segment : NSObject

@property int sID, sDura, cat;
@property NSString *sName, *sRank, *type, *pRank;
@property CLLocationCoordinate2D location;
@property float sDist, avgGrad, hEle, lEle, gain, hClimb, pTime;
@property(retain, nonatomic)NSDate *sTime;
@property(retain, nonatomic)NSMutableArray *pointsArray, *leaderboardArray;
+ (id)sharedManager;

@end
