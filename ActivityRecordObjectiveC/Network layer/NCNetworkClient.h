//
//  Phoenix.h
//  localsgowild
//
//  Created by Artem Rizhov on 28.01.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//


#import "NCNetworkManager.h"

@interface NCNetworkClient : NSObject

// Public
+ (void)initHTTPClientWithRootPath:(NSString*)baseURL;

// Singletons
+ (NCNetworkManager *)HTTPClient;

// Network status
- (BOOL)checkReachabilityStatusWithError:(NSError* __autoreleasing*)error;

//Requests
+ (NSURLSessionTask*)getGenderInfoWithSuccessBlock:(void (^)(NSDictionary *genderAttributes))success
                                           failure:(void (^)(NSError *error, BOOL isCanceled))failure;

+ (NSURLSessionTask*)downloadImageFromPath:(NSString*)path
                                   success:(void (^)(UIImage* image))success
                                   failure:(void (^)(NSError *error, BOOL isCanceled))failure
                                  progress:(NSProgress*)progress;

- (NSURLSessionDownloadTask*)downloadFileFromPath:(NSString*)path
                                       toFilePath:(NSString*)filePath
                                          success:(SuccessFileURLBlock)successBlock
                                          failure:(FailureBlock)failureBlock
                                         progress:(NSProgress*)progress;
;

@end
