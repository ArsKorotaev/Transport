//
//  TPFiltersViewController.m
//  Transport
//
//  Created by multilab on 23.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import "TPFiltersViewController.h"
#import "AFJSONRequestOperation.h"
#import "TPTransport+Create.h"


@interface TPFiltersViewController ()

@end

@implementation TPFiltersViewController

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

   
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    
    self.refreshControl = refreshControl;
    
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
}
- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"TPTransport"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
                                    [NSSortDescriptor sortDescriptorWithKey:@"routeNumber" ascending:YES]];
                
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:@"type"
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    if (!_managedObjectContext) {
        [self.refreshControl endRefreshing];
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://map.gptperm.ru/json/route-types-tree/23.10.2013/"]];
    
    AFJSONRequestOperation *routesRequest = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //
        
        for (NSDictionary *autosSet in JSON) {
            for (NSDictionary *rout in [autosSet objectForKey:@"children"])
            {
                NSMutableDictionary *values = [rout mutableCopy];
                NSString *type = [[autosSet objectForKey:@"title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [values setObject:type forKey:kTPTransportType];
                [TPTransport transportWithValues:values inContext:_managedObjectContext];
                
            }
        }
        NSError *error;
        [_managedObjectContext save:&error];
        
        if (error) {
            NSLog(@"%@", error.description);
        }
        [self.refreshControl endRefreshing];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //
    }];
    
    [routesRequest start];
    
//    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
//    dispatch_async(fetchQ, ^{
//        NSArray *photos = [FlickrFetcher latestGeoreferencedPhotos];
//        // put the photos in Core Data
//        [self.managedObjectContext performBlock:^{
//            for (NSDictionary *photo in photos) {
//                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.refreshControl endRefreshing];
//            });
//        }];
//    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TransportCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    TPTransport *transport = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = transport.title;
    if (transport.isSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell...
    
    return cell;
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
    
    TPTransport *transport = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (transport.isSelected) {
        transport.isSelected = NO;
    }
    else
    {
        transport.isSelected = YES;
    }
}

- (IBAction)dismis:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
