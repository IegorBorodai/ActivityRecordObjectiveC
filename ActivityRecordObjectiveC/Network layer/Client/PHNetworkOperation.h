//
//  PHURLSessionTask.h
//  Phoenix
//
//  Created by Iegor Borodai on 12/11/13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

@import Foundation;
#import "AFHTTPSessionManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "PHNetworkRequest.h"

@interface PHNetworkOperation : NSObject

//typedef void (^SuccessBlock)(PHNetworkOperation* operation);
//typedef void (^FailureBlock)(NSError* error, BOOL isCanceled);
//typedef void (^FailureBlockWithOperation)(PHNetworkOperation* operation, NSError* error, BOOL isCanceled);
//typedef void (^ProgressBlock)(PHNetworkOperation* operation, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite);

- (id)initWithNetworkRequest:(PHNetworkRequest*)networkRequest networkManager:(id)manager error:(NSError *__autoreleasing *)error;

- (void)setCompletionBlockAfterProcessingWithSuccess:(SuccessBlock)success
                                             failure:(FailureBlockWithOperation)failure;

- (void)setProgressBlock:(ProgressBlock)block;

- (void)start;
- (void)pause;
- (void)cancel;

@property (nonatomic, readonly, strong)       PHNetworkRequest*                   networkRequest;
@property (nonatomic, strong)                 SuccessBlock                        successBlock;
@property (nonatomic, strong)                 FailureBlockWithOperation           failureBlock;

@end
