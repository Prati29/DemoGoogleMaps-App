//
//  ViewController.m
//  LocationOnMap
//
//  Created by Admin on 27/01/16.
//  Copyright © 2016 ITC. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CLLocation.h>
#import "ViewController.h"
#import "DirectionsListVC.h"

@interface ViewController ()<GMSMapViewDelegate>
{
    bool firstLocationUpdate_;
}
@property(retain, nonatomic) NSSet *markerSet;
@property(strong, nonatomic) NSURLSession *markerSession;
@property CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *steps;
@end

@implementation ViewController

GMSMapView *mapView_;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    firstLocationUpdate_ = NO;
    [self.view layoutIfNeeded];
    self.steps = [[NSArray alloc]init];
    
    //set camera position
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.545651 longitude:-81.35699999999 zoom:14 bearing:0 viewingAngle:0];
    mapView_ = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    
    self.view = mapView_;
    mapView_.delegate = self;
    mapView_.mapType = kGMSTypeNormal;
    mapView_.myLocationEnabled = YES;
    
    //enable compass button and user location button
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self setUpMakerData];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity : 2 * 1024 * 1024 diskCapacity :10 * 1024 * 1024 diskPath:@"MarkerData"];
    
    self.markerSession = [NSURLSession sharedSession];
    //_defaultSession = [NSURLSession sharedSession];
    
    // load markers on click
    UIButton *loadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loadButton addTarget:self action:@selector(loadMarkers:) forControlEvents:UIControlEventTouchUpInside];
    [loadButton setTitle:@"Load" forState:UIControlStateNormal];
    [loadButton setBackgroundColor:[UIColor blueColor]];
    [loadButton setTintColor:[UIColor blackColor]];
    loadButton.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [self.view addSubview:loadButton];
    
    //show directions data on click
    UIButton *directionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [directionButton addTarget:self action:@selector(directionTapped:) forControlEvents:UIControlEventTouchUpInside];
    [directionButton setTitle:@"Direction" forState:UIControlStateNormal];
    [directionButton setBackgroundColor:[UIColor blueColor]];
    [directionButton setTintColor:[UIColor blackColor]];
    directionButton.frame = CGRectMake(150.0, 400.0, 160.0, 40.0);
    [self.view addSubview:directionButton];
    
    //to show user loaction
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestAlwaysAuthorization];



    NSLog(@"Location : %@",_locationManager.location);
    
}


-(IBAction)loadMarkers:(id)sender{
    [self downloadMarkerData:self];
}
-(IBAction)directionTapped:(id)sender{
    
    DirectionsListVC *directionsVC = [[DirectionsListVC alloc]init];
    directionsVC.steps = self.steps;
    [self presentViewController:directionsVC animated:YES completion:^{
        self.steps = nil;
        mapView_.selectedMarker = nil;
    }];
    
}

-(void)viewWillLayoutSubviews{
    mapView_.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 5, 0, self.bottomLayoutGuide.length + 5, 0);
}
-(void)setUpMakerData{
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(18.5203, 73.8567);
    marker.title = @"Pune";
    marker.snippet = @"Maharashtra";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.map = nil;
    
    GMSMarker *marker1 = [[GMSMarker alloc] init];
    marker1.position = CLLocationCoordinate2DMake(18.9750, 72.8258);
    marker1.title = @"Navi Mumbai";
    marker1.snippet = @"Maharashtra";
    marker1.appearAnimation = kGMSMarkerAnimationPop;
    marker1.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
    marker1.map = nil;
    
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = CLLocationCoordinate2DMake(21.1500, 79.0900);
    marker2.title = @"Nagpur";
    marker2.snippet = @"Maharashtra";
    marker2.appearAnimation = kGMSMarkerAnimationPop;
    marker2.icon = [GMSMarker markerImageWithColor:[UIColor cyanColor]];
    marker2.map = nil;
    
    GMSMarker *marker3 = [[GMSMarker alloc] init];
    marker3.position = CLLocationCoordinate2DMake(16.5083, 80.6417);
    marker3.title = @"Vijaywada";
    marker3.snippet = @"Andhra Pradesh";
    marker3.appearAnimation = kGMSMarkerAnimationPop;
    marker3.icon = [GMSMarker markerImageWithColor:[UIColor orangeColor]];
    marker3.map = nil;
    
    self.markerSet = [NSSet setWithObjects:marker, marker1, marker2, marker3, nil];
    [self drawMarkers];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)drawMarkers{
    for(GMSMarker *marker in self.markerSet){
        if(marker.map == nil){
            marker.map = mapView_;
        }
    }
}


