//
//  ACRequestSerializer.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "ACRequestSerializer.h"

@implementation ACRequestSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                 URLString:(NSString *)URLString
                                parameters:(NSDictionary *)parameters
                                     error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *request = [super requestWithMethod:method
                                                  URLString:URLString
                                                 parameters:parameters
                                                      error:error];
    
    return request;
}


@end
