//
//  ACRequestSerializer.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "ACRequestSerializer.h"

@implementation ACRequestSerializer


-(NSMutableURLRequest *)serializeRequestFromNetworkRequest:(PHNetworkRequest*)networkRequest error:(NSError* __autoreleasing*)error
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
        request = [self  multipartFormRequestWithMethod:@"POST" URLString:networkRequest.path parameters:networkRequest.parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for(PHNetworkHTTPRequestFileParameter* file in networkRequest.files)
            {
                if (![file isKindOfClass:[PHNetworkHTTPRequestFileParameter class]]) {
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
                                URLString:networkRequest.path
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

@end
