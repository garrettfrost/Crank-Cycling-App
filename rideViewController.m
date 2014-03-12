/*
 RideViewController
 This handles the user undertaking a ride
 It tracks their location, average speed, total distance
 and the actual route they have been travelling. Handles pausing and unpausing of rides
 When the user chooses to save a ride it creates a tcp socket connection and attempts to upload it
 It will save the ride to local storage and alert the user if unsuccessful
 */

#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "rideViewController.h"

@interface rideViewController ()

@end

@implementation rideViewController

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
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
        
    // set label properties
    
    [self.distanceSubtitle setTextColor:[UIColor grayColor]];
    [self.distanceSubtitle setFont:[UIFont fontWithName:@"Aero" size:18.0]];
    [self.distanceSubtitle setText:@"Distance"];
    self.distanceSubtitle.textAlignment = NSTextAlignmentCenter;
    
    [self.timeNumber setTextColor:[UIColor whiteColor]];
    [self.timeNumber setFont:[UIFont fontWithName:@"Aero" size:18.0]];
    self.timeNumber.textAlignment = NSTextAlignmentCenter;

    [self.timeSubtitle setTextColor:[UIColor grayColor]];
    [self.timeSubtitle setFont:[UIFont fontWithName:@"Aero" size:18.0]];
    [self.timeSubtitle setText:@"Time"];
    self.timeSubtitle.textAlignment = NSTextAlignmentCenter;
    
    [self.averageSpeedNumber setTextColor:[UIColor whiteColor]];
    [self.averageSpeedNumber setFont:[UIFont fontWithName:@"Aero" size:18.0]];
    self.averageSpeedNumber.textAlignment = NSTextAlignmentCenter;
    
    [self.averageSpeedSubtitle setTextColor:[UIColor grayColor]];
    [self.averageSpeedSubtitle setFont:[UIFont fontWithName:@"Aero" size:18.0]];
    [self.averageSpeedSubtitle setText:@"Avg. Speed"];
    self.averageSpeedSubtitle.textAlignment = NSTextAlignmentCenter;
    
    [self.distanceNumber setTextColor:[UIColor whiteColor]];
    [self.distanceNumber setFont:[UIFont fontWithName:@"Aero" size:35.0]];
    self.distanceNumber.textAlignment = NSTextAlignmentCenter;
    
    // Create the stop watch timer that fires every 100 ms
    self.startDate = [NSDate date];
    self.startTime = [NSDate date];
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                           target:self
                                                         selector:@selector(updateTimer)
                                                         userInfo:nil
                                                          repeats:YES];
    
    self.rideName = self.ride.name;
    self.rideType = self.ride.type;
    self.distance = 0;
    self.ride = [[ride alloc]init];
    
    self.timePassed = 0;
    self.shouldBeUpdating = YES;
    self.messages = [[NSMutableArray alloc]init];
    
    self.numSeconds = 0;
    self.locations = [[NSMutableArray alloc]init];
    self.pointString = [[NSString alloc]init];
    
    self.xmlString = [[NSString alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpParseObject) name:@"parseXML" object:nil];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self.pauseButton addTarget:self action:@selector(displayActionSheet:) forControlEvents:UIControlEventTouchUpInside];
    
    // lets the user know they have a ride going if they go back to the springboard
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //Get the documentsDirectory
    NSString *documentsDirectory = [paths lastObject];
    //Get the filepath
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"userSettings"];
    self.userSettings = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    self.locations = [[NSMutableArray alloc]init];
    
    [self startStandardUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pauseButtonPressed:(id)sender
{
    self.pausedDate = [NSDate date];
    self.pauseInterval = [self.pausedDate timeIntervalSinceDate:self.startDate];
    [self.stopWatchTimer invalidate];
    self.stopWatchTimer = nil;
    self.shouldBeUpdating = NO;
    [self.locationManager stopUpdatingLocation];
}

#pragma mark timer methods
// a timer to show how long the user has been on the current ride
- (void)updateTimer
{
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:self.startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    self.timeNumber.text = timeString;
    self.numSeconds++;
}

#pragma mark location manager delegate methods

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager)
        self.locationManager = [[CLLocationManager alloc] init];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 5; // meters
    
    [self.locationManager startUpdatingLocation];
}

