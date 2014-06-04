//
//  PHMappedObject.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/30/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EasyMapping.h"

@interface PHMappedObject : NSObject

@property (nonatomic, strong) NSDictionary *responseObject;

+ (EKObjectMapping *)objectMapping;

- (id)initWithProperties:(NSDictionary *)properties;
- (void)saveAsManagedObject;

@end
