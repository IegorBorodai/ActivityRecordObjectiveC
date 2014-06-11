//
//  NetworkHTTPRequest.m
//  localsgowild
//
//  Created by Artem Rizhov on 8/7/12.
//  Copyright (c) 2012 massinteractiveserviceslimited. All rights reserved.
//

#import "NCNetworkRequest.h"
#import "NCNetworkClient.h"

@implementation NCNetworkHTTPRequestFileParameter
@end

@implementation NCNetworkRequest

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

- (BOOL)parseJSON:(id)responseObject error:(NSError* __autoreleasing *)error;
{
    return YES;
}

- (BOOL)prepareAndCheckRequestParameters
{
    return YES;
}


@end
