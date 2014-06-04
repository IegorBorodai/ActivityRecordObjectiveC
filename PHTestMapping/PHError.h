//
//  PHError.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PHMappedObject.h"

@interface PHError : PHMappedObject

@property (nonatomic, copy) NSString *errorDescription;
@property (nonatomic, assign) NSString *errorType;

@end