// gets the location of the user and performs appropriate actions with this data
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // makes sure we don't get data from a previous trip and add it in to this one as CLLocation caches data from previous trip
    if(oldLocation == nil)
        return;
    
    // checks to see if the ride is paused, if it is it wont add anything to the rides pints array
    if(self.shouldBeUpdating)
    {
        CLLocationDistance meters = [newLocation distanceFromLocation:oldLocation];
        
        self.totalDistance += meters;
        if([self.userSettings.units isEqualToString:@"Metric"])
        {
            if(self.totalDistance > 0)
                self.distance = [NSString stringWithFormat:@"%.2f km", (self.totalDistance / 1000)];
            else
                self.distance = [NSString stringWithFormat:@"%.2f km", 0.00];
        }
        else
        {
            if(self.totalDistance > 0)
                self.distance = [NSString stringWithFormat:@"%.2f Mi", (self.totalDistance / 1000) * 0.621371192];
            else
                self.distance = [NSString stringWithFormat:@"%.2f Mi", 0.00];
        }
        
        self.distanceNumber.text = self.distance;
        self.ride.distance = self.totalDistance;
        
        self.avgSpeedValue = (((self.ride.distance / (self.numSeconds / 10)) * 60 * 60) / 1000);
        
        if([self.userSettings.units isEqualToString:@"Metric"])
        {
            if(self.avgSpeedValue > 0)
                self.avgSpeed = [NSString stringWithFormat:@"%.2f", self.avgSpeedValue];
            else
                self.avgSpeed = [NSString stringWithFormat:@"%.2f", 0.00];

            self.avgSpeed = [self.avgSpeed stringByAppendingString:@" km/h"];
            self.averageSpeedNumber.text = self.avgSpeed;
        }
        else
        {
            if(self.avgSpeedValue > 0)
                self.avgSpeed = [NSString stringWithFormat:@"%.2f", self.avgSpeedValue *  0.621371192];
            else
                self.avgSpeed = [NSString stringWithFormat:@"%.2f", 0.00];

            self.avgSpeed = [self.avgSpeed stringByAppendingString:@" mph"];
            self.averageSpeedNumber.text = self.avgSpeed;
        }
        
        [self.locations addObject:newLocation];
        
        
        // create the point string as we go, as processing a lot of points at once
        // can hang the ui on GPX file creation
        self.pointString = [self.pointString stringByAppendingString:[NSString stringWithFormat:@"<trkpt lat=\"%f\" lon=\"%f\">\n<ele>%f</ele>\n<time>", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.altitude]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        NSString *pointTimeString = [formatter stringFromDate:newLocation.timestamp];
        
        self.pointString = [self.pointString stringByAppendingString:[NSString stringWithFormat:@"%@</time>\n</trkpt>\n", pointTimeString]];
    }
}

// creates an action sheet with options for the user
#pragma mark Action sheet methods
- (IBAction)displayActionSheet:(id)sender
{
    NSString *actionSheetTitle = @"Ride Paused"; //Action Sheet Title
    NSString *saveTitle = @"Save Ride";
    NSString *cancelTitle = @"Resume Ride";
    NSString *destructiveTitle = @"Discard Ride";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                   initWithTitle:actionSheetTitle
                   delegate:self
                   cancelButtonTitle:cancelTitle
                   destructiveButtonTitle:destructiveTitle
                   otherButtonTitles:saveTitle, nil];
    [actionSheet showInView:self.view];
}

// handles the action sheet options appropriately
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Resume Ride"])
    {
        NSDate *dateNow = [NSDate date];
        self.startDate = [NSDate dateWithTimeInterval:-self.pauseInterval sinceDate:dateNow];
        self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                               target:self
                                                             selector:@selector(updateTimer)
                                                             userInfo:nil
                                                              repeats:YES];
        
        [self.locationManager startUpdatingLocation];
        self.shouldBeUpdating = true;

        NSLog(@"Resume Ride Pressed");
    }
    if ([buttonTitle isEqualToString:@"Save Ride"])
    {
        NSLog(@"Save Ride Pressed");
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [self.stopWatchTimer invalidate];
        self.stopWatchTimer = nil;
        self.shouldBeUpdating = NO;
        [self.locationManager stopUpdatingLocation];
        [self createGPX];
        [self.uploadingIndicator startAnimating];
        [self connect];
    }
    if ([buttonTitle isEqualToString:@"Discard Ride"])
    {
        [self.stopWatchTimer invalidate];
        self.stopWatchTimer = nil;
        self.shouldBeUpdating = NO;
        [self.locationManager stopUpdatingLocation];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        NSLog(@"Discard Ride Pressed");
        bool found = false;
        // takes us to the home screen
        NSArray *viewsArray = [self.navigationController viewControllers];
        for(int i = 0; i < viewsArray.count; i++)
        {
            UIViewController *chosenView = [viewsArray objectAtIndex:i];
            if([chosenView isKindOfClass:[MainViewController class]])
            {
                found = true;
                [self.navigationController popToViewController:chosenView animated:YES];
            }
        }
        if(!found)
            [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

// invokes the camera when the user has selected the camera button
#pragma mark Camera methods
- (IBAction)showCamera:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    else
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.imageView setImage:image];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"map_while_riding_segue"])
    {
        UINavigationController *nav = segue.destinationViewController;
        mapWhileRidingViewController *mapView = (mapWhileRidingViewController*)nav.topViewController;
        mapView.mapLocations = self.locations;
    }
}

