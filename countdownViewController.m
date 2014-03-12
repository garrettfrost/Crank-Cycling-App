/*
 countdownViewController
 gives the user a countdown before beggining a ride
 this is done to allow the user's phone's GPS to acquire a reasonable signal before the ride begins
 When the countdown finishes it automatically segues.
 */

#import "countdownViewController.h"

@interface countdownViewController ()

@end

@implementation countdownViewController

@synthesize progress, currMinute, currSeconds, timer;

int hours, minutes, seconds;
int secondsLeft;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    progress.backgroundColor=[UIColor clearColor];
    currMinute=0;
    currSeconds=10;
    self.progress.font = [UIFont fontWithName:@"Aero" size:100.0];
    [self.progress setTextColor:[UIColor whiteColor]];
    
    [self start];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [timer invalidate];
}

-(void)start
{
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 5; // meters
    
    [self.locationManager startUpdatingLocation];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)timerFired
{
    if((currMinute > 0 || currSeconds >= 0) && currMinute >= 0)
    {
        if(currSeconds == 0)
        {
            currMinute -= 1;
            currSeconds = 59;
        }
        else if(currSeconds > 0)
        {
            currSeconds -= 1;
        }
        if(currMinute >- 1)
            [progress setText:[NSString stringWithFormat:@"%d", currSeconds]];
    }
    else
    {
        [timer invalidate];
        [self performSegueWithIdentifier:@"countdown_finished_segue" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    rideViewController *dest = segue.destinationViewController;
    dest.ride = self.ride;
}

@end
