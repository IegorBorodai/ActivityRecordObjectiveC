//
//  NetworkHTTPRequest.m
//  localsgowild
//
//  Created by Artem Rizhov on 8/7/12.
//  Copyright (c) 2012 massinteractiveserviceslimited. All rights reserved.
//

#import "PHNetworkRequest.h"
#import "PHPhoenix.h"

@implementation PHNetworkRequest

#pragma mark - Control methods

-(id)init
{
    if (((self = [super init])))
    {
        _path = @"";
     	if (!_parameters) {
            _parameters = [[NSMutableDictionary alloc] init];
        }
        
        if(!_customHeaders) {
            _customHeaders = [[NSMutableDictionary alloc] init];
        }
        
        if(!_files) {
            _files = [NSMutableArray new];
        }
    }
    return self;
}

-(void)dealloc
{
    _error = nil;
}

- (BOOL)parseResponseSucessfully:(id)responseObject
{
    BOOL parseJSONData = NO;
    
    if(responseObject == nil)
    {
//        LOG_NETWORK(@"Error: Response Is Empty");
        _error = [NSError errorWithDomain:[NSString stringWithFormat:@"%@ - response is empty", NSStringFromClass([self class])]
                                     code:1
                                 userInfo:@{NSLocalizedDescriptionKey: @"response empty"}];
        
        return parseJSONData;
    }
    
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseObject
                          options:kNilOptions
                          error:&error];
    
    if(error)
    {
        _error = error;
    }
    else
    {
        if([json isKindOfClass:[NSDictionary class]] && json[@"status"])
        {
            if([json[@"status"] isEqualToString:@"success"])
            {
                @try
                {
                    if(json[@"data"] && [json[@"data"] isKindOfClass:[NSDictionary class]]) {
                        NSError* error = nil;
                        parseJSONData = [self parseJSONDataSucessfully:json[@"data"] error:&error];
                        if (!_error) {
                            _error = error;
                        }
                    }
                    else {
                        [self createErrorWithResponseObject:json];
                    }
                }
                @catch (NSException * e)
                {
                    _error = [NSError errorWithDomain:@""
                                                 code:3
                                             userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"name:%@\nreason:%@", e.name, e.reason]}];
                }
                @finally
                {
                    
                }
            }
            else if([json[@"status"] isEqualToString:@"error"])
            {
                [self createErrorWithResponseObject:json];
            }
            else
            {
                
            }
        }
        else {
            
        }
    }
    
    return parseJSONData;
}

- (void)createErrorWithResponseObject:(NSDictionary*)responseObject
{
    if (responseObject[@"meta"][@"redirect"] && [responseObject[@"meta"][@"redirect"] isKindOfClass:[NSString class]]) {
        _error = [NSError errorWithDomain:@"redirect"
                                     code:302
                                 userInfo:@{NSLocalizedDescriptionKey: responseObject[@"meta"][@"redirect"]}];
    }
    else
    {
        NSInteger code = 0;
        NSString* description = @"";
        
        if(responseObject[@"meta"][@"code"]) {
            code = [responseObject[@"meta"][@"code"] integerValue];
        }
        
        if([self validateJsonErrorObject:responseObject withKey:@"general"]) {
            description = responseObject[@"meta"][@"description"][@"general"][0];
        }
        
    _error = [NSError errorWithDomain:@"message"
                                 code:code
                             userInfo:@{NSLocalizedDescriptionKey: description}];
    }
}

- (BOOL)validateJsonErrorObject:(id)object withKey:(NSString*)key
{
    
    if ([object[@"meta"][@"description"] isKindOfClass:[NSDictionary class]] && object[@"meta"][@"description"][key] && [object[@"meta"][@"description"][key] isKindOfClass:[NSArray class]] && ((NSArray*)object[@"meta"][@"description"][key]).count > 0 && [[((NSArray*)object[@"meta"][@"description"][key]) firstObject] isKindOfClass:[NSString class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)parseJSONDataSucessfully:(id)responseObject error:(NSError* __autoreleasing  *)error
{
    return YES;
}

- (BOOL)prepareAndCheckRequestParameters
{
    return YES;
}


@end
