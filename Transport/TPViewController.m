//
//  TPViewController.m
//  Transport
//
//  Created by Арсений Коротаев on 17.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import "TPViewController.h"
#import "AFJSONRequestOperation.h"


@interface TPViewController ()

@end

@implementation TPViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMapView];
    displayedObjects = [[NSMutableDictionary alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) setupMapView
{

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    //self.view = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView;
    
    [mapView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [mapContainer addSubview:mapView];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (mapView);
    NSArray *constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mapView]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewsDictionary];
    NSArray *constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mapView]|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:viewsDictionary];
    
    
    
    
    [mapContainer addConstraints:constraintsVertical];
    [mapContainer addConstraints:constraintsHorizontal];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(updateAutos:) userInfo:nil repeats:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [updateTimer invalidate];
    updateTimer = nil;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateAutos:(id) sender
{
    NSAssert(mapView, @"Не инициализирована карта");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://map.gptperm.ru/json/get-moving-autos/-68-"]];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
        NSArray *objects = [JSON objectForKey:@"autos"];
        
        for (NSDictionary *bus in objects) {
            NSDictionary *oldBus = [displayedObjects objectForKey:[bus objectForKey:@"gosNom"]];
            if (!oldBus) {
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake([[bus objectForKey:@"n"] doubleValue], [[bus objectForKey:@"e"] doubleValue]);
                marker.title = @"68";
                marker.map = mapView;
                [displayedObjects setObject:marker forKey:[bus objectForKey:@"gosNom"]];
            }
            else
            {
                GMSMarker *marker = (GMSMarker *)oldBus;
                marker.position = CLLocationCoordinate2DMake([[bus objectForKey:@"n"] doubleValue], [[bus objectForKey:@"e"] doubleValue]);
                marker.title = @"68";
                marker.map = mapView;
            }
            
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
    }];
    
    
    [op start];
}

@end
