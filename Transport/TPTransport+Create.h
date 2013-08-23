//
//  TPTransport+Create.h
//  Transport
//
//  Created by multilab on 23.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import "TPTransport.h"
static NSString * const kTPTransportNumber = @"routeNumber";
static NSString * const kTPTransportTitle = @"title";
static NSString * const kTPTransportIdentifer = @"routeId";
static NSString * const kTPTransportType = @"type";

@interface TPTransport (Create)
+ (TPTransport*) transportWithValues:(NSDictionary*) values inContext:(NSManagedObjectContext*) ctx;
@end
