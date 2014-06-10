//
//  PHNetworkManager.m
//  Phoenix
//
//  Created by Iegor Borodai on 1/23/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHNetworkManager.h"

#import "ACRequestSerializer.h"
#import "ACResponseSerializer.h"
#import "PHImageDownloadRequest.h"

#define MAX_CONCURENT_REQUESTS 100

typedef void (^failBlock)(NSError* error);

@interface PHNetworkManager ()


@property (nonatomic)                   AFNetworkReachabilityStatus           reachabilityStatus;
@property (nonatomic, strong)           AFHTTPSessionManager                  *sessionManager;
@property (nonatomic, readwrite)        NSString                              *rootPath;
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
        taskConfig.HTTPShouldSetCookies = NO;

        NSDictionary* headers = @{@"X-Requested-With" : @"XMLHttpRequest", @"App-Marker":@"hios8dc1c8e1"};
        taskConfig.HTTPAdditionalHeaders = headers;
        
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:taskConfig];
        
        [_sessionManager setRequestSerializer:[ACRequestSerializer serializer]];
        [_sessionManager setResponseSerializer:[ACResponseSerializer serializer]];
        
        
        __weak typeof(self)weakSelf = self;
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


- (BOOL)checkReachabilityStatusWithError:(NSError* __autoreleasing*)error
{
    if (self.reachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        if (error != NULL) {
            *error = [NSError errorWithDomain:@"Reachability."
                                         code:2
                                     userInfo:@{NSLocalizedDescriptionKey: @"noInternetConnection"}];
        }
        return NO;
    }
    return YES;
}


#pragma mark - Operation cycle

- (NSURLSessionTask*)enqueueTaskWithNetworkRequest:(PHNetworkRequest*)networkRequest
                                                success:(SuccessBlock)successBlock
                                                failure:(FailureBlock)failureBlock
                                               progress:(NSProgress*)progress
{
   __block  NSError             *error = nil;
    NSURLSessionTask            *task = nil;
    BOOL isInternetEnabled = [self checkReachabilityStatusWithError:&error];
    
    if (isInternetEnabled) {
    
    NSMutableURLRequest *request = [((ACRequestSerializer*)self.sessionManager.requestSerializer) serializeRequestFromNetworkRequest:networkRequest error:&error];
    
    if (error) {
        failureBlock(error, NO);
    }
    
    void (^SuccessOperationBlock)(NSURLSessionTask *task, id responseObject) = ^(NSURLSessionTask *task, id responseObject) {
        
//        if (![weakSelf.networkRequest isKindOfClass:[PHImageDownloadRequest class]]) {
//            LOG_NETWORK(@"Response <<< : %li \n%@\n%@", (long)weakself.requestNumber, [NSString stringWithString:[weakself.urlRequest.URL absoluteString]], [[NSString alloc] initWithData:responseObject encoding: NSUTF8StringEncoding]);
//        }
        BOOL success = NO;
//        if ([networkRequest isKindOfClass:[PHImageDownloadRequest class]]) {
//            success = [networkRequest parseJSON:responseObject error:&error];
//        } else {
            success = [networkRequest parseJSON:responseObject error:&error];
//        }
        
        if (success)
        {
            if (successBlock) {
                successBlock(task);
            }
        }
        else
        {
            if (failureBlock) {
                networkRequest.error = error;
                failureBlock(networkRequest.error, NO);
            }
        }
    };
    
    void (^FailureOperationBlock)(NSURLSessionTask *task, NSError *error) = ^(id operation, NSError *error){
        BOOL requestCanceled = NO;
        
        if (error.code == 500 || error.code == 404 || error.code == -1011)
        {
            NSString* path = @"";
            if ([operation isKindOfClass:[NSURLResponse class]]) {
                path = [((NSURLResponse*)operation).URL path];
            } else {
                path = [((AFHTTPRequestOperation*)operation).request.URL path];
            }
//            LOG_NETWORK(@"STATUS: request %@ failed with error: %@", path, [error localizedDescription]);
            networkRequest.error = [NSError errorWithDomain:error.domain
                                                                code:error.code
                                                            userInfo:@{NSLocalizedDescriptionKey: @"serverIsOnMaintenance"}];
        }
        else if (error.code == NSURLErrorCancelled)
        {
            networkRequest.error = error;
            requestCanceled = YES;
        }
        else
        {
            networkRequest.error = error;
        }
        
        if (failureBlock) {
            failureBlock(networkRequest.error,requestCanceled);
        }
    };

    
    if ([networkRequest.files count] > 0)
    {
        NSProgress *localProgress;
        task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                SuccessOperationBlock(task, responseObject);
            } else {
                FailureOperationBlock(task, error);
            }
        }];
        progress = localProgress;
    } else if ([networkRequest isKindOfClass:[PHImageDownloadRequest class]]) {
        NSProgress* localProgress;
        task = [self.sessionManager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString* path = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[[targetPath path] componentsSeparatedByString:@"/"] lastObject]]];
            NSError* error = nil;
            [fileManager moveItemAtPath:[targetPath path] toPath:path error:&error];
            
            if (error) {
//                LOG_GENERAL(@"FILE MOVE ERROR = %@", error.localizedDescription);
            }
            return [NSURL fileURLWithPath:path];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (!error) {
                SuccessOperationBlock(task, filePath);
            } else {
                FailureOperationBlock(task, error);
            }
        }];
        progress = localProgress;
    } else {
        task = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                SuccessOperationBlock(task, responseObject);
            } else {
                FailureOperationBlock(task, error);
            }
        }];
    }
    
        [task resume];
    } else {
        if (failureBlock) {
            failureBlock(error, NO);
        }
    };
    
    return task;
}

@end
