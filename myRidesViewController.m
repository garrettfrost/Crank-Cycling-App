/*
 myRidesViewController
 Shows a list of the user completed and uploaded rides
 When a user selects a ride they are taken to the ride overview section
 */

#import "myRidesViewController.h"
#import "SWRevealViewController.h"

@interface myRidesViewController ()

@end

@implementation myRidesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]];
    
    // Change button color
    self.sidebarButton.tintColor = [UIColor redColor];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self setRequestString];
    
    self.xmlString = [[NSString alloc]init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpParseObject) name:@"parseXML" object:nil];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    UIBarButtonItem *rideButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Ride"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(ridePushed)];
    self.navigationItem.rightBarButtonItem = rideButton;
    
    [self connect];
    
    self.loadIndicator.hidden = NO;
    [self.loadIndicator startAnimating];

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

-(void)setRequestString
{
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"crankAppLogin" accessGroup:nil];
    self.password = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
    self.userName = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    
    self.getRidesString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg>\n<login uName=\"";
    self.getRidesString = [self.getRidesString stringByAppendingString:self.userName];
    self.getRidesString = [self.getRidesString stringByAppendingString:@"\" pw=\""];
    self.password = [self md5:self.password];
    self.password = [self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.getRidesString = [self.getRidesString stringByAppendingString:self.password];
    self.getRidesString = [self.getRidesString stringByAppendingString:@"\"/>\n<command>getAllRides</command>\n</msg>\n||\n"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0)
        return [self.thisWeek count];
    if(section == 1)
        return [self.lastWeek count];
    else
        return [self.older count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ride_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.font = [UIFont fontWithName:@"Aero" size:18.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    self.displayRide = [[allRides alloc]init];
    
    if(indexPath.section == 0)
        self.displayRide = [self.thisWeek objectAtIndex:indexPath.row];
    else if(indexPath.section == 1)
        self.displayRide = [self.lastWeek objectAtIndex:indexPath.row];
    else
        self.displayRide = [self.older objectAtIndex:indexPath.row];
    
    
    cell.textLabel.text = self.displayRide.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *date = [dateFormatter stringFromDate:self.displayRide.sTime];
    cell.detailTextLabel.text = date;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"This Week";
    if(section == 1)
        return @"Last Week";
    else
        return @"Older";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        self.ride = [self.thisWeek objectAtIndex:indexPath.row];
    else if(indexPath.section == 1)
        self.ride = [self.lastWeek objectAtIndex:indexPath.row];
    else
        self.ride = [self.older objectAtIndex:indexPath.row];

    allRides *rideSingleton = [allRides sharedManager];
    
    rideSingleton.name = self.ride.name;
    rideSingleton.rID = self.ride.rID;
    rideSingleton.dist = self.ride.dist;
    rideSingleton.dura = self.ride.dura;
    rideSingleton.sTime = self.ride.sTime;

    [self performSegueWithIdentifier:@"ride_details_segue" sender:self];
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
    
    NSData *request = [self.getRidesString dataUsingEncoding:NSUTF8StringEncoding];
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
    [self.tableView reloadData];
    self.loadIndicator.hidden = YES;
    [self.loadIndicator stopAnimating];
}

// called when it found an element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    self.currentElementValue = [[NSMutableString alloc] init];
    if ([elementName isEqualToString:@"ride"])
    {
        self.ride = [[allRides alloc]init];
    }
    else if([elementName isEqualToString:@"rides"])
    {
        self.thisWeek = [[NSMutableArray alloc] init];
        self.lastWeek = [[NSMutableArray alloc] init];
        self.older = [[NSMutableArray alloc] init];
    }
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"result"])
    {
        if([self.currentElementValue isEqualToString:@"unsuccessful"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to retrieve rides information, do you have a network connection?"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
    
    if ([elementName isEqualToString:@"ride"])
    {
        if(self.ride.sTime)
        {
            NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate *today = [NSDate date];
            
            NSDateComponents *todaysComponents = [gregorian components:NSWeekCalendarUnit fromDate:today];
            
            NSUInteger todaysWeek = [todaysComponents week];
            
            NSDateComponents *otherComponents = [gregorian components:NSWeekCalendarUnit fromDate:self.ride.sTime];
            
            NSUInteger anotherWeek = [otherComponents week];
            
            if(todaysWeek==anotherWeek)
            {
                [self.thisWeek addObject:self.ride];
            }
            else if(todaysWeek - 1 == anotherWeek)
            {
                [self.lastWeek addObject:self.ride];
            }
            else
            {
                [self.older addObject:self.ride];
            }
        }
        else
            [self.older addObject:self.ride];
    }
    
    if ([elementName isEqualToString:@"rID"])
    {
        self.ride.rID = [self.currentElementValue intValue];
    }
    
    if ([elementName isEqualToString:@"name"])
    {
        self.ride.name = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"sTime"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.ride.sTime = [dateFormatter dateFromString:self.currentElementValue];
    }
    
    if ([elementName isEqualToString:@"dura"])
    {
        self.ride.dura = [self.currentElementValue intValue];
    }
    
    if ([elementName isEqualToString:@"dist"])
    {
        self.ride.dist = [self.currentElementValue floatValue];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
