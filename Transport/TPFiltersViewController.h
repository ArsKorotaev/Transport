//
//  TPFiltersViewController.h
//  Transport
//
//  Created by multilab on 23.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPCoreDataTableViewController.h"

@interface TPFiltersViewController : BPCoreDataTableViewController
@property NSManagedObjectContext *managedObjectContext;
- (IBAction)dismis:(id)sender;

@end