-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    
    NSString *message = [NSString stringWithFormat:@"You tapped the info window for the %@ marker",marker.title];
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Infowindow Tapped"
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert ];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

//long press and add marker
-(void)mapView: (GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    GMSGeocoder *geoCoder = [GMSGeocoder geocoder];
    [geoCoder reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
       
        GMSMarker *marker1 = [[GMSMarker alloc] init];
        marker1.position = coordinate;
        marker1.title = response.firstResult.thoroughfare;
        marker1.snippet = response.firstResult.locality;
        marker1.appearAnimation = kGMSMarkerAnimationPop;
        marker1.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
        marker1.map = mapView;
        NSLog(@"title : %@ Snippet : %@",marker1.title, marker1.snippet);
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    NSLog(@"Latitude :  %f", newLocation.coordinate.latitude);
    NSLog(@"Longitude :  %f", newLocation.coordinate.longitude);
    
    [_locationManager stopUpdatingLocation];
}

-(BOOL)mapView: (GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    if(mapView.myLocation != nil){
        NSLog(@"using LocationManager:current location latitude = %f, longtitude = %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
        
        NSString *urlString = [NSString stringWithFormat:@"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",@"https://maps.googleapis.com/maps/api/directions/json", mapView.myLocation.coordinate.latitude, mapView.myLocation.coordinate.longitude,  marker.position.latitude, marker.position.longitude, @"AIzaSyCHeC5kpCfnTERwPkxbXYcMcpuzvBylKYY"];
        
        NSURL *directionURL = [NSURL URLWithString:urlString];
        NSURLSessionDataTask *directionsTask = [self.markerSession dataTaskWithURL:directionURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *e) {
            dispatch_sync(dispatch_get_main_queue(), ^{
               
                NSError *error = nil;
               
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSLog(@"Data : %@",data);
                
                if(!e){
                    self.steps = json[@"routes"][0][@"legs"][0][@"steps"];
                   NSLog(@"Json Steps : %@",self.steps);
                }
              
            });
        }];

        [directionsTask resume];
        NSLog(@"Steps : %@",self.steps);
    }
        return NO;
}
//Browser Key == AIzaSyCHeC5kpCfnTERwPkxbXYcMcpuzvBylKYY
// Wait for location callbacks
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
   
}

-(void)downloadMarkerData : (id)sender{

    NSString* path  = [[NSBundle mainBundle] pathForResource:@"lakes" ofType:@"json"];
    NSString* jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *jsonError;
    NSArray *allKeys = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError];

        NSLog(@"data ---- %@",allKeys);
    
    [self createMarkerObjectWithJson:allKeys];
}

-(void)createMarkerObjectWithJson :(NSArray *)json{
    NSMutableSet *mutableSet = [[NSMutableSet alloc]initWithSet:self.markerSet];
    for(NSDictionary *markerData in json){
        GMSMarker *newMarker = [[GMSMarker alloc]init];
        newMarker.appearAnimation = [markerData[@"appearAnimation"]integerValue];
        newMarker.position = CLLocationCoordinate2DMake([markerData[@"lat"]doubleValue], [markerData[@"lng"]doubleValue]);
        newMarker.title = markerData[@"title"];
        newMarker.snippet = markerData[@"snippet"];
        newMarker.map = nil;
        newMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        [mutableSet addObject:newMarker];
    }
    self.markerSet = [mutableSet copy];
   
    [self drawMarkers];
    
}
@end
