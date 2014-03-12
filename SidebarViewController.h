//
//  SidebarViewController.h
//  SidebarDemo
//
//  Created by Simon on 29/6/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

@interface SidebarViewController : UITableViewController

@property(retain, nonatomic)KeychainItemWrapper *keychainItem;
@end
