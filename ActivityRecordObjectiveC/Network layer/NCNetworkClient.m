//
//  Phoenix.m
//  Phoenix
//
//  Created by Boroday on 25.04.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

#import "NCNetworkClient.h"

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
    NSURLSessionTask* task = [[NCNetworkClient networkClient] enqueueTaskWithMethod:@"GET" path:@"/info" parameters:@{@"get":@"gender"} customHeaders:nil success:^(id responseObject) {
        if (success) {
            NSDictionary* genderAttributes = nil;
            if (responseObject[@"gender"]) {
                if ([responseObject[@"gender"] isKindOfClass:[NSDictionary class]]) {
                    genderAttributes = [responseObject[@"gender"] copy];
                } else if (([responseObject[@"gender"] isKindOfClass:[NSArray class]]) &&
                           (((NSArray *)responseObject[@"gender"]).count == 2)) {
                    NSMutableDictionary *genderMut = [NSMutableDictionary new];
                    
                    genderMut[@"female"] = [(NSArray *)responseObject[@"gender"] firstObject];
                    genderMut[@"male"] = [(NSArray *)responseObject[@"gender"] lastObject];
                    genderAttributes = genderMut;
                } else if ([responseObject[@"gender"] isKindOfClass:[NSString class]]) {
                    NSMutableDictionary *genderMut = [NSMutableDictionary new];
                    genderMut[@"male"] = responseObject[@"gender"];
                    genderAttributes = genderMut;
                }
            }
            if (genderAttributes) {
            success(genderAttributes);
            } else {
#warning error wrong answer type
            }
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

