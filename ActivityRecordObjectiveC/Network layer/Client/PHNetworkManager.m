//
//  PHNetworkManager.m
//  Phoenix
//
//  Created by Iegor Borodai on 1/23/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHNetworkManager.h"

//#import "AFNetworking/AFHTTPSessionManager.h"
//#import "AFNetworking/AFHTTPRequestOperationManager.h"
#import "ACRequestSerializer.h"

#define MAX_CONCURENT_REQUESTS 100

typedef void (^failBlock)(NSError* error);

@interface PHNetworkManager ()


@property (nonatomic)                   AFNetworkReachabilityStatus           reachabilityStatus;

@property (nonatomic, strong)           AFHTTPSessionManager                  *sessionManager;
@property (nonatomic, strong)           AFHTTPSessionManager                  *downloadSessionManager;
@property (nonatomic, strong)           AFHTTPSessionManager                  *uploadSessionManager;

@property (nonatomic, strong)           NSMutableArray*                       requestStack;
@property (nonatomic, strong)           NSMutableArray*                       failStack;

@property (nonatomic, readwrite)        NSString*                             rootPath;

@property (nonatomic, readwrite)        NSURL                                 *baseURL;

@end

@implementation PHNetworkManager

#pragma mark - Lifecycle

- (id)initWithBaseURL:(NSURL*)url
{
    (self = [super init]);
    if (self) {
        self.baseURL = url;
        NSURLSessionConfiguration* taskConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        taskConfig.HTTPMaximumConnectionsPerHost = MAX_CONCURENT_REQUESTS;
        taskConfig.timeoutIntervalForResource = 0;
        taskConfig.timeoutIntervalForRequest = 0;
        taskConfig.allowsCellularAccess = YES;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:taskConfig];
        _downloadSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:taskConfig];
        _uploadSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:taskConfig];
        
        [_sessionManager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [_sessionManager setRequestSerializer:[ACRequestSerializer serializer]];
        
        
        __weak typeof(self)weakSelf = self;
        self.requestStack = [NSMutableArray new];
        self.failStack = [NSMutableArray new];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            weakSelf.reachabilityStatus = status;
            
#ifdef DEBUG
            NSString* stateText = nil;
            switch (weakSelf.reachabilityStatus) {
                case AFNetworkReachabilityStatusUnknown:
                    stateText = @"Network reachability is unknown";
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    stateText = @"Network is not reachable";
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    stateText = @"Network is reachable via WWAN";
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    stateText = @"Network is reachable via WiFi";
                    break;
            }
//            LOG_GENERAL(@"%@", stateText);
#endif
            
        }];
        
    }
    return self;
}

    
-(void)dealloc
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}


#pragma mark - Public methods


- (BOOL)checkReachabilityStatus
{
    if (self.reachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        return NO;
    }
    return YES;
}

- (void)checkReachabilityStatusWithSuccess:(void (^)(void))success
                                   failure:(void (^)(NSError *error))failure
{
    if (self.reachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        if (failure) {
            NSError* error = [NSError errorWithDomain:@"Reachability."
                                                 code:2
                                             userInfo:@{NSLocalizedDescriptionKey: @"noInternetConnection"}];
            failure(error);
        }
    }
    else {
        if (success) {
            success();
        }
    }
}

#pragma mark - Operation cycle

- (NSURLSessionTask*)enqueueOperationWithNetworkRequest:(PHNetworkRequest*)networkRequest success:(SuccessBlock)success
                                                  failure:(FailureBlock)failure
{
    NSError* error = nil;
    id manager = nil;
//        if (networkRequest.files.count > 0) {
//            manager = _uploadSessionManager;
//        } else if ([networkRequest isKindOfClass:[PHImageDownloadRequest class]]) {
//            manager = _downloadSessionManager;
//        } else
//        {
            manager = _sessionManager;
//        }
    NSURLSessionTask* task;
//    PHNetworkOperation* operation = [[PHNetworkOperation alloc] initWithNetworkRequest:networkRequest networkManager:manager error:&error];
    
//    if ((error) && (failure)) {
//        failure(error, NO);
//    }
//    else
//    {
//        [self enqueueOperation:operation success:^(PHNetworkOperation *operation) {
//            if (success) {
//                success(operation);
//            }
//        } failure:^(PHNetworkOperation *operation, NSError *error, BOOL isCanceled) {
//            if (failure) {
//                failure(error,isCanceled);
//            }
//        }];
//    }
    
    return task;
}


- (void)enqueueOperation:(NSURLSessionTask*)task success:(SuccessBlock)success
                 failure:(FailureBlockWithOperation)failure
{
 
    [self checkReachabilityStatusWithSuccess:^() {
//        [operation setCompletionBlockAfterProcessingWithSuccess:success failure:failure];
            [task resume];
    } failure:^(NSError *error) {
        if (failure) {
            failure(task, error, NO);
        }
    }];
}

- (void)cancelAllOperation
{
        [self.sessionManager.operationQueue cancelAllOperations];
        [self.uploadSessionManager.operationQueue cancelAllOperations];
        [self.downloadSessionManager.operationQueue cancelAllOperations];
}

@end
