//
//  ViewController.m
//  MapKit
//
//  Created by Cole Bratcher on 5/20/14.
//  Copyright (c) 2014 Cole Bratcher. All rights reserved.
//

#import "ViewController.h"
#import "PointOfInterest.h"

@import MapKit;
@import AVFoundation;

#define CODEFELLOWS_COORDINATE CLLocationCoordinate2DMake(47.623548,-122.336212)

@interface ViewController () <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) MKLocalSearchResponse *searchResponse;
@property (nonatomic, strong) CLLocationManager *locationManager;
//@property (nonatomic, strong) MKAnnotationView *annotationView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.delegate = self;
	
    PointOfInterest *hilliardsBeer = [[PointOfInterest alloc] initWithCoordinate:(CLLocationCoordinate2DMake(47.664623,-122.378051)) andTitle:@"Hilliard's Beer"];
    [_mapView addAnnotation:hilliardsBeer];
    
    PointOfInterest *stoupBrewing = [[PointOfInterest alloc] initWithCoordinate:(CLLocationCoordinate2DMake(47.666653,-122.371202)) andTitle:@"Stoup Brewing"];
    [_mapView addAnnotation:stoupBrewing];
    
    PointOfInterest *rooftopBrewingCo = [[PointOfInterest alloc] initWithCoordinate:(CLLocationCoordinate2DMake(47.648910,-122.357299)) andTitle:@"Rooftop Brewing Co."];
    [_mapView addAnnotation:rooftopBrewingCo];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
    //7
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    //8
    static NSString *identifier = @"myAnnotation";
    MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView)
    {
        //9
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.pinColor = MKPinAnnotationColorPurple;
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
    }else {
        annotationView.annotation = annotation;
    }
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CODEFELLOWS_COORDINATE, 1000, 1000);
    [_mapView setRegion:region animated:YES];
    
}

#pragma mark - Search Bar Delegate


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    [searchRequest setNaturalLanguageQuery:searchBar.text];
    [searchRequest setRegion:_mapView.region];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return;
        }
        
        if (!response.mapItems.count) {
            NSLog(@"No Results Found");
            return;
        }
        
        _searchResponse = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
        
    }];
}

#pragma mark - Table View Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchResponse.mapItems count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    MKMapItem *item = self.searchResponse.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKMapItem *item = self.searchResponse.mapItems[indexPath.row];
    
    [_mapView addAnnotation:(id<MKAnnotation>)item.placemark];
    
}

-(void)drawRouteForItem:(MKMapItem *)item
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = item;
    MKDirections *directions = [[MKDirections alloc]initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error Calculating Directions %@", error);
        } else {
            [self showRoute:response];
        }
    }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes) {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        AVSpeechSynthesizer *speech = [AVSpeechSynthesizer new];
        
        for (MKRouteStep *step in route.steps) {
            NSLog(@"%@", step.instructions);
            [speech speakUtterance:[AVSpeechUtterance speechUtteranceWithString:step.instructions]];
        }
        
    }
}

-(IBAction)currentLocation:(id)sender
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude), 1000, 1000);
    [_mapView setRegion:region animated:YES];
}


@end
