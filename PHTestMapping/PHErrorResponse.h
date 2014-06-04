//
//  PHErrorResponse.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PHMappedObject.h"

@class PHResponse;

@interface PHErrorResponse : PHMappedObject

@property (nonatomic, strong) PHResponse *response;

@end
