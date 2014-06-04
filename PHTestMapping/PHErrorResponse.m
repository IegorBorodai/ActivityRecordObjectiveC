//
//  PHErrorResponse.m
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHErrorResponse.h"

#import "PHResponse.h"
#import "PHManagedErrorResponse.h"
#import "PHManagedResponse.h"
#import "PHManagedError.h"

@implementation PHErrorResponse

+ (EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:[self class] withBlock:^(EKObjectMapping *mapping) {
        [mapping hasOneMapping:[PHResponse objectMapping] forKey:@"response"];
    }];
}

- (void)saveAsManagedObject
{
    //PHManagedErrorResponse *mErrorResponse = [PHManagedErrorResponse MR_importFromObject:self];
    
    PHManagedErrorResponse *mErrorResponse = [PHManagedErrorResponse MR_createEntity];
    NSLog(@"%@", self.responseObject);
    [mErrorResponse MR_importValuesForKeysWithObject:self.responseObject];
    
    NSLog(@"Mapping on managed objects:\nError description:%@\n terms of service: %@\n version: %@\n error type: %@",
          mErrorResponse.response.error.errorDescription,
          mErrorResponse.response.termsofService,
          mErrorResponse.response.version,
          mErrorResponse.response.error.errorType);
    
    //PHManagedErrorResponse *mErrorResponse = []
    
    [super saveAsManagedObject];
}

@end
