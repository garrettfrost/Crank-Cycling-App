/*
 rideClimbViewController
 This shiows the maximum elevation, highest climb and the overall gain for 
 a selected ride. It also shows an elevation over time graph
 */

#import "rideClimbViewController.h"

@interface rideClimbViewController ()

@end

@implementation rideClimbViewController

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
    
    self.parentViewController.navigationItem.title = @"Ride Overview";
    
    self.ride = [ride sharedManager];
    [self setUpGUI];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.chart = [[ShinobiChart alloc]initWithFrame:self.chartView.bounds];
    self.chart.licenseKey = @"faiwOZDXPxkDV1zMjAxMzExMjFpbmZvQHNoaW5vYmljb250cm9scy5jb20=8Edj91TgvIyE3Kih1ij1lPLoYRaNFE8p/k3FlsW//Qe5oyAoIIFgJJU0GPfFaWZRbMdbQcwYcbHKYmmdRE3zMFZpPO4oOjdRli2DObjJtJc74syfw61a0T1CNjPgR4+wVf73SXAAoEU2yE4zZHgJ2KcunN8g=BQxSUisl3BaWf/7myRmmlIjRnMU2cA7q+/03ZX9wdj30RzapYANf51ee3Pi8m2rVW6aD7t6Hi4Qy5vv9xpaQYXF5T7XzsafhzS3hbBokp36BoJZg8IrceBj742nQajYyV7trx5GIw9jy/V6r0bvctKYwTim7Kzq+YPWGMtqtQoU=PFJTQUtleVZhbHVlPjxNb2R1bHVzPnh6YlRrc2dYWWJvQUh5VGR6dkNzQXUrUVAxQnM5b2VrZUxxZVdacnRFbUx3OHZlWStBK3pteXg4NGpJbFkzT2hGdlNYbHZDSjlKVGZQTTF4S2ZweWZBVXBGeXgxRnVBMThOcDNETUxXR1JJbTJ6WXA3a1YyMEdYZGU3RnJyTHZjdGhIbW1BZ21PTTdwMFBsNWlSKzNVMDg5M1N4b2hCZlJ5RHdEeE9vdDNlMD08L01vZHVsdXM+PEV4cG9uZW50PkFRQUI8L0V4cG9uZW50PjwvUlNBS2V5VmFsdWU+";
    
    self.chart.datasource = self;
    self.chart.autoresizingMask = ~UIViewAutoresizingNone;
    
    SChartNumberAxis *xAxis = [[SChartNumberAxis alloc] init];
    self.chart.xAxis = xAxis;
    
    // Use a number axis for the y axis.
    SChartNumberAxis *yAxis = [[SChartNumberAxis alloc] init];
    self.chart.yAxis = yAxis;
    
    [self.chartView addSubview:self.chart];
    
    UIBarButtonItem *rideButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Ride"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(ridePushed)];
    self.parentViewController.navigationItem.rightBarButtonItem = rideButton;
}

-(IBAction)ridePushed
{
    [self performSegueWithIdentifier:@"ride_segue" sender:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpGUI
{
    NSString *maxClimb, *start, *gain;
    //Get the list of paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //Get the documentsDirectory
    NSString *documentsDirectory = [paths lastObject];
    //Get the filepath
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"userSettings"];
    self.userSettings = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    if([self.userSettings.units isEqualToString:@"Metric"])
    {
        maxClimb = [NSString stringWithFormat:@"%0.2fm", self.ride.hEle];
        start = [NSString stringWithFormat:@"%0.2fm", self.ride.hClimb];
        gain = [NSString stringWithFormat:@"%0.2fm", self.ride.gain];
    }
    else
    {
        maxClimb = [NSString stringWithFormat:@"%0.2fft", self.ride.hEle * 3.2808399];
        start = [NSString stringWithFormat:@"%0.2fft", self.ride.hClimb * 3.2808399];
        gain = [NSString stringWithFormat:@"%0.2fft", self.ride.gain * 3.2808399];
    }
    
    self.rideNameLabel.adjustsFontSizeToFitWidth = YES;
    [self.rideNameLabel setTextColor:[UIColor whiteColor]];
    [self.rideNameLabel setFont:[UIFont fontWithName:@"Aero" size:30.0]];
    [self.rideNameLabel setText:self.ride.name];
    
    [self.climbAmount setTextColor:[UIColor whiteColor]];
    [self.climbAmount setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    [self.climbAmount setText:maxClimb];
    
    [self.climbLabel setTextColor:[UIColor grayColor]];
    [self.climbLabel setFont:[UIFont fontWithName:@"Aero" size:15.0]];
    [self.climbLabel setText:@"Max"];
    
    [self.startAmount setTextColor:[UIColor whiteColor]];
    [self.startAmount setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    [self.startAmount setText:start];
    
    [self.startLabel setTextColor:[UIColor grayColor]];
    [self.startLabel setFont:[UIFont fontWithName:@"Aero" size:15.0]];
    [self.startLabel setText:@"Highest Climb"];
    
    [self.gainAmount setTextColor:[UIColor whiteColor]];
    [self.gainAmount setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    [self.gainAmount setText:gain];
    
    [self.gainLabel setTextColor:[UIColor grayColor]];
    [self.gainLabel setFont:[UIFont fontWithName:@"Aero" size:15.0]];
    [self.gainLabel setText:@"Gain"];
}

- (int)numberOfSeriesInSChart:(ShinobiChart *)chart
{
    return 1;
}

// Returns the series at the specified index for a given chart
-(SChartSeries *)sChart:(ShinobiChart *)chart seriesAtIndex:(int)index {
    
    // In our example all series are line series.
    SChartLineSeries *lineSeries = [[SChartLineSeries alloc] init];
    
    return lineSeries;
}

// Returns the number of points for a specific series in the specified chart
- (int)sChart:(ShinobiChart *)chart numberOfDataPointsForSeriesAtIndex:(int)seriesIndex {
    // In this example each series has 100 points
    return [self.ride.pointArray count];
}

// Returns the data point at the specified index for the given series/chart.
- (id<SChartData>)sChart:(ShinobiChart *)chart dataPointAtIndex:(int)dataIndex forSeriesAtIndex:(int)seriesIndex
{
    
    //Construct a data point to return
    SChartDataPoint *datapoint = [[SChartDataPoint alloc] init];
    
    ridePoint *point = [self.ride.pointArray objectAtIndex:dataIndex];
    float locat = point.ele;
    
    datapoint.xValue = [NSNumber numberWithInt:dataIndex];
    datapoint.yValue = [NSNumber numberWithDouble:locat];
    
    return datapoint;
}

@end
