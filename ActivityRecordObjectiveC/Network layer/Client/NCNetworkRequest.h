//
//  NetworkHTTPRequest.h
//  localsgowild
//
//  Created by Artem Rizhov on 8/7/12.
//  Copyright (c) 2012 massinteractiveserviceslimited. All rights reserved.
//

@import Foundation;
@import ObjectiveC.runtime;

@interface NCNetworkHTTPRequestFileParameter : NSObject

@property(copy, nonatomic)	NSURL*		fileURL;
@property(copy, nonatomic)	NSString*	filename;
@property(copy, nonatomic)	NSString*	mimeType;
@property(copy, nonatomic)	NSData*     fileData;

@end

@interface NCNetworkRequest : NSObject
{
	NSString*						_path;
	NSString*						_method;
	NSMutableDictionary*			_parameters;
    NSMutableDictionary*            _customHeaders;
//    BOOL                            _autorizationRequired;
}

@property (readonly, nonatomic)	NSString*                           path;
@property (readonly, nonatomic)	NSString*                           method;
@property (readonly, nonatomic)	NSMutableDictionary*                parameters;
@property (readonly, nonatomic)	NSMutableDictionary*                customHeaders;
@property (readonly, nonatomic) NSMutableArray                      *files;
@property (nonatomic, strong)   NSError*                            error;
//@property (readonly, nonatomic) BOOL                                autorizationRequired;

- (BOOL)prepareAndCheckRequestParameters;
- (BOOL)parseJSON:(id)responseObject error:(NSError* __autoreleasing *)error;

@end
