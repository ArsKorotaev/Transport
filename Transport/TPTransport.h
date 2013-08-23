//
//  TPTransport.h
//  Transport
//
//  Created by multilab on 23.08.13.
//  Copyright (c) 2013 Арсений Коротаев. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TPTransport : NSManagedObject

@property (nonatomic, retain) NSString * routeId;
@property (nonatomic) int32_t routeNumber;
@property (nonatomic, retain) NSString * title;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) id marker;

@end
