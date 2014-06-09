//
//  PHNetworkManager.h
//  Phoenix
//
//  Created by Iegor Borodai on 1/23/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

//#import "PHNetworkOperation.h"
#import "PHNetworkRequest.h"

@interface PHNetworkManager : NSObject

@property (nonatomic, readonly)    NSURL                                 *baseURL;
    
@property (nonatomic, readonly)    AFHTTPSessionManager                  *manager;

typedef void (^SuccessBlock)(NSURLSessionTask* task);
typedef void (^FailureBlock)(NSError* error, BOOL isCanceled);
typedef void (^FailureBlockWithOperation)(NSURLSessionTask* task, NSError* error, BOOL isCanceled);
typedef void (^ProgressBlock)(NSURLSessionTask* task, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);

- (id)initWithBaseURL:(NSURL*)url;

- (BOOL)checkReachabilityStatus;
- (void)checkReachabilityStatusWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;
- (void)cancelAllOperation;
//- (void)cleanManagersWithCompletionBlock:(CleanBlock)block;

- (NSURLSessionTask*)enqueueOperationWithNetworkRequest:(PHNetworkRequest*)networkRequest
                                                  success:(SuccessBlock)success
                                                  failure:(FailureBlock)failure;

- (void)enqueueOperation:(NSURLSessionTask*)operation
                 success:(SuccessBlock)success
                 failure:(FailureBlockWithOperation)failure;


@end
