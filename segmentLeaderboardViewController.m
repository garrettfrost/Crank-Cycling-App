//
//  segmentLeaderboardViewController.m
//  ui testing
//
//  Created by Garrett on 28/08/13.
//  Copyright (c) 2013 gf99. All rights reserved.
//

#import "segmentLeaderboardViewController.h"
#import "SWRevealViewController.h"

@interface segmentLeaderboardViewController ()

@end

@implementation segmentLeaderboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.parentViewController.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"crankLogoTitlebar.png"]];
    
    // Change buton color
    
    self.parentViewController.navigationItem.leftBarButtonItem = _sidebarButton;
    
    _sidebarButton.tintColor = [UIColor redColor];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
