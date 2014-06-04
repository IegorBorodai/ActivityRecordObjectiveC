//
//  PHResponse.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PHMappedObject.h"

@class PHError;
@class PHFeautres;

@interface PHResponse : PHMappedObject

@property (nonatomic, strong) PHError *error;
@property (nonatomic, strong) PHFeautres *features;
@property (nonatomic, copy) NSString *termsofService;
@property (nonatomic, copy) NSString *version;

@end
