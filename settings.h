//
//  settings.h
//  ui testing
//
//  Created by Garrett on 7/09/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface settings : NSObject<NSCoding>

@property (nonatomic) NSString *units;

-(id)initWithUnits: (NSString*)units;
+ (id)sharedManager;

@end
