/*
 rideOverviewViewController
 Shows more details of a selected ride including
 distance of the ride, the average speed, the date and time it was ridden
 and the route shown on a google map
 */

#import "rideOverviewViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface rideOverviewViewController ()

@end

@implementation rideOverviewViewController

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
    
    self.rideSingleton = [allRides sharedManager];
    
    self.parentViewController.navigationItem.title = @"Ride Overview";
    
    self.xmlString = [[NSString alloc]init];
    
    [self setRequestString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpParseObject) name:@"parseXML" object:nil];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self connect];
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
 
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

#pragma mark ui set up methods

-(void)setRequestString
{
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"crankAppLogin" accessGroup:nil];
    self.password = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
    self.userName = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    self.rideID = [NSString stringWithFormat:@"%d", self.rideSingleton.rID];
    
    self.getRideString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg>\n<login uName=\"";
    self.getRideString = [self.getRideString stringByAppendingString:self.userName];
    self.getRideString = [self.getRideString stringByAppendingString:@"\" pw=\""];
    self.password = [self md5:self.password];
    self.password = [self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.getRideString = [self.getRideString stringByAppendingString:self.password];
    self.getRideString = [self.getRideString stringByAppendingString:@"\"/>\n<command>getRide</command>\n<rideID>"];
    self.getRideString = [self.getRideString stringByAppendingString:self.rideID];
    self.getRideString = [self.getRideString stringByAppendingString:@"</rideID>\n</msg>\n||\n"];
}

