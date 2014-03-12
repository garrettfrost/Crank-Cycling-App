/*
 newRideViewController
 Gives the user the option when starting a new ride which
 are giving it a name and selecting the ride type
 */

#import "newRideViewController.h"

@interface newRideViewController ()

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation newRideViewController

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
    
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background.jpg"]];
    
    self.menuItems = @[@"Ride Name", @"Ride Type"];
    
    [self.view addSubview:self.buttonView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.font = [UIFont fontWithName:@"Aero" size:18.0];
    if(!self.rideName && indexPath.row == 0)
        cell.detailTextLabel.text = @"";
    else if(!self.rideName && indexPath.row == 1)
        cell.detailTextLabel.text = @"";
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}

-(void)hasEnteredRideName:(NSString *)rideName
{
    NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:firstRow];
    
    self.rideName = rideName;
    self.rideName = [self.rideName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    self.rideName = [self.rideName stringByReplacingOccurrencesOfString:@"'" withString:@""];

    cell.detailTextLabel.text = self.rideName;
    [self.tableView reloadData];
}

-(void)hasChosenType:(NSString*)rideType
{
    NSIndexPath *secondRow = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:secondRow];
    
    if([rideType isEqualToString:@"ROAD"])
        cell.detailTextLabel.text = @"Road Ride";
    else
        cell.detailTextLabel.text = @"Cross Country Ride";
    
    self.rideType = rideType;
    [self.tableView reloadData];
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
    switch(indexPath.row)
    {
        case 0:
            [self performSegueWithIdentifier:@"ride_name_segue" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"ride_type_segue" sender:self];
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"coutdown_segue"])
    {
        countdownViewController *countdownView = segue.destinationViewController;
        self.rideToSend = [[ride alloc]initWith:self.rideName andType:self.rideType];
        countdownView.ride = self.rideToSend;
    }
    else
        [segue.destinationViewController setDelegate:sender];
}

- (IBAction)playButtonPressed:(id)sender
{
    if([self.rideType length] == 0 || [self.rideName length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your ride needs both a name and a type"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
        [self performSegueWithIdentifier:@"coutdown_segue" sender:self];
}
@end
