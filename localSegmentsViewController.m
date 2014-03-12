/*
 localSegmentsViewController
 This shows the user any local segments they may be near on a google map
 It takes ther user current location, queueries the server and the server returns a list of local segments
 Due to the map taking up the entire screen, a network activity indicator has been aded to the top bar
 to show when the server is being communicated with
 */

#import "localSegmentsViewController.h"
#import "SWRevealViewController.h"

@interface localSegmentsViewController ()

@end

@implementation localSegmentsViewController

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
    
    UIImage *buttonImage = [UIImage imageNamed:@"menu.png"];
    
    // Change button color
    self.sidebarButton = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStyleBordered target:self action:nil];
    self.sidebarButton.tintColor = [UIColor redColor];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = self.sidebarButton;
    self.sidebarButton.enabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRequestString) name:@"setRequest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpParseObject) name:@"parseXML" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connect) name:@"connect" object:nil];


    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.xmlString = [[NSString alloc]init];
    self.geocoder = [[CLGeocoder alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    self.view = self.mapView;
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.userLocation = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);

    // finds the users location in lat and lon coords
    NSLog(@"Resolving the Address");
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (error == nil && [placemarks count] > 0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setRequest" object:nil];
            [self.locationManager stopUpdatingLocation];
        }
        else
        {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}

-(void)setRequestString
{
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"crankAppLogin" accessGroup:nil];
    self.password = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
    self.userName = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    
    self.getSegmentString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg>\n<login uName=\"";
    self.getSegmentString = [self.getSegmentString stringByAppendingString:self.userName];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:@"\" pw=\""];
    self.password = [self md5:self.password];
    self.password = [self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:self.password];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:@"\"/>\n<command>getLocalSegments</command>\n<pnt>\n<lat>"];
    self.getSegmentString = [self.getSegmentString stringByAppendingString:[NSString stringWithFormat:@"%f</lat>\n<long>%f</long>\n</pnt>\n</msg>\n||\n", self.userLocation.latitude, self.userLocation.longitude]];
    NSLog(@"%@", self.getSegmentString);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connect" object:nil];
}

// adds any local segment we have acquired to the map
-(void)addSegmentsToMap
{
    for(int i = 0; i < self.localSegments.count; i++)
    {
        self.seg = [[segment alloc]init];
        self.seg = [self.localSegments objectAtIndex:i];
        GMSMarker *marker = [GMSMarker markerWithPosition:self.seg.location];
        marker.title = self.seg.sName;
        marker.snippet = [NSString stringWithFormat:@"%d", self.seg.sID];
        marker.tappable = true;
        marker.map = self.mapView;
    }
}

- (void) mapView:(GMSMapView *) mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    self.seg = [segment sharedManager];
    self.seg.sID = [marker.snippet integerValue];
    [self performSegueWithIdentifier:@"local_segment_to_segment_overview_segue" sender:self];
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
        NSLog(@"Local segments request sent");
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
    [self addSegmentsToMap];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
}

// called when it found an element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    self.currentElementValue = [[NSMutableString alloc] init];
    
    if([elementName isEqualToString:@"seg"])
    {
        self.seg = [[segment alloc]init];
    }
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // the end of each major element is handled here
    if ([elementName isEqualToString:@"result"])
    {
        if([self.currentElementValue isEqualToString:@"successful"])
        {
            self.localSegments = [[NSMutableArray alloc]init];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to retrieve local segments, there aren't any here"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    if([elementName isEqualToString:@"sID"])
    {
        self.seg.sID = [self.currentElementValue integerValue];
    }
    if([elementName isEqualToString:@"name"])
    {
        self.seg.sName = self.currentElementValue;
    }
    if([elementName isEqualToString:@"lat"])
    {
        self.lat = [self.currentElementValue doubleValue];
    }
    if([elementName isEqualToString:@"lon"])
    {
        self.lon = [self.currentElementValue doubleValue];
        self.seg.location = CLLocationCoordinate2DMake(self.lat, self.lon);
    }
    if([elementName isEqualToString:@"seg"])
    {
        [self.localSegments addObject:self.seg];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
