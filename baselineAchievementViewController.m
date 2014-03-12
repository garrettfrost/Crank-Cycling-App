/*
 baselineAchievementViewController
 This shows a table view of the user's completed and incomplete baseline achievements
 When a cell is touched it shows the description of the achievement in
 an alert view for the user
 */

#import "baselineAchievementViewController.h"
#import "SWRevealViewController.h"

@interface baselineAchievementViewController ()

@end

@implementation baselineAchievementViewController

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
    
    UIImage *buttonImage = [UIImage imageNamed:@"menu.png"];
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]];
    
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
    
    self.baselineAchievements = [[NSMutableArray alloc]init];
    self.incompleteAchievs = [[NSMutableArray alloc]init];

    self.getAchievementsString = [[NSString alloc]init];
    
    self.xmlParserObject.delegate = self;

    self.xmlString = [[NSString alloc]init];
    [self setRequestString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpParseObject) name:@"parseBaselineXML" object:nil];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self connect];
    
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimating];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.baselineAchievements count];
    else
        return [self.incompleteAchievs count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Completed";
    else
        return @"Incomplete";
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"baseline_achievement_cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        cell.textLabel.font = [UIFont fontWithName:@"Aero" size:18.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        baselineAchievement *achiev = [self.baselineAchievements objectAtIndex:indexPath.row];
        cell.textLabel.text = achiev.name;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yy HH:mm:ss"];
        NSString *value = [dateFormatter stringFromDate:achiev.date];
        cell.detailTextLabel.text = value;
        cell.imageView.image = [UIImage imageNamed:[achiev.displayPic stringByAppendingString:@".png"]];
        
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"baseline_achievement_cell_incomplete";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        // Configure the cell...
        
        cell.textLabel.font = [UIFont fontWithName:@"Aero" size:18.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        baselineAchievement *achiev = [self.incompleteAchievs objectAtIndex:indexPath.row];
        cell.textLabel.text = achiev.name;
        cell.imageView.image = [UIImage imageNamed:[achiev.displayPic stringByAppendingString:@".png"]];
                                
        return cell;
    }
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
    baselineAchievement *achiev = [[baselineAchievement alloc]init];
    
    if(indexPath.section == 0)
        achiev = [self.baselineAchievements objectAtIndex:indexPath.row];
    else
        achiev = [self.incompleteAchievs objectAtIndex:indexPath.row];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:achiev.name
                                                    message:achiev.des
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    
    [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"parseBaselineXML" object:nil];
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
    self.loadingIndicator.hidden = YES;
    [self.loadingIndicator stopAnimating];
}

// called when it found an element
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    self.currentElementValue = [[NSMutableString alloc] init];
    if ([elementName isEqualToString:@"cba"] || [elementName isEqualToString:@"ucba"])
    {
        self.bAchiev = [[baselineAchievement alloc]init];
    }
}

// called when it hits the closing of the element
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"result"])
    {
        if([self.currentElementValue isEqualToString:@"unsuccessful"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to retrieve baseline achievement information, do you have a network connection?"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    
    ////////////////////// parse completed achievement date ///////////////////////////////////
    if ([elementName isEqualToString:@"cName"])
    {
        self.bAchiev.name = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"cDes"])
    {
        self.bAchiev.des = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"cDate"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        self.bAchiev.date = [dateFormatter dateFromString:self.currentElementValue];
    }
    if ([elementName isEqualToString:@"cDp"])
    {
        self.bAchiev.displayPic = self.currentElementValue;
    }
    
    ////////////////////// parse incomplete achievement date ///////////////////////////////////
    
    if ([elementName isEqualToString:@"ucName"])
    {
        self.bAchiev.name = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"ucDes"])
    {
        self.bAchiev.des = self.currentElementValue;
    }
    if ([elementName isEqualToString:@"ucDp"])
    {
        self.bAchiev.displayPic = self.currentElementValue;
    }
    
    /////////////////////// add to the arrays //////////////////////////
    
    if ([elementName isEqualToString:@"ucba"])
    {
        [self.incompleteAchievs addObject:self.bAchiev];
    }
    if ([elementName isEqualToString:@"cba"])
    {
        [self.baselineAchievements addObject:self.bAchiev];
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