#pragma mark GPX file creation methods

// creates the GPX file for uploading
- (void)createGPX
{
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"crankAppLogin" accessGroup:nil];
    self.password = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
    self.userName = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    
    self.gpx = [[NSString alloc]init];
    
    self.gpx = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg>\n<login uName=\"";
    self.gpx = [self.gpx stringByAppendingString:self.userName];
    self.gpx = [self.gpx stringByAppendingString:@"\" pw=\""];
    self.password = [self md5:self.password];
    self.password = [self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.gpx = [self.gpx stringByAppendingString:self.password];
    self.gpx = [self.gpx stringByAppendingString:@"\"/>\n<command>uploadRide</command>\n<rType>"];
    self.gpx = [self.gpx stringByAppendingString:self.rideType];
    self.gpx = [self.gpx stringByAppendingString:@"</rType>\n<metadata>\n<time>"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:self.startTime];
    
    self.gpx = [self.gpx stringByAppendingString:stringFromDate];
    self.gpx = [self.gpx stringByAppendingString:[NSString stringWithFormat:@"</time>\n</metadata>\n<trk>\n<name>%@</name>\n<trkseg>\n", self.rideName]];
    
    // append the string of points we created while the ride was happening
    self.gpx = [self.gpx stringByAppendingString:self.pointString];
    
    self.gpx = [self.gpx stringByAppendingString:@"</trkseg>\n</trk>\n</msg>\n||\n||\n"];
    self.gpx = [self.gpx stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma password encoding method

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
    
    NSData *request = [self.gpx dataUsingEncoding:NSUTF8StringEncoding];

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
        NSLog(@"Ride Upload request sent");
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
    // check to see if the XML string is empty, if it is we weren't able to connect and will save the ride to the database for later upload
    if(![self.xmlString isEqualToString:@""])
    {
        NSData *data = [self.xmlString dataUsingEncoding:NSASCIIStringEncoding];
        self.xmlParserObject = [[NSXMLParser alloc] initWithData:data];
        [self.xmlParserObject setDelegate:self];
        [self.xmlParserObject setShouldProcessNamespaces:NO];
        [self.xmlParserObject setShouldReportNamespacePrefixes:NO];
        [self.xmlParserObject setShouldResolveExternalEntities:NO];
        [self.xmlParserObject parse];
        [self.uploadingIndicator startAnimating];
    }
    else
    {
        [self.uploadingIndicator startAnimating];
        [self saveRideAndAlert];
    }
}

// called when it found an element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    self.currentElementValue = [[NSMutableString alloc] init];
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // checks to see if the upload was successful or not, if not we save the ride for later upload and let the user know
    if([elementName isEqualToString:@"result"])
    {
        if([self.currentElementValue isEqualToString:@"successful"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Well done!"
                                                            message:@"Your ride has been uploaded"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            
            // checks for the home screen and segues back to it, it's done like this as the home screens
            // location in the stack can change after browing through the app
            // if no home screen we have come from another view and pop to the root
            NSArray *viewsArray = [self.navigationController viewControllers];
            bool found = false;
            for(int i = 0; i < viewsArray.count; i++)
            {
                UIViewController *chosenView = [viewsArray objectAtIndex:i];
                if([chosenView isKindOfClass:[MainViewController class]])
                {
                    found = true;
                    [self.navigationController popToViewController:chosenView animated:YES];
                }
            }
            if(!found)
                [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
            [self saveRideAndAlert];
        
        return;
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

// saves the ride and alerts the user that it is available to upload from the settings menu
-(void)saveRideAndAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to upload ride, your ride is saved and can be uploaded in the settings menu."
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    
    // this will save the file and allow us to upload it later if need be, we store the user name in case w ehave multiple users
    GPXFile *fileToSave = [GPXFile MR_createEntity];
    fileToSave.gpxString = self.gpx;
    fileToSave.userName = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    // checks for the home screen and segues back to it, it's done like this as the home screens
    // location in the stack can change after browsing through the app
    NSArray *viewsArray = [self.navigationController viewControllers];
    for(int i = 0; i < viewsArray.count; i++)
    {
        UIViewController *chosenView = [viewsArray objectAtIndex:i];
        if([chosenView isKindOfClass:[MainViewController class]])
            [self.navigationController popToViewController:chosenView animated:YES];
    }
}

@end
