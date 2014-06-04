//
//  PHResponse.m
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHResponse.h"
#import "PHError.h"
#import "PHFeautres.h"

@implementation PHResponse

+ (EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:[self class] withBlock:^(EKObjectMapping *mapping) {
        [mapping hasOneMapping:[PHError objectMapping] forKey:@"error"];
        [mapping hasOneMapping:[PHFeautres objectMapping] forKey:@"features"];
        [mapping mapFieldsFromArray:@[@"termsofService", @"version"]];
    }];
}

@end
