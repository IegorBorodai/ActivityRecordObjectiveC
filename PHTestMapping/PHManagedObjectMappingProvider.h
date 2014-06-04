//
//  PHManagedObjectMappingProvider.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EasyMapping.h"

@interface PHManagedObjectMappingProvider : NSObject

+ (EKManagedObjectMapping *)errorResponseMapping;
+ (EKManagedObjectMapping *)responseMapping;
+ (EKManagedObjectMapping *)errorMapping;
+ (EKManagedObjectMapping *)featuresMapping;

@end
