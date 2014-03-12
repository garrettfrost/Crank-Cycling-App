/*
 ride.m
 This is the ride class, which holds information on a ride including its achievement, 
 segments and many other statistics
 */

#import "ride.h"

@implementation ride

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.name = [[NSString alloc]init];
        self.type = [[NSString alloc]init];
        self.rID = 0;
        self.rDura = 0;
        self.mTime = 0;
        self.rDist = 0;
        self.avgSpd = 0;
        self.avgMoveSpeed = 0;
        self.maxSpd = 0;
        self.hEle = 0;
        self.lEle = 0;
        self.gain = 0;
        self.hClimb = 0;
        self.rTime = [[NSDate alloc]init];
        self.distance = 0;
        self.pointArray = [[NSMutableArray alloc]init];
        self.segmentArray = [[NSMutableArray alloc]init];
        self.personalAchievementsArray = [[NSMutableArray alloc]init];
        self.baselineAchievementsArray = [[NSMutableArray alloc]init];
    }
    
    return self;
}

-(id)initWith : (NSString*)name andType: (NSString*)type
{
    self = [super init];
    
    if(self)
    {
        self.name = name;
        self.type = type;
    }
    
    return self;
}

+ (id)sharedManager
{
    static ride *sharedRides = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRides = [[self alloc] init];
    });
    return sharedRides;
}

@end
