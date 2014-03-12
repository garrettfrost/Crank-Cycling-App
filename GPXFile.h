//
//  GPXFile.h
//  Crank
//
//  Created by Garrett on 23/10/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GPXFile : NSManagedObject

@property (nonatomic, retain) NSString * gpxString;
@property (nonatomic, retain) NSString * userName;

@end
