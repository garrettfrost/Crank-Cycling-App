/*
 ridePoint.m
 This is the ridepoint class and handles the storing of a point in a ride or segment.
 It holds all values a point needs in regards to a GPX file
 */

#import "ridePoint.h"

@implementation ridePoint

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.dist = 0;
        self.ele = 0;
        self.spd = 0;
        self.cTime = [[NSDate alloc]init];
    }
    
    return self;
}

@end
