//
//  ridePoint.h
//  ui testing
//
//  Created by cs321kw1a on 9/10/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#include <CommonCrypto/CommonDigest.h>

@interface ridePoint : NSObject
@property(nonatomic)CLLocationCoordinate2D location;
@property float dist, ele, spd;
@property(retain, nonatomic)NSDate *cTime;

@end
