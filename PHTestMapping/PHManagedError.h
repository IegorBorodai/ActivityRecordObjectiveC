//
//  PHManagedError.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "PHBaseManagedObject.h"

@class PHManagedResponse;

@interface PHManagedError : PHBaseManagedObject

@property (nonatomic, retain) NSString * errorType;
@property (nonatomic, retain) NSString * errorDescription;
@property (nonatomic, retain) PHManagedResponse *response;

@end
