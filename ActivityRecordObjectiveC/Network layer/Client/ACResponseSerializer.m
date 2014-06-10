//
//  ACResponseSerializer.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/10/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "ACResponseSerializer.h"

@implementation ACResponseSerializer

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError *__autoreleasing *)error
{
    BOOL success = NO;
    
    success = [super validateResponse:response data:data error:error];
    
    
    return YES;
}

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    NSDictionary* resposeData = [super responseObjectForResponse:response data:data error:error];
    
    return resposeData;
}

@end
