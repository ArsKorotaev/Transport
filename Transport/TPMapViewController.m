//
//  TPViewController.m
//  Transport
//
//  Created by Арсений Коротаев on 17.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import "TPMapViewController.h"
#import "AFJSONRequestOperation.h"


@interface TPMapViewController ()

@end

@implementation TPMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMapView];
    displayedObjects = [[NSMutableDictionary alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) setupMapView
{

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:58.00
                                                            longitude:56.22
                                                                 zoom:10];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.buildingsEnabled = NO;
    mapView.settings.rotateGestures = NO;
    //self.view = mapView_;
    
    // Creates a marker in the center of the map.    
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
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateAutos:) userInfo:nil repeats:YES];
    
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
            
            GMSMarker *marker;
            NSDictionary *oldBus = [displayedObjects objectForKey:[bus objectForKey:@"gosNom"]];
            
            if (!oldBus) {
                marker = [[GMSMarker alloc] init];                
                marker.map = mapView;
                [displayedObjects setObject:marker forKey:[bus objectForKey:@"gosNom"]];
            }
            else
            {
                marker = (GMSMarker *)oldBus;
            }
            
            @try {
                marker.position = CLLocationCoordinate2DMake([[bus objectForKey:@"n"] doubleValue], [[bus objectForKey:@"e"] doubleValue]);
                marker.title = [[bus objectForKey:@"gosNom"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
               // UIImage *icon =  [self courseImageWithAngle:[[bus objectForKey:@"course"] doubleValue] andColor:[UIColor redColor]];
               // marker.icon = icon;
            }
            @catch (NSException *exception) {
                NSLog(@"Ошибка обновления");
            }
            
            
            
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
    }];
    

    [op start];
}


- (UIImage *) courseImageWithAngle:(double)angle andColor:(UIColor*) color
{
    
    
    

	float width = 10;
	float height = 10;
	
    // Create a temporary texture data buffer
	void *data = calloc(width * height , 8);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
	// Draw image to buffer
	CGContextRef context = CGBitmapContextCreate(data,
                                             width,
                                             height,
                                             8,
                                             width * 8,
                                             colorSpace,
                                             kCGImageAlphaPremultipliedLast);
    


    //CGContextAddRect(context, CGRectMake(0, 0, 40, 40));
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, 2, 2));
    //CGContextFillRect(context, CGRectMake(0, 0, 2, 2));
    
    
    // write it to a new image
	CGImageRef cgimage = CGBitmapContextCreateImage(context);
	UIImage *newImage = [UIImage imageWithCGImage:cgimage];
    
	CFRelease(cgimage);
	CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    // auto-released
	return newImage;
}

@end
