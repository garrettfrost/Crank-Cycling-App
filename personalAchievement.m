/*
 personalAchievement.m
 this is the personal achievement class. It handles the storing of personal achievements
 and its variables such as the displauy picture and name
 */

#import "personalAchievement.h"

@implementation personalAchievement

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.name = [[NSString alloc]init];
        self.dp = [[NSString alloc]init];
        self.time = [[NSDate alloc]init];
        self.val = [[NSString alloc]init];
    }
    
    return self;
}

@end
