/*
 goalViewController
 shows the user their current and past goals. the current goal is shown by
 a progress bar while the previous goals are shown in a table view
 */

#import "goalViewController.h"
#import "SWRevealViewController.h"

@interface goalViewController ()

@end

@implementation goalViewController

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
    
    self.previousGoalsTable.delegate = self;
    self.previousGoalsTable.dataSource = self;
    self.previousGoalsTable.backgroundColor = [UIColor clearColor];
    
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
    
    self.previousGoals = [[NSMutableArray alloc]init];
    self.xmlString = [[NSString alloc]init];
    
    self.xmlParserObject.delegate = self;
    [self setRequestString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpParseObject) name:@"parseGoalXML" object:nil];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self connect];
    
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
    self.goalProgress.hidden = YES;
    self.previousGoalsTable.hidden = YES;
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
    
    self.getAchievementsString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<msg>\n<login uName=\"";
    self.getAchievementsString = [self.getAchievementsString stringByAppendingString:self.userName];
    self.getAchievementsString = [self.getAchievementsString stringByAppendingString:@"\" pw=\""];
    self.password = [self md5:self.password];
    self.password = [self.password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.getAchievementsString = [self.getAchievementsString stringByAppendingString:self.password];
    self.getAchievementsString = [self.getAchievementsString stringByAppendingString:@"\"/>\n<command>getAllAchievements</command>\n</msg>\n||\n"];
}

-(void)setUpGUI
{
    self.goalProgress.hidden = NO;
    self.previousGoalsTable.hidden = NO;
    
    if(self.goal.progress && self.goal.target)
    {
        self.goalProgress.progress = (self.currentGoal.progress/self.currentGoal.target);
        [self.goalNameLabel setTextColor:[UIColor whiteColor]];
        [self.goalNameLabel setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.goalNameLabel setText:self.currentGoal.name];
        
        [self.goalProgressLabel setTextColor:[UIColor whiteColor]];
        [self.goalProgressLabel setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.goalProgressLabel setText:[NSString stringWithFormat:@"%0.0f", self.currentGoal.progress]];
        
        [self.goalHeadingLabel setTextColor:[UIColor whiteColor]];
        [self.goalHeadingLabel setFont:[UIFont fontWithName:@"Aero" size:20.0]];
        [self.goalHeadingLabel setText:@"Goal Progress"];
    }
    else
    {
        self.goalProgress.progress = 0;
        [self.goalNameLabel setTextColor:[UIColor whiteColor]];
        [self.goalNameLabel setFont:[UIFont fontWithName:@"Aero" size:15.0]];
        [self.goalNameLabel setText:@"No goal set"];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [self.previousGoals count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Previous Goals";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"goalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.font = [UIFont fontWithName:@"Aero" size:18.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    goal *cellGoal = [self.previousGoals objectAtIndex:indexPath.row];
    cell.textLabel.text = cellGoal.name;

    return cell;
}

-(void)connect
{
    NSError *err = nil;
    if (![self.socket connectToHost:@"203.143.84.128" onPort:20100 error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        return;
    }
    
    NSData *request = [self.getAchievementsString dataUsingEncoding:NSUTF8StringEncoding];
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
        NSLog(@"Achievements request sent");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    self.readString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	self.xmlString = [self.xmlString stringByAppendingString:self.readString];
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"parseGoalXML" object:nil];
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
    [self.previousGoalsTable reloadData];
    self.loadingIndicator.hidden = YES;
    [self.loadingIndicator stopAnimating];
    [self setUpGUI];
}

// called when it found an element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    self.currentElementValue = [[NSMutableString alloc] init];
    
    if ([elementName isEqualToString:@"ucgoal"] || [elementName isEqualToString:@"cgoal"])
    {
        self.goal = [[goal alloc]init];
    }
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"result"])
    {
        if([self.currentElementValue isEqualToString:@"unsuccessful"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to retrieve goal information, do you have a network connection?"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
    ////////////////////// parse completed goals ///////////////////////////////////
    if ([elementName isEqualToString:@"cgName"])
    {
        self.goal.name = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"cgDP"])
    {
        self.goal.dp = self.currentElementValue;
    }
    
    ////////////////////// parse current goal ///////////////////////////////////
    
    if ([elementName isEqualToString:@"ucgName"])
    {
        self.goal.name = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"ucgTarg"])
    {
        self.goal.target = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"ucgProg"])
    {
        self.goal.progress = [self.currentElementValue floatValue];
    }
    if ([elementName isEqualToString:@"ucgDP"])
    {
        self.goal.dp = self.currentElementValue;
    }
    
    /////////////////////// add to the array and retain current goal //////////////////////////
    
    if ([elementName isEqualToString:@"cgoal"])
    {
        [self.previousGoals addObject:self.goal];
    }
    if ([elementName isEqualToString:@"ucgoal"])
    {
        self.currentGoal = self.goal;
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
