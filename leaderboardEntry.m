/*
 leaderboardEntry.m
 holds the information relevent to a leaderboard entry including the rank and user id
 */

#import "leaderboardEntry.h"

@implementation leaderboardEntry

-(id) init
{
    self = [super init];
    
    if(self)
    {
        self.lbDura = 0;
        self.lbRank = [[NSString alloc]init];
        self.uID = [[NSString alloc]init];
    }
    return self;
}


@end
