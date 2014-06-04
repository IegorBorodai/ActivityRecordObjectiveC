//
//  PHManagedResponse.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PHManagedFeatures;
@class PHManagedError;

@interface PHManagedResponse : NSManagedObject

@property (nonatomic, retain) NSString * termsofService;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) NSManagedObject *errorResponse;
@property (nonatomic, retain) PHManagedError *error;
@property (nonatomic, retain) PHManagedFeatures *features;

@end
