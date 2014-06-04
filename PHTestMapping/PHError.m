//
//  PHError.m
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHError.h"

@implementation PHError

+ (EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:[self class] withBlock:^(EKObjectMapping *mapping) {
        [mapping mapFieldsFromDictionary:@{@"description" : @"errorDescription", @"type" : @"errorType"}];
    }];
}

@end
