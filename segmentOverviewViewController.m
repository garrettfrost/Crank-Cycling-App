/*
 segmentOverviewViewController
 This shows more details information on a selected segment including its length,
 its current fastest time and the users rank if they have one
 It also shows the segment route on a google map
 */

#import "segmentOverviewViewController.h"

@interface segmentOverviewViewController ()

@end

@implementation segmentOverviewViewController

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
    
    self.segment = [segment sharedManager];
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
                                   action:@selector(ride)];
    self.parentViewController.navigationItem.rightBarButtonItem = rideButton;
    self.parentViewController.navigationItem.title = @"Segments Overview";
}

-(IBAction)ride
{
    [self performSegueWithIdentifier:@"ride_segue" sender:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)setRequestString
{
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"crankAppLogin" accessGroup:nil];
    self.password = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
    self.userName = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *segID = [NSString stringWithFormat:@"%d", self.segment.sID];
    
    self.getSegmentString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg>\n<login uName=\"";
    self.getSegmentString = [self.getSegmentString stringByAppendingString:self.userName];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:@"\" pw=\""];
    self.password = [self md5:self.password];
    self.password = [self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:self.password];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:@"\"/>\n<command>getSegment</command>\n<segID>"];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:segID];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:@"</segID>\n</msg>\n||\n"];
}

-(void)setUpGUI
{
    //Get the list of paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //Get the documentsDirectory
    NSString *documentsDirectory = [paths lastObject];
    //Get the filepath
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"userSettings"];
    
    self.userSettings = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    self.segmentNameLabel.adjustsFontSizeToFitWidth = YES;
    [self.segmentNameLabel setTextColor:[UIColor whiteColor]];
    [self.segmentNameLabel setFont:[UIFont fontWithName:@"Aero" size:30.0]];
    [self.segmentNameLabel setText:self.segment.sName];
    
    [self.segmentSubtitle setTextColor:[UIColor grayColor]];
    [self.segmentSubtitle setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    [self.segmentSubtitle setText:@"Segment"];
    
    [self.distanceNumberLabel setTextColor:[UIColor whiteColor]];
    [self.distanceNumberLabel setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    
    if([self.userSettings.units isEqualToString:@"Metric"])
        [self.distanceNumberLabel setText:[NSString stringWithFormat:@"%0.2f km", self.segment.sDist]];
    else
        [self.distanceNumberLabel setText:[NSString stringWithFormat:@"%0.2f Mi", self.segment.sDist * 0.621371192]];
    
    [self.distanceSubtitle setTextColor:[UIColor grayColor]];
    [self.distanceSubtitle setFont:[UIFont fontWithName:@"Aero" size:15.0]];
    [self.distanceSubtitle setText:@"Distance"];
    
    [self.bestTimeLabel setTextColor:[UIColor whiteColor]];
    [self.bestTimeLabel setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    
    int hours = (int)self.segment.pTime / 3600;
    int remainder = (int)self.segment.pTime - hours * 3600;
    int mins = remainder / 60;
    remainder = remainder - mins * 60;
    int secs = remainder;
    
    [self.bestTimeLabel setText:[NSString stringWithFormat:@"%02dh:%02dm:%02ds", hours, mins, secs]];
    
    [self.bestTimeSubtitle setTextColor:[UIColor grayColor]];
    [self.bestTimeSubtitle setFont:[UIFont fontWithName:@"Aero" size:15.0]];
    [self.bestTimeSubtitle setText:@"Best Time"];
    
    [self.standingLabel setTextColor:[UIColor whiteColor]];
    [self.standingLabel setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    [self.standingLabel setText:self.segment.pRank];
    
    [self.standingSubtitle setTextColor:[UIColor grayColor]];
    [self.standingSubtitle setFont:[UIFont fontWithName:@"Aero" size:15.0]];
    [self.standingSubtitle setText:@"Rank"];
    
    [self putLocationsOnMap];
    
    self.loadingIndicator.hidden = YES;
    [self.loadingIndicator stopAnimating];
}

-(void)putLocationsOnMap
{
    ridePoint *startPoint, *endPoint, *newRidePoint;
    CLLocationCoordinate2D start, end;
    
    self.mapView.myLocationEnabled = YES;
    
    startPoint = [self.segment.pointsArray objectAtIndex:0];
    endPoint = [self.segment.pointsArray objectAtIndex:[self.segment.pointsArray count]-1];
    
    start.latitude = startPoint.location.latitude;
    start.longitude = startPoint.location.longitude;
    end.latitude = endPoint.location.latitude;
    end.longitude = endPoint.location.longitude;
    
    //  this makes it so that the ride is shown on the map at the highest zoom level possible
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.mapView.padding = mapInsets;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:start coordinate:end];
    GMSCameraPosition *camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsZero];
    self.mapView.camera = camera;
    
    GMSMutablePath *path = [[GMSMutablePath alloc]init];
    
    for(int i = 0; i < self.segment.pointsArray.count; i++)
    {
        newRidePoint = [self.segment.pointsArray objectAtIndex:i];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    
    NSData *request = [self.getSegmentString dataUsingEncoding:NSUTF8StringEncoding];
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
        NSLog(@"Segment request sent");
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
    
    if([elementName isEqualToString:@"seg"])
    {
        self.segment = [segment sharedManager];
        self.segment.leaderboardArray = [[NSMutableArray alloc]init];
        self.segment.pointsArray = [[NSMutableArray alloc]init];
    }
    if([elementName isEqualToString:@"pnt"])
    {
        float lat, lon;
        
        self.point = [[ridePoint alloc]init];
        lat = [[attributeDict objectForKey:@"lat"]doubleValue];
        lon = [[attributeDict objectForKey:@"lon"]doubleValue];
        
        self.point.location = CLLocationCoordinate2DMake(lat, lon);
    }
    if([elementName isEqualToString:@"lb"])
    {
        self.leaderboard = [[leaderboardEntry alloc]init];
    }
    
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // the end of each major element is handled here
    if ([elementName isEqualToString:@"result"])
    {
        if([self.currentElementValue isEqualToString:@"unsuccessful"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to retrieve segment information, do you have an network connection?"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    
    //////////////////////// parse segment data //////////////////////////
    if ([elementName isEqualToString:@"sName"])
    {
        self.segment.sName = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"sDist"])
    {
        self.segment.sDist = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"avgGrad"])
    {
        self.segment.avgGrad = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"cat"])
    {
        self.segment.cat = [self.currentElementValue intValue];
    }
    if ([elementName isEqualToString:@"hEle"])
    {
        self.segment.hEle = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"lEle"])
    {
        self.segment.lEle = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"gain"])
    {
        self.segment.gain = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"hClimb"])
    {
        self.segment.hClimb = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"type"])
    {
        self.segment.type = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"pRank"])
    {
        self.segment.pRank = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"pTime"])
    {
        self.segment.pTime = [self.currentElementValue floatValue];
    }
    
    ///////////////////// parse point data //////////////////////////
    if ([elementName isEqualToString:@"ele"])
    {
        self.point.ele = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"dist"])
    {
        self.point.dist = [self.currentElementValue floatValue];
    }
    
    //////////////////// parse leaderboard data ////////////////////
    if ([elementName isEqualToString:@"uID"])
    {
        self.leaderboard.uID = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"lbDura"])
    {
        self.leaderboard.lbDura = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"lbRank"])
    {
        self.leaderboard.lbRank = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"pnt"])
    {
        [self.segment.pointsArray addObject:self.point];
    }
    if ([elementName isEqualToString:@"lb"])
    {
        [self.segment.leaderboardArray addObject:self.leaderboard];
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
