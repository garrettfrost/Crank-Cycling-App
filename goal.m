/*
 goal.m
 handles the storing of a goal and its relevent information
 including its target, progress name and a display picture
 */

#import "goal.h"

@implementation goal

-(id) init
{
    self = [super init];
    
    if(self)
    {
        self.target = 0;
        self.progress = 0;
        self.name = [[NSString alloc]init];
        self.dp = [[NSString alloc]init];
    }
    return self;
}

@end
