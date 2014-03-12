/*
 rideResultsviewController
 This shows all achievements, both baseline and personal of a selected ride.
 It also shows any segment that may been ridden on that ride
 */

#import "rideResultsViewController.h"

@interface rideResultsViewController ()

@end

@implementation rideResultsViewController

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
    
    self.parentViewController.navigationItem.title = @"Ride Overview";
    
    self.singleRideSingleton = [ride sharedManager];
    
    UIBarButtonItem *rideButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Ride"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(ride)];
    self.parentViewController.navigationItem.rightBarButtonItem = rideButton;
}

-(IBAction)ride
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (section == 0)
    {
        return [self.singleRideSingleton.personalAchievementsArray count];
    }
    else if(section == 1)
    {
        return [self.singleRideSingleton.baselineAchievementsArray count];
    }
    else
    {
        return [self.singleRideSingleton.segmentArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ride_results_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    if(indexPath.section == 0)
    {
        personalAchievement *pAchiev = [self.singleRideSingleton.personalAchievementsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = pAchiev.name;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yy hh:mm:ss"];
        NSString *value = [dateFormatter stringFromDate:pAchiev.time];
        cell.detailTextLabel.text = value;
        cell.imageView.image = [UIImage imageNamed:[pAchiev.dp stringByAppendingString:@".png"]];
    }
    else if(indexPath.section == 1)
    {
        baselineAchievement *bAchiev = [self.singleRideSingleton.baselineAchievementsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = bAchiev.name;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yy hh:mm:ss"];
        NSString *value = [dateFormatter stringFromDate:bAchiev.date];
        cell.detailTextLabel.text = value;
        cell.imageView.image = [UIImage imageNamed:[bAchiev.displayPic stringByAppendingString:@".png"]];
    }
    else
    {
        segment *newSeg = [self.singleRideSingleton.segmentArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = newSeg.sName;
        cell.detailTextLabel.text = newSeg.sRank;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Aero" size:18.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Personal Achievements";
    if(section == 1)
        return @"Baseline Achievements";
    else
        return @"Segments";
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
    if(indexPath.section == 0)
    {
        personalAchievement *newPersAchiev = [self.singleRideSingleton.personalAchievementsArray objectAtIndex:indexPath.row];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:newPersAchiev.name message:newPersAchiev.val delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alert show];
        
        [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    }
    else if(indexPath.section == 1)
    {
        baselineAchievement *newBaseAchiev = [self.singleRideSingleton.baselineAchievementsArray objectAtIndex:indexPath.row];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:newBaseAchiev.name message:newBaseAchiev.des delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
        [alert show];
        
        [self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    }
    else
    {
        self.segment = [self.self.singleRideSingleton.segmentArray objectAtIndex:indexPath.row];
        segment *segmentSingleton = [segment sharedManager];
        
        segmentSingleton.sID = self.segment.sID;
        segmentSingleton.sDura = self.segment.sDura;
        segmentSingleton.sName = self.segment.sName;
        segmentSingleton.sRank = self.segment.sRank;
        segmentSingleton.sDist = self.segment.sDist;
        segmentSingleton.cat = self.segment.cat;
        segmentSingleton.sTime = self.segment.sTime;
        segmentSingleton.cat = self.segment.cat;
        segmentSingleton.avgGrad = self.segment.avgGrad;
        segmentSingleton.hEle = self.segment.hEle;
        segmentSingleton.lEle = self.segment.lEle;
        segmentSingleton.gain = self.segment.gain;
        segmentSingleton.hClimb = self.segment.hClimb;
        segmentSingleton.type = self.segment.type;
        segmentSingleton.pRank = self.segment.pRank;
        segmentSingleton.pTime = self.segment.pTime;
        
        [self performSegueWithIdentifier:@"rides_overview_to_segments_segue" sender:self];
    }
}

@end
