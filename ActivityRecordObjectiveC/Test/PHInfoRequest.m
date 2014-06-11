//
//  PHInfoRequest.m
//  Phoenix
//
//  Created by Boroday on 09.09.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

#import "PHInfoRequest.h"
#import "NCNetworkClient.h"

@implementation PHInfoRequest

- (id)init
{
    (self = [super init]);
    if (self)
    {
        _path = @"/info";
		_method = @"GET";
//        _autorizationRequired = NO;
    }
    return self;
}

- (BOOL)prepareAndCheckRequestParameters
{
	BOOL result = NO;
	
	BOOL passedBasicParametersCheck = [super prepareAndCheckRequestParameters];
	
	if (passedBasicParametersCheck)
	{
        _parameters[@"get"] = @"gender";
        
        result = YES;
    }
    
    return result;
}

- (BOOL)parseJSON:(id)responseObject error:(NSError* __autoreleasing *)error;
{
    if (responseObject[@"gender"]) {
        if ([responseObject[@"gender"] isKindOfClass:[NSDictionary class]]) {
            _genderAttributes = [responseObject[@"gender"] copy];
        } else if (([responseObject[@"gender"] isKindOfClass:[NSArray class]]) &&
                   (((NSArray *)responseObject[@"gender"]).count == 2)) {
            NSMutableDictionary *genderMut = [NSMutableDictionary new];
            
            genderMut[@"female"] = [(NSArray *)responseObject[@"gender"] firstObject];
            genderMut[@"male"] = [(NSArray *)responseObject[@"gender"] lastObject];
            _genderAttributes = genderMut;
        } else if ([responseObject[@"gender"] isKindOfClass:[NSString class]]) {
            NSMutableDictionary *genderMut = [NSMutableDictionary new];
            genderMut[@"male"] = responseObject[@"gender"];
            _genderAttributes = genderMut;
        }
    }

    if (_genderAttributes) {
        return YES;
    }
    
    return  NO;
}


@end
