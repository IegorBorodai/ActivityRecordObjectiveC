//
//  NetworkHTTPRequest.h
//  localsgowild
//
//  Created by Artem Rizhov on 8/7/12.
//  Copyright (c) 2012 massinteractiveserviceslimited. All rights reserved.
//

@import Foundation;
@import ObjectiveC.runtime;

@interface PHNetworkRequest : NSObject
{
	NSString*						_path;
	NSMutableDictionary*			_parameters;
	NSString*						_method;
    NSMutableDictionary*            _customHeaders;
    BOOL                            _autorizationRequired;

    NSError*                        _error;
}

@property (readonly)	NSString*                           path;
@property (readonly)	NSMutableDictionary*                parameters;
@property (readonly)	NSString*                           method;
@property (readonly)    BOOL                                autorizationRequired;
@property (readonly)    NSMutableArray                      *files;
@property (readonly)	NSMutableDictionary*                customHeaders;
@property (nonatomic, strong)    NSError*                   error;

- (BOOL)prepareAndCheckRequestParameters;
- (BOOL)parseResponseSucessfully:(id)responseObject;
- (BOOL)parseJSONDataSucessfully:(id)responseObject error:(NSError* __autoreleasing *)error;
- (void)createErrorWithResponseObject:(NSDictionary*)responseObject;
- (BOOL)validateJsonErrorObject:(id)object withKey:(NSString*)key;

@end