-(void)setUpGUI
{
    NSString *value;
    
    if([self.result isEqualToString:@"successful"])
    {
        self.rideNameLabel.adjustsFontSizeToFitWidth = YES;
        [self.rideNameLabel setTextColor:[UIColor whiteColor]];
        [self.rideNameLabel setFont:[UIFont fontWithName:@"Aero" size:30.0]];
        [self.rideNameLabel setText:self.ride.name];
        
        [self.rideTypeLabel setTextColor:[UIColor whiteColor]];
        [self.rideTypeLabel setFont:[UIFont fontWithName:@"Aero" size:20.0]];
        if([self.ride.type isEqualToString:@"ROAD"])
            [self.rideTypeLabel setText:@"Road Ride"];
        else
            [self.rideTypeLabel setText:@"Cross Country Ride"];
        
        //Get the list of paths
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //Get the documentsDirectory
        NSString *documentsDirectory = [paths lastObject];
        //Get the filepath
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"userSettings"];

        self.userSettings = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        [self.distanceNumberLabel setTextColor:[UIColor whiteColor]];
        [self.distanceNumberLabel setFont:[UIFont fontWithName:@"Aero" size:20.0]];

        if([self.userSettings.units isEqualToString:@"Metric"])
            value = [NSString stringWithFormat:@"%0.2fkm", self.ride.rDist];
        else
            value = [NSString stringWithFormat:@"%.02fMi", self.ride.rDist * 0.621371192];
        [self.distanceNumberLabel setText:value];
        
        [self.averageSpeedLabel setTextColor:[UIColor whiteColor]];
        [self.averageSpeedLabel setFont:[UIFont fontWithName:@"Aero" size:20.0]];
        if([self.userSettings.units isEqualToString:@"Metric"])
            value = [NSString stringWithFormat:@"%0.2f km/h", self.ride.avgSpd];
        else
            value = [NSString stringWithFormat:@"%0.2f mph", self.ride.avgSpd * 0.621371192];
        [self.averageSpeedLabel setText:value];
        
        [self.dateAndTimeLabel setTextColor:[UIColor whiteColor]];
        [self.dateAndTimeLabel setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yy HH:mm:ss"];
        value = [dateFormatter stringFromDate:[NSDate date]];
        [self.dateAndTimeLabel setText:value];
        
        [self.rideTimeLabel setTextColor:[UIColor whiteColor]];
        [self.rideTimeLabel setFont:[UIFont fontWithName:@"Aero" size:20.0]];
        
        int hours = (int)self.ride.rDura / 3600;
        int remainder = (int)self.ride.rDura - hours * 3600;
        int mins = remainder / 60;
        remainder = remainder - mins * 60;
        int secs = remainder;
        
        value = [NSString stringWithFormat:@"%02dh:%02dm:%02ds", hours, mins, secs];
        [self.rideTimeLabel setText:value];
        
        [self.rideTimeSubtitle setTextColor:[UIColor grayColor]];
        [self.rideTimeSubtitle setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.rideTimeSubtitle setText:@"Ride Time"];
        
        [self.distanceSubtitle setTextColor:[UIColor grayColor]];
        [self.distanceSubtitle setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.distanceSubtitle setText:@"Distance"];
        
        [self.dateSubtitle setTextColor:[UIColor grayColor]];
        [self.dateSubtitle setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.dateSubtitle setText:@"Date and Time"];
        
        [self.speedSubtitle setTextColor:[UIColor grayColor]];
        [self.speedSubtitle setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.speedSubtitle setText:@"Avg Speed"];
        
        [self putLocationsOnMap];
        
        self.loadingIndicator.hidden = YES;
        [self.loadingIndicator stopAnimating];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)putLocationsOnMap
{
    ridePoint *startPoint, *newRidePoint;
    CLLocationCoordinate2D start;
    
    self.mapView.myLocationEnabled = YES;
    
    startPoint = [self.ride.pointArray objectAtIndex:0];
    
    start.latitude = startPoint.location.latitude;
    start.longitude = startPoint.location.longitude;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:start.latitude
                                                            longitude:start.longitude
                                                                 zoom:12];
    self.mapView.camera = camera;
    
    GMSMutablePath *path = [[GMSMutablePath alloc]init];
    
    for(int i = 0; i < self.ride.pointArray.count; i++)
    {
        newRidePoint = [self.ride.pointArray objectAtIndex:i];
        [path addCoordinate:newRidePoint.location];
    }
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 10.f;
    polyline.geodesic = YES;
    polyline.map = self.mapView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark networking methods

-(void)connect
{
    NSError *err = nil;
    if (![self.socket connectToHost:@"203.143.84.128" onPort:20100 error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        return;
    }
    
    NSData *request = [self.getRideString dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:request withTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Cool, I'm connected! That was easy.");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag == 0)
        NSLog(@"Ride request sent");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    self.readString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	self.xmlString = [self.xmlString stringByAppendingString:self.readString];
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"parseXML" object:nil];
}

#pragma mark NSXML methods

-(void)setUpParseObject
{
    NSData *data = [self.xmlString dataUsingEncoding:NSASCIIStringEncoding];
    self.xmlParserObject = [[NSXMLParser alloc] initWithData:data];
    [self.xmlParserObject setDelegate:self];
    [self.xmlParserObject setShouldProcessNamespaces:NO];
    [self.xmlParserObject setShouldReportNamespacePrefixes:NO];
    [self.xmlParserObject setShouldResolveExternalEntities:NO];
    
    [self.xmlParserObject parse];
    [self setUpGUI];
}

// called when it found an element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    self.currentElementValue = [[NSMutableString alloc] init];
    
    if ([elementName isEqualToString:@"ride"])
    {
        self.ride = [ride sharedManager];
        self.ride.pointArray = [[NSMutableArray alloc]init];
        self.ride.segmentArray = [[NSMutableArray alloc]init];
        self.ride.personalAchievementsArray = [[NSMutableArray alloc]init];
        self.ride.baselineAchievementsArray = [[NSMutableArray alloc]init];

    }
    else if([elementName isEqualToString:@"seg"])
    {
        self.seg = [[segment alloc]init];
    }
    else if([elementName isEqualToString:@"pa"])
    {
        self.pAchiev = [[personalAchievement alloc]init];
    }
    else if([elementName isEqualToString:@"ba"])
    {
        self.bAchiev = [[baselineAchievement alloc]init];
    }
    else if([elementName isEqualToString:@"pnt"])
    {
        float lat, lon;
        
        self.point = [[ridePoint alloc]init];
        lat = [[attributeDict objectForKey:@"lat"]doubleValue];
        lon = [[attributeDict objectForKey:@"lon"]doubleValue];
        
        self.point.location = CLLocationCoordinate2DMake(lat, lon);
    }
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"ride"])
    {
        // We reached the end of the string
        [[NSNotificationCenter defaultCenter] postNotificationName:@"xmlFinishedLoading" object:nil];
        return;
    }
    if([elementName isEqualToString:@"result"])
    {
        self.result = self.currentElementValue;
        if([self.result isEqualToString:@"unsuccessful"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't retrieve ride information, do you have a network connection?"
                                                            message: nil
                                                            delegate:self
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:@"OK",nil];
            [alert show];
        }
    }
    if ([elementName isEqualToString:@"pnt"])
    {
        // We reached the end of the point
        [self.ride.pointArray addObject:self.point];
    }
    
    if ([elementName isEqualToString:@"ba"])
    {
        // We reached the end of the achievement
        [self.ride.baselineAchievementsArray addObject:self.bAchiev];
    }
    if ([elementName isEqualToString:@"pa"])
    {
        // We reached the end of the achievement
        [self.ride.personalAchievementsArray addObject:self.pAchiev];
    }
    
    if ([elementName isEqualToString:@"seg"])
    {
        // We reached the end of the segment
        [self.ride.segmentArray addObject:self.seg];
    }
    
