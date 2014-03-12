/*
 segments.m
 This is the segments class. It handles the storing of segments including its type, ID, name
 and a users rank for that segment
 */

#import "segment.h"

@implementation segment


-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.sID = 0;
        self.sDura = 0;
        self.sName = [[NSString alloc]init];
        self.sRank = [[NSString alloc]init];
        self.sTime = [[NSDate alloc]init];
        self.sDist = 0;
        self.cat = 0;
        self.avgGrad = 0;
        self.hEle = 0;
        self.lEle = 0;
        self.gain = 0;
        self.hClimb = 0;
        self.type = [[NSString alloc]init];
        self.pRank = [[NSString alloc]init];
        self.pTime = 0;
    }
    return self;
}

+ (id)sharedManager
{
    static segment *sharedSegment = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSegment = [[self alloc] init];
    });
    return sharedSegment;
}

@end
