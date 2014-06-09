//
//  PHManagedErrorResponse.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "PHBaseManagedObject.h"

@class PHManagedResponse;

@interface PHManagedErrorResponse : PHBaseManagedObject

@property (nonatomic, retain) PHManagedResponse *response;

@end