///////////////////////////// parse ride information //////////////////////////////////////
    
    if ([elementName isEqualToString:@"rID"])
    {
        self.ride.rID = [self.currentElementValue intValue];
    }
    
    if ([elementName isEqualToString:@"rName"])
    {
        self.ride.name = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"rTime"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.ride.rTime = [dateFormatter dateFromString:self.currentElementValue];
    }
    
    if ([elementName isEqualToString:@"rDura"])
    {
        self.ride.rDura = [self.currentElementValue intValue];
    }
    
    if ([elementName isEqualToString:@"rDist"])
    {
        self.ride.rDist = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"mTime"])
    {
        self.ride.mTime = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"avgSpd"])
    {
        self.ride.avgSpd = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"avgMoveSpd"])
    {
        self.ride.avgMoveSpeed = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"maxSpd"])
    {
        self.ride.maxSpd = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"hEle"])
    {
        self.ride.hEle = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"lEle"])
    {
        self.ride.lEle = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"gain"])
    {
        self.ride.gain = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"hClimb"])
    {
        self.ride.hClimb = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"rType"])
    {
        self.ride.type = self.currentElementValue;
    }
    
    ///////////////////////////// parse point information //////////////////////////////////////
    
    if ([elementName isEqualToString:@"cTime"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.point.cTime = [dateFormatter dateFromString:self.currentElementValue];
    }
    
    if ([elementName isEqualToString:@"ele"])
    {
        self.point.ele = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"spd"])
    {
        self.point.spd = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"dist"])
    {
        self.point.dist = [self.currentElementValue floatValue];
    }
    
    ///////////////////////////// parse segment information //////////////////////////////////////
    
    if([elementName isEqualToString:@"sName"])
    {
        self.seg.sName = self.currentElementValue;
    }
    
    if([elementName isEqualToString:@"sID"])
    {
        self.seg.sID = [self.currentElementValue intValue];
    }
    
    if ([elementName isEqualToString:@"sTime"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.seg.sTime = [dateFormatter dateFromString:self.currentElementValue];
    }
    
    if ([elementName isEqualToString:@"sDura"])
    {
        self.seg.sDura = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"sDist"])
    {
        self.seg.sDist = [self.currentElementValue floatValue];
    }
    
    if ([elementName isEqualToString:@"sRank"])
    {
        self.seg.sRank = self.currentElementValue;
    }
    
    ///////////////////////////// parse baseline achievement information //////////////////////////////////////
    
    if ([elementName isEqualToString:@"bName"])
    {
        self.bAchiev.name = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"des"])
    {
        self.bAchiev.des = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"date"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.bAchiev.date = [dateFormatter dateFromString:self.currentElementValue];
    }
    
    if ([elementName isEqualToString:@"dp"])
    {
        self.bAchiev.displayPic = self.currentElementValue;
    }
    
    ///////////////////////////// parse personal achievement information //////////////////////////////////////
    
    if ([elementName isEqualToString:@"pName"])
    {
        self.pAchiev.name = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"pdp"])
    {
        self.pAchiev.dp = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"val"])
    {
        self.pAchiev.val = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"time"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.pAchiev.time = [dateFormatter dateFromString:self.currentElementValue];
    }
    
    self.currentElementValue = nil;
}

// called when it found the characters in the data of the element
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!self.currentElementValue)
    {
        // init the ad hoc string with the value
        self.currentElementValue = [[NSMutableString alloc] init];
    }
    
    [self.currentElementValue appendString:string];
}

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
