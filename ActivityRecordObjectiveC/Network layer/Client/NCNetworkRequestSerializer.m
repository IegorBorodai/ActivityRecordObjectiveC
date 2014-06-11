//
//  ACRequestSerializer.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "NCNetworkRequestSerializer.h"
#import "NCNetworkClient.h"

@implementation NCNetworkRequestSerializer


-(NSMutableURLRequest *)serializeRequestFromNetworkRequest:(NCNetworkRequest*)networkRequest error:(NSError* __autoreleasing*)error
{
    NSMutableURLRequest *request = nil;
    __block NSError     *localError = nil;
    
    BOOL passedParametersCheck = [networkRequest prepareAndCheckRequestParameters];
	
	if (!passedParametersCheck)
	{
		if (!networkRequest.error)
		{
			networkRequest.error = [NSError errorWithDomain:@"Internal inconsistency"
                                                       code:3
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Parameters didn't pass validation."}];
		}
        
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = networkRequest.error;
        return request;
	}
    
    if ([networkRequest.files count] > 0) {
        request = [self  multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:networkRequest.path relativeToURL:[NCNetworkClient HTTPClient].baseURL] absoluteString] parameters:networkRequest.parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for(NCNetworkHTTPRequestFileParameter* file in networkRequest.files)
            {
                if (![file isKindOfClass:[NCNetworkHTTPRequestFileParameter class]]) {
                    localError = [NSError errorWithDomain:@"Global" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Incorrect file parameter class. Must be PHNetworkHTTPRequestFileParameter"}];
                    continue;
                }
                
                if(file.fileData == nil)
                {
                    [formData appendPartWithFileURL:file.fileURL
                                               name:file.filename
                                              error:&localError];
                }
                else
                {
                    [formData appendPartWithFileData:file.fileData
                                                name:file.filename
                                            fileName:[file.fileURL lastPathComponent]
                                            mimeType:file.mimeType];
                }
            }
            
        } error:&localError];
	} else {
		request = [self requestWithMethod:networkRequest.method
                                URLString:[[NSURL URLWithString:networkRequest.path relativeToURL:[NCNetworkClient HTTPClient].baseURL] absoluteString]
                               parameters:networkRequest.parameters
                                    error:&localError];
	}
    
    if (localError && error != NULL) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = localError;
        return request;
    }
    
    for (NSString* key in networkRequest.customHeaders) {
        [request addValue:networkRequest.customHeaders[key] forHTTPHeaderField:key];
    }
    
    
    return request;
}


-(NSMutableURLRequest *)serializeRequestForDownloadingPath:(NSString*)path error:(NSError* __autoreleasing*)error;
{
    NSMutableURLRequest *request = nil;
    __block NSError     *localError = nil;
    
    request = [self requestWithMethod:@"GET"
                            URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient HTTPClient].baseURL] absoluteString]
                           parameters:nil
                                error:&localError];
    
    if (localError && error != NULL) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = localError;
        return request;
    }
    
    return request;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
								 URLString:(NSString *)URLString
								parameters:(NSDictionary *)parameters
									 error:(NSError *__autoreleasing *)error {
	NSMutableURLRequest *request = [super requestWithMethod:method
												  URLString:URLString
												 parameters:parameters
													  error:error];
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"hios8dc1c8e1" forHTTPHeaderField:@"App-Marker"];
    [request setValue:@"Bearer qrjjo5jrmmh9loq1saha57iu77" forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    return request;
    
}

-(NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block error:(NSError *__autoreleasing *)error
{
    NSMutableURLRequest *request = [super multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"hios8dc1c8e1" forHTTPHeaderField:@"App-Marker"];
    
    return request;
}

@end
