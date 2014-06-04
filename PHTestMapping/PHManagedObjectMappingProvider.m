//
//  PHManagedObjectMappingProvider.m
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHManagedObjectMappingProvider.h"

#import "PHErrorResponse.h"

@implementation PHManagedObjectMappingProvider

+ (EKManagedObjectMapping *)errorResponseMapping
{
    return [EKManagedObjectMapping mappingForEntityName:@"PHManagedErrorResponse" withBlock:^(EKManagedObjectMapping *mapping) {
        [mapping hasOneMapping:[self responseMapping] forKey:@"response"];
    }];
}

+ (EKManagedObjectMapping *)responseMapping
{
    return [EKManagedObjectMapping mappingForEntityName:@"PHManagedResponse" withBlock:^(EKManagedObjectMapping *mapping) {
        [mapping hasOneMapping:[self errorMapping] forKey:@"error"];
        [mapping hasOneMapping:[self featuresMapping] forKey:@"features"];
        [mapping mapFieldsFromArray:@[@"termsofService", @"version"]];
    }];
}

+ (EKManagedObjectMapping *)errorMapping
{
    return [EKManagedObjectMapping mappingForEntityName:@"PHManagedError" withBlock:^(EKManagedObjectMapping *mapping) {
        [mapping mapFieldsFromDictionary:@{@"type" : @"errorType", @"description" : @"errorDescription"}];
    }];
}

+ (EKManagedObjectMapping *)featuresMapping
{
    return [EKManagedObjectMapping mappingForEntityName:@"PHManagedFeatures" withBlock:^(EKManagedObjectMapping *mapping) {
        
    }];
}

@end
