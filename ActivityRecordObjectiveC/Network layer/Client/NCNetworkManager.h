//
//  PHNetworkManager.h
//  Phoenix
//
//  Created by Iegor Borodai on 1/23/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

//#import "PHNetworkOperation.h"
#import "NCNetworkRequest.h"

typedef void (^SuccessBlock)(NSURLSessionTask* task);
typedef void (^FailureBlock)(NSError* error, BOOL isCanceled);
typedef void (^FailureBlockWithOperation)(NSURLSessionTask* task, NSError* error, BOOL isCanceled);
typedef void (^ProgressBlock)(NSURLSessionTask* task, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);

@interface NCNetworkManager : NSObject

@property (nonatomic, readonly)    NSURL                                 *baseURL;
@property (nonatomic, readonly)    AFHTTPSessionManager                  *manager;

- (id)initWithBaseURL:(NSURL*)url;

- (BOOL)checkReachabilityStatusWithError:(NSError* __autoreleasing*)error;

- (NSURLSessionTask*)enqueueTaskWithNetworkRequest:(NCNetworkRequest*)networkRequest
                                                  success:(SuccessBlock)success
                                                  failure:(FailureBlock)failure
                                                 progress:(NSProgress*)progress;
@end
