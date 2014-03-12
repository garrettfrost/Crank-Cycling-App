/*
 allRides.m
 the all rides class is used solely for the storing of the list of rides a user has undertaken
 It is then used to get the id of a particular ride for more detailed information
 */

#import "allRides.h"

@implementation allRides

-(id) init
{
    self = [super init];
    
    if(self)
    {
        self.rID = 0;
        self.dura = 0;
        self.name = [[NSString alloc]init];
        self.dist = 0;
        self.sTime = [[NSDate alloc]init];
    }
    return self;
}

+ (id)sharedManager
{
    static allRides *sharedAllRides = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAllRides = [[self alloc] init];
    });
    return sharedAllRides;
}

@end
