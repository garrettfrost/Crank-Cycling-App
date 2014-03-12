/*
 MainViewController
 This is the first thing the user sees when they have logged in
 It displays their total ride time, distance and their latest achievements
 and in progress goals
 */

#import "MainViewController.h"
#import "SWRevealViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setRequestString];
    self.xmlString = [[NSString alloc]init];
    
    // Change button color
    self.sidebarButton.tintColor = [UIColor redColor];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    self.sidebarButton.target = self.revealViewController;
    self.sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"crankLogoTitlebar.png"]];
    self.progressBar.hidden = YES;
    
    self.personalAchievOne.enabled = NO;
    self.personalAchievOne.hidden = YES;
    self.personalAchievTwo.enabled = NO;
    self.personalAchievTwo.hidden = YES;
    self.personalAchievThree.enabled = NO;
    self.personalAchievThree.hidden = YES;
    
    self.baselineAchievOne.enabled = NO;
    self.baselineAchievOne.hidden = YES;
    self.baselineAchievTwo.enabled = NO;
    self.baselineAchievTwo.hidden = YES;
    self.baselineAchievThree.enabled = NO;
    self.baselineAchievThree.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpParseObject) name:@"parseXML" object:nil];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self connect];
    self.loginActivityIndicator.hidden = NO;
    [self.loginActivityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

// sets up the tcp request string
-(void)setRequestString
{
    self.keychainItem = [[KeychainItemWrapper alloc]initWithIdentifier:@"crankAppLogin" accessGroup:nil];
    self.pWord = [self.keychainItem objectForKey:(__bridge id)(kSecValueData)];
    self.uName = [self.keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    self.getHomeString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg>\n<login uName=\"";
    self.getHomeString = [self.getHomeString stringByAppendingString:self.uName];
    self.getHomeString = [self.getHomeString stringByAppendingString:@"\" pw=\""];
    self.pWord = [self md5:self.pWord];
    self.pWord = [self.pWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.getHomeString = [self.getHomeString stringByAppendingString:self.pWord];
    self.getHomeString = [self.getHomeString stringByAppendingString:@"\"/>\n<command>getHomeScreen</command>\n</msg>\n||\n"];
}

// sets up the interface after all the data has been received and parsed
-(void)setUpGUI
{
    //Get the list of paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //Get the documentsDirectory
    NSString *documentsDirectory = [paths lastObject];
    //Get the filepath
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"userSettings"];
    
    self.userSettings = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    // set font colours for all labels here
    self.textColour = [UIColor whiteColor];
    self.greyTextColour = [UIColor grayColor];
    
    //set labels here
    self.userName.adjustsFontSizeToFitWidth = YES;
    [self.userName setTextColor:self.textColour];
    [self.userName setFont:[UIFont fontWithName:@"Aero" size:30.0]];
    NSString *name = self.firstName;
    name = [name stringByAppendingString:@" "];
    name = [name stringByAppendingString:self.lastName];
    [self.userName setText:name];
    
    [self.distanceNum setTextColor:self.textColour];
    [self.distanceNum setFont:[UIFont fontWithName:@"Aero" size:17.0]];
    
    if([self.userSettings.units isEqualToString:@"Metric"])
        [self.distanceNum setText:[NSString stringWithFormat:@"%.02f km", self.dist]];
    else
        [self.distanceNum setText:[NSString stringWithFormat:@"%.02f Mi", self.dist * 0.621371192]];
    
    [self.distanceLabel setTextColor:self.greyTextColour];
    [self.distanceLabel setFont:[UIFont fontWithName:@"Aero" size:12.0]];
    [self.distanceLabel setText:@"Total Distance"];
    
    // conversion from seconds, to hours, minutes and seconds
    int hours = (int)self.rt / 3600;
    int remainder = (int)self.self.rt - hours * 3600;
    int mins = remainder / 60;
    remainder = remainder - mins * 60;
    int secs = remainder;
    
    [self.totalRideTime setTextColor:self.textColour];
    [self.totalRideTime setFont:[UIFont fontWithName:@"Aero" size:18.0]];
    [self.totalRideTime setText:[NSString stringWithFormat:@"%02dh:%02dm:%02ds", hours, mins, secs]];
    
    [self.rideTimeLabel setTextColor:self.greyTextColour];
    [self.rideTimeLabel setFont:[UIFont fontWithName:@"Aero" size:12.0]];
    [self.rideTimeLabel setText:@"Total Ride Time"];
    
    [self.personalAchievments setTextColor:self.greyTextColour];
    [self.personalAchievments setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    [self.personalAchievments setText:@"Personal Achievments"];
    
    [self.baselineAchievments setTextColor:self.greyTextColour];
    [self.baselineAchievments setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    [self.baselineAchievments setText:@"Baseline Achievments"];
    
    [self.goalProgress setTextColor:self.textColour];
    [self.goalProgress setFont:[UIFont fontWithName:@"Aero" size:20.0]];
    [self.goalProgress setText:@"Goal Progress"];
    

    // we wont always have 3 achievements to set here so we check to see how many there are and set the images accordingly
    if([self.personalAchievements count] >= 3)
    {
        self.personalAchiev = [self.personalAchievements objectAtIndex:0];
        [self.personalAchievOne setBackgroundImage:[UIImage imageNamed:[self.personalAchiev.dp stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.personalAchiev = [self.personalAchievements objectAtIndex:1];
        [self.personalAchievTwo setBackgroundImage:[UIImage imageNamed:[self.personalAchiev.dp stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.personalAchiev = [self.personalAchievements objectAtIndex:2];
        [self.personalAchievThree setBackgroundImage:[UIImage imageNamed:[self.personalAchiev.dp stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.personalAchievOne.enabled = YES;
        self.personalAchievOne.hidden = NO;
        self.personalAchievTwo.enabled = YES;
        self.personalAchievTwo.hidden = NO;
        self.personalAchievThree.enabled = YES;
        self.personalAchievThree.hidden = NO;
    }
    else if([self.personalAchievements count] == 2)
    {
        self.personalAchiev = [self.personalAchievements objectAtIndex:0];
        [self.personalAchievOne setBackgroundImage:[UIImage imageNamed:[self.personalAchiev.dp stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.personalAchiev = [self.personalAchievements objectAtIndex:1];
        [self.personalAchievTwo setBackgroundImage:[UIImage imageNamed:[self.personalAchiev.dp stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.personalAchievOne.enabled = YES;
        self.personalAchievOne.hidden = NO;
        self.personalAchievTwo.enabled = YES;
        self.personalAchievTwo.hidden = NO;
        self.personalAchievThree.enabled = NO;
        self.personalAchievThree.hidden = YES;
    }
    else if([self.personalAchievements count] == 1)
    {
        self.personalAchiev = [self.personalAchievements objectAtIndex:0];
        [self.personalAchievOne setBackgroundImage:[UIImage imageNamed:[self.personalAchiev.dp stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.personalAchievOne.enabled = YES;
        self.personalAchievOne.hidden = NO;
        self.personalAchievTwo.enabled = NO;
        self.personalAchievTwo.hidden = YES;
        self.personalAchievThree.enabled = NO;
        self.personalAchievThree.hidden = YES;
    }

    if([self.baselineAchievements count] >= 3)
    {
        self.baselineAchiev = [self.baselineAchievements objectAtIndex:0];
        [self.baselineAchievOne setBackgroundImage:[UIImage imageNamed:[self.baselineAchiev.displayPic stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.baselineAchiev = [self.baselineAchievements objectAtIndex:1];
        [self.baselineAchievTwo setBackgroundImage:[UIImage imageNamed:[self.baselineAchiev.displayPic stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.baselineAchiev = [self.baselineAchievements objectAtIndex:2];
        [self.baselineAchievThree setBackgroundImage:[UIImage imageNamed:[self.baselineAchiev.displayPic stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.baselineAchievOne.enabled = YES;
        self.baselineAchievOne.hidden = NO;
        self.baselineAchievTwo.enabled = YES;
        self.baselineAchievTwo.hidden = NO;
        self.baselineAchievThree.enabled = YES;
        self.baselineAchievThree.hidden = NO;
    }
    else if([self.baselineAchievements count] == 2)
    {
        self.baselineAchiev = [self.baselineAchievements objectAtIndex:0];
        [self.baselineAchievOne setBackgroundImage:[UIImage imageNamed:[self.baselineAchiev.displayPic stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.baselineAchiev = [self.baselineAchievements objectAtIndex:1];
        [self.baselineAchievTwo setBackgroundImage:[UIImage imageNamed:[self.baselineAchiev.displayPic stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.baselineAchievOne.enabled = YES;
        self.baselineAchievOne.hidden = NO;
        self.baselineAchievTwo.enabled = YES;
        self.baselineAchievTwo.hidden = NO;
        self.baselineAchievThree.enabled = NO;
        self.baselineAchievThree.hidden = YES;
    }
    else if([self.baselineAchievements count] == 1)
    {
        self.baselineAchiev = [self.baselineAchievements objectAtIndex:0];
        [self.baselineAchievOne setBackgroundImage:[UIImage imageNamed:[self.baselineAchiev.displayPic stringByAppendingString:@".png"]] forState:UIControlStateNormal];
        
        self.baselineAchievOne.enabled = YES;
        self.baselineAchievOne.hidden = NO;
        self.baselineAchievTwo.enabled = NO;
        self.baselineAchievTwo.hidden = YES;
        self.baselineAchievThree.enabled = NO;
        self.baselineAchievThree.hidden = YES;
    }
    
    // set progress bar here
    self.progressBar.hidden = NO;
    if(self.goal.progress && self.goal.target)
    {
        [self.goalName setTextColor:self.textColour];
        [self.goalName setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.goalName setText:self.goal.name];
        
        [self.goalAmount setTextColor:self.textColour];
        [self.goalAmount setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.goalAmount setText:[NSString stringWithFormat:@"%.00f", self.goal.progress]];
        self.progressBar.progress = (self.goal.progress/self.goal.target);
    }
    else
    {
        self.progressBar.progress = 0;
        [self.goalName setTextColor:self.textColour];
        [self.goalName setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.goalName setText:@"No goal set"];
    }
    
    self.loginActivityIndicator.hidden = YES;
    [self.loginActivityIndicator stopAnimating];
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
    
    NSData *request = [self.getHomeString dataUsingEncoding:NSUTF8StringEncoding];
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
        NSLog(@"Home screen request sent");
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
    if ([elementName isEqualToString:@"fName"])
    {
        self.firstName = [[NSString alloc]init];
    }
    if ([elementName isEqualToString:@"lName"])
    {
        self.lastName = [[NSString alloc]init];
    }
    if ([elementName isEqualToString:@"goal"])
    {
        self.goal = [[goal alloc]init];
    }
    if ([elementName isEqualToString:@"pa"])
    {
        self.personalAchiev = [[personalAchievement alloc]init];
    }
    if ([elementName isEqualToString:@"ba"])
    {
        self.baselineAchiev = [[baselineAchievement alloc]init];
    }
    if ([elementName isEqualToString:@"pas"])
    {
        self.personalAchievements = [[NSMutableArray alloc]init];
    }
    if ([elementName isEqualToString:@"bas"])
    {
        self.baselineAchievements = [[NSMutableArray alloc]init];
    }
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"result"])
    {
        if([self.currentElementValue isEqualToString:@"unsuccessful"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Unable to retrieve home screen information"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
    ///////////////////////////// parse user information ////////////////////////////////////////////
    if ([elementName isEqualToString:@"fName"])
    {
        self.firstName = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"lName"])
    {
        self.lastName = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"dist"])
    {
        self.dist = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"rt"])
    {
        self.rt = [self.currentElementValue floatValue];
    }
    
    ///////////////////////////// parse personal achievements information ////////////////////////////////////////////

    if ([elementName isEqualToString:@"pName"])
    {
        self.personalAchiev.name = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"pdp"])
    {
        self.personalAchiev.dp = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"val"])
    {
        self.personalAchiev.val = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"time"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.personalAchiev.time = [dateFormatter dateFromString:self.currentElementValue];
    }
    
    ///////////////////////////// parse baseline achievements information ////////////////////////////////////////////

    if ([elementName isEqualToString:@"bName"])
    {
        self.baselineAchiev.name = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"des"])
    {
        self.baselineAchiev.des = self.currentElementValue;
    }
    
    if ([elementName isEqualToString:@"date"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.baselineAchiev.date = [dateFormatter dateFromString:self.currentElementValue];
    }
    
    if ([elementName isEqualToString:@"dp"])
    {
        self.baselineAchiev.displayPic = self.currentElementValue;
    }
    
    ///////////////////////////// parse goal information ////////////////////////////////////////////

    if ([elementName isEqualToString:@"gName"])
    {
        self.goal.name = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"gTarg"])
    {
        self.goal.target = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"gProg"])
    {
        self.goal.progress = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"gDP"])
    {
        self.goal.dp = self.currentElementValue;
    }
    
    ///////////////////////////// add achievements to the arrays ////////////////////////////////////////////
    
    if ([elementName isEqualToString:@"pa"])
    {
        [self.personalAchievements addObject:self.personalAchiev];
    }
    if ([elementName isEqualToString:@"ba"])
    {
        [self.baselineAchievements addObject:self.baselineAchiev];
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

// creates and alert view based on what the user has selected
- (IBAction)achievmentPressed:(id)sender
{
    NSString *name, *desc;
    personalAchievement *pers;
    baselineAchievement *base;
    
    if([sender tag] == 0)
    {
        pers = [self.personalAchievements objectAtIndex:0];
        name = pers.name;
        desc = pers.val;
    }
    if([sender tag] == 1)
    {
        pers = [self.personalAchievements objectAtIndex:1];
        name = pers.name;
        desc = pers.val;
    }
    if([sender tag] == 2)
    {
        pers = [self.personalAchievements objectAtIndex:2];
        name = pers.name;
        desc = pers.val;
    }
    if([sender tag] == 3)
    {
        base = [self.baselineAchievements objectAtIndex:0];
        name = base.name;
        desc = base.des;
    }
    if([sender tag] == 4)
    {
        base = [self.baselineAchievements objectAtIndex:1];
        name = base.name;
        desc = base.des;
    }
    if([sender tag] == 5)
    {
        base = [self.baselineAchievements objectAtIndex:2];
        name = base.name;
        desc = base.des;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:name
                                                    message:desc
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
}
@end
