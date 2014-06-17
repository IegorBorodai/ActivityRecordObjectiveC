//
//  Phoenix.m
//  Phoenix
//
//  Created by Boroday on 25.04.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

#import "NCNetworkClient.h"
#import "PHInfoRequest.h"

static dispatch_once_t networkToken;
static NCNetworkManager *sharedNetworkClient = nil;

@implementation NCNetworkClient

- (BOOL)checkReachabilityStatusWithError:(NSError* __autoreleasing*)error;
{
    return [sharedNetworkClient checkReachabilityStatusWithError:error];
}

#pragma mark - Sigleton methods

+ (NCNetworkManager *)networkClient
{
    dispatch_once(&networkToken, ^{
        sharedNetworkClient = [[NCNetworkManager alloc] initWithBaseURL:nil];
    });
	
    return sharedNetworkClient;
}

#pragma mark - Lifecycle

+ (void)initNetworkClientWithRootPath:(NSString*)baseURL;
{
    dispatch_once(&networkToken, ^{
        sharedNetworkClient = [[NCNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
}

+ (NSURLSessionTask*)getGenderInfoWithSuccessBlock:(void (^)(NSDictionary *genderAttributes))success
                                             failure:(void (^)(NSError *error, BOOL isCanceled))failure
{
    PHInfoRequest * infoRequest = [PHInfoRequest new];
    NSURLSessionTask* task = [[NCNetworkClient networkClient] enqueueTaskWithNetworkRequest:infoRequest success:^(NSURLSessionTask *task) {
        if (success) {
            success(infoRequest.genderAttributes);
        }
    } failure:failure];
    return task;
}


+ (NSURLSessionTask*)downloadImageFromPath:(NSString*)path success:(void (^)(UIImage* image))success
                                           failure:(void (^)(NSError *error, BOOL isCanceled))failure
                                          progress:(NSProgress*)progress
{
    NSURLSessionTask* downloadTask = [[NCNetworkClient networkClient] downloadImageFromPath:path success:success failure:failure];
    return downloadTask;
}

+ (NSURLSessionDownloadTask*)downloadFileFromPath:(NSString*)path
                                       toFilePath:(NSString*)filePath
                                          success:(SuccessFileURLBlock)successBlock
                                          failure:(FailureBlock)failureBlock
                                         progress:(NSProgress* __autoreleasing *)progress
{
    NSURLSessionDownloadTask* downloadTask = [[NCNetworkClient networkClient] downloadFileFromPath:path toFilePath:filePath success:successBlock failure:failureBlock progress:progress];
    return downloadTask;
}


@end

