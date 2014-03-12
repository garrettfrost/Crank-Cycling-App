/*
 baselineAchievement.m
 this is the baseline achievement class. It handles the storing of baseline achievements
 and its variables such as the displauy picture and name
 */

#import "baselineAchievement.h"

@implementation baselineAchievement


-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.name = [[NSString alloc]init];
        self.des = [[NSString alloc]init];
        self.displayPic = [[NSString alloc]init];
        self.date = [[NSDate alloc]init];
    }
    
    return self;
}

@end
