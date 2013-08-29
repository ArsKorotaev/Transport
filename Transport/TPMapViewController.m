//
//  TPViewController.m
//  Transport
//
//  Created by Арсений Коротаев on 17.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import "TPMapViewController.h"
#import "AFJSONRequestOperation.h"
#import "TPFiltersViewController.h"
#import "TPTransport.h"

#define ARC4RANDOM_MAX      0x100000000

@interface TPMapViewController () <NSFetchedResultsControllerDelegate>

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
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.managedObjectContext) {
        [self useDocument];
    }
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowFilterView"]) {
        UINavigationController *nav = segue.destinationViewController;
        TPFiltersViewController *fvc = [nav.childViewControllers lastObject];
        
        fvc.managedObjectContext = _managedObjectContext;
    }
    
}
- (void) updateAutos:(id) sender
{
    NSAssert(mapView, @"Не инициализирована карта");
    
    for (TPTransport *transport in fetchedResultsController.fetchedObjects) {
        NSString *requestString = [NSString stringWithFormat:@"http://map.gptperm.ru/json/get-moving-autos/-%@-",transport.routeId];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
        
        AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            //
            NSArray *objects = [JSON objectForKey:@"autos"];
            
            UIColor *markerColor = [UIColor colorWithRed:((double)arc4random() / ARC4RANDOM_MAX)
                                                   green:((double)arc4random() / ARC4RANDOM_MAX)
                                                    blue:((double)arc4random() / ARC4RANDOM_MAX)
                                                   alpha:1.0];
            for (NSDictionary *bus in objects) {
                
                GMSMarker *marker;
                NSDictionary *oldBus = [displayedObjects objectForKey:[bus objectForKey:@"gosNom"]];
                
                
                
                @try {
                    
                    if (!oldBus) {
                        marker = [[GMSMarker alloc] init];
                        marker.map = mapView;
                        UIImage *icon =  [self courseImageWithAngle:[[bus objectForKey:@"course"] doubleValue] andColor:markerColor];
                        marker.icon = icon;//[GMSMarker markerImageWithColor:markerColor];
                        marker.groundAnchor = CGPointMake(0.5, 0.5);
                        [displayedObjects setObject:marker forKey:[bus objectForKey:@"gosNom"]];
                    }
                    else
                    {
                        marker = (GMSMarker *)oldBus;
                    }
                    
                    UIImage *icon =  [self courseImageWithAngle:[[bus objectForKey:@"course"] doubleValue] andColor:markerColor];
                    marker.icon = icon;//[GMSMarker markerImageWithColor:markerColor];
                    
                    marker.position = CLLocationCoordinate2DMake([[bus objectForKey:@"n"] doubleValue], [[bus objectForKey:@"e"] doubleValue]);
                    marker.title = [[bus objectForKey:@"gosNom"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    
                   // NSLog(@"Gos nomer: %@. Rotation: %@", [bus objectForKey:@"gosNom"], [bus objectForKey:@"course"]);
                    
                }
                @catch (NSException *exception) {
                    marker.map = nil;
                    NSLog(@"Ошибка обновления");
                }
                
                
                
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            //
        }];
        
        
        [op start];
    }
    

}

- (void)useDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"base.sqlite"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self setupFetchedResultsController];
              }
              else
              {
                  NSLog(@"Can't save");
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self setupFetchedResultsController];
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
        [self setupFetchedResultsController];
    }
    

}

- (void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TPTransport"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                [NSSortDescriptor sortDescriptorWithKey:@"routeNumber" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"isSelected == YES"];
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:nil];
}

- (UIImage *) courseImageWithAngle:(double)angle andColor:(UIColor*) color
{
    
    
    

	float width = 40.f;
	float height = 40.f;
	
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
    
    
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(width / 2.0, height / 2.0);
    transform = CGAffineTransformRotate(transform,  - (angle * M_PI / 180.f));
    
    transform = CGAffineTransformTranslate(transform, -width / 2.0, -height / 2.0);
    
    CGContextConcatCTM(context, transform);

    //CGContextAddRect(context, CGRectMake(0, 0, 40, 40));
    CGContextSetFillColorWithColor(context, color.CGColor);
    //CGContextFillEllipseInRect(context, CGRectMake(0, 0, 2, 2));
    //CGContextFillRect(context, CGRectMake(0, 0, 10, 10));
    
    //Cnhtkrf
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL,15,10);
    CGPathAddLineToPoint(path, NULL,20,30);
    CGPathAddLineToPoint(path, NULL,25,10);
    CGPathAddLineToPoint(path, NULL,15,10);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    
    // write it to a new image
	CGImageRef cgimage = CGBitmapContextCreateImage(context);
	UIImage *newImage = [UIImage imageWithCGImage:cgimage];
    
	CFRelease(cgimage);
	CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	
    // auto-released
	return newImage;
}

#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch(type)
    {
    case NSFetchedResultsChangeInsert:
     //   [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self updateAutos:nil];
        break;
        
    case NSFetchedResultsChangeDelete:
      //  [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
    case NSFetchedResultsChangeUpdate:
    //    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
    case NSFetchedResultsChangeMove:
     //   [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
     //   [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
    }

}
@end
