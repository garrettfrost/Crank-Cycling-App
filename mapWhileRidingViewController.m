/*
 mapWhileridingViewController
 Displays the users current route on a goole map
 */

#import "mapWhileRidingViewController.h"

@interface mapWhileRidingViewController ()

@end

@implementation mapWhileRidingViewController

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
    
    CLLocationCoordinate2D coord;
    coord = [[self.mapLocations lastObject] coordinate];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coord.latitude
                                                            longitude:coord.longitude
                                                                 zoom:13];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    
    self.view = self.mapView;
    
    [self putLocationsOnMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)putLocationsOnMap
{
    GMSMutablePath *path = [[GMSMutablePath alloc]init];
    CLLocationCoordinate2D coord;

    for(int i = 0; i < self.mapLocations.count; i++)
    {
        coord = [[self.mapLocations objectAtIndex:i] coordinate];
        [path addCoordinate:coord];
    }
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 10.f;
    polyline.geodesic = YES;
    polyline.map = self.mapView;
}
@end
