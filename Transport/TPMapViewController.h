//
//  TPViewController.h
//  Transport
//
//  Created by Арсений Коротаев on 17.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TPMapViewController : UIViewController
{
    GMSMapView *mapView;
    __weak IBOutlet UIView *mapContainer;
    
    NSMutableDictionary *displayedObjects;
    NSTimer *updateTimer;

}
@property NSManagedObjectContext *managedObjectContext;
@end
