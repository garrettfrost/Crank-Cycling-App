/*
 segmentLeaderboardViewController
 This shows a table view with the selected segments leaderboard
 It also shows the users best time if applicable at the top so 
 they need not go searching for themselves in a long list
 */

#import "segmentsLeaderboardViewController.h"

@interface segmentsLeaderboardViewController ()

@end

@implementation segmentsLeaderboardViewController

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
    
    self.segment = [segment sharedManager];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else
        return [self.segment.leaderboardArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"segment_leaderboard_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont fontWithName:@"Aero" size:18.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    // Configure the cell...
    
    if(indexPath.section == 0)
    {
        cell.textLabel.text = self.segment.pRank;
        
        int hours = (int)self.segment.pTime / 3600;
        int remainder = (int)self.segment.pTime - hours * 3600;
        int mins = remainder / 60;
        remainder = remainder - mins * 60;
        int secs = remainder;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%02dh:%02dm:%02ds", hours, mins, secs];
    }
    else
    {
        leaderboardEntry *lbCell = [self.segment.leaderboardArray objectAtIndex:indexPath.row];
        lbCell.lbRank = [lbCell.lbRank stringByAppendingString:@" "];
        cell.textLabel.text = [lbCell.lbRank stringByAppendingString:lbCell.uID];
        
        int hours = (int)lbCell.lbDura / 3600;
        int remainder = (int)lbCell.lbDura - hours * 3600;
        int mins = remainder / 60;
        remainder = remainder - mins * 60;
        int secs = remainder;
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%02dh:%02dm:%02ds", hours, mins, secs];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Personal Best";
    else
        return @"Leaderboard";
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
