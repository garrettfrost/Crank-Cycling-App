/*
 ridenameViewcontroller
 allows the user to specify a name for a ride
 When entering a ride name, the user cannot input and quotation marks or apostrophes
 for the sake fo the server. The name is also limited to 50 characters and under for server side
 */

#import "rideNameViewController.h"

@interface rideNameViewController ()

@end

@implementation rideNameViewController

@synthesize delegate;

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
    self.rideName.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.rideName resignFirstResponder];
    
    NSString *rideName = [[NSString alloc]init];
    rideName = self.rideName.text;
    
    [self.delegate hasEnteredRideName:rideName];
    [self.navigationController popViewControllerAnimated:YES];
    
    return YES;
}

// handles limiting the amount of characters the user can input
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([textField.text length] <= 49)
        return YES;
    else
        return NO;
}

@end