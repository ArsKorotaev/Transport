//
//  TPTransport+Create.m
//  Transport
//
//  Created by multilab on 23.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import "TPTransport+Create.h"

@implementation TPTransport (Create)
+ (TPTransport*) transportWithValues:(NSDictionary *)values inContext:(NSManagedObjectContext *)ctx
{
    TPTransport *transport;
    transport = [NSEntityDescription insertNewObjectForEntityForName:@"TPTransport" inManagedObjectContext:ctx];
    transport.title = [values objectForKey:kTPTransportTitle];
    transport.routeId = [values objectForKey:kTPTransportIdentifer];
    transport.routeNumber = [[values objectForKey:kTPTransportNumber] integerValue];
    transport.type = [values objectForKey:kTPTransportType];
    
    return transport;
}
@end
