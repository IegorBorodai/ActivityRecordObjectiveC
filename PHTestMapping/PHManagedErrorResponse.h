//
//  PHManagedErrorResponse.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHManagedResponse;

@interface PHManagedErrorResponse : NSManagedObject

@property (nonatomic, retain) PHManagedResponse *response;

@end
