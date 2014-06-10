//
//  NetworkHTTPRequest.h
//  localsgowild
//
//  Created by Artem Rizhov on 8/7/12.
//  Copyright (c) 2012 massinteractiveserviceslimited. All rights reserved.
//

@import Foundation;
@import ObjectiveC.runtime;

@interface PHNetworkHTTPRequestFileParameter : NSObject

@property(copy, nonatomic)	NSURL*		fileURL;
@property(copy, nonatomic)	NSString*	filename;
@property(copy, nonatomic)	NSString*	mimeType;
@property(copy, nonatomic)	NSData*     fileData;

@end

@interface PHNetworkRequest : NSObject
{
	NSString*						_path;
	NSMutableDictionary*			_parameters;
	NSString*						_method;
    NSMutableDictionary*            _customHeaders;
    BOOL                            _autorizationRequired;

    NSError*                        _error;
}

@property (readonly, nonatomic)	NSString*                           path;
@property (readonly, nonatomic)	NSMutableDictionary*                parameters;
@property (readonly, nonatomic)	NSString*                           method;
@property (readonly, nonatomic) BOOL                                autorizationRequired;
@property (readonly, nonatomic) NSMutableArray                      *files;
@property (readonly, nonatomic)	NSMutableDictionary*                customHeaders;
@property (nonatomic, strong)   NSError*                            error;

- (BOOL)prepareAndCheckRequestParameters;
//- (BOOL)parseResponseSucessfully:(id)responseObject;
- (BOOL)parseJSON:(id)responseObject error:(NSError* __autoreleasing *)error;
//- (void)createErrorWithResponseObject:(NSDictionary*)responseObject;
//- (BOOL)validateJsonErrorObject:(id)object withKey:(NSString*)key;

@end
