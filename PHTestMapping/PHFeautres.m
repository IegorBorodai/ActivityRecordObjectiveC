//
//  PHFeautres.m
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHFeautres.h"

@implementation PHFeautres

+ (EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:[self class] withBlock:^(EKObjectMapping *mapping) {
        
    }];
}

@end
