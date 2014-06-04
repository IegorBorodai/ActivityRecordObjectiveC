//
//  PHManagedError.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHManagedResponse;

@interface PHManagedError : NSManagedObject

@property (nonatomic, retain) NSString * errorType;
@property (nonatomic, retain) NSString * errorDescription;
@property (nonatomic, retain) PHManagedResponse *response;

@end
