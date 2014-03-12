/*
 settings.m
 this is the settings class and handles storing the units of measurement
 the user has selected to view the app in
 */

#import "settings.h"

@implementation settings

-(id)init
{
    self = [super init];
    
    if(self)
    {
        self.units = [[NSString alloc]init];
    }
    
    return self;
}

-(id)initWithUnits: (NSString*)units;
{
    self = [super init];
    if(self)
    {
        self.units = units;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    if (self)
    {
        self.units = [decoder decodeObjectForKey:@"units"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[self units] forKey:@"units"];
}

+ (id)sharedManager
{
    static settings *sharedSettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[self alloc] init];
    });
    return sharedSettings;
}


@end
