//
//  Phoenix.m
//  Phoenix
//
//  Created by Boroday on 25.04.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

#import "PHPhoenix.h"
#import "PHInfoRequest.h"

static dispatch_once_t NetworkToken;
static PHNetworkManager *sharedNetworkClient = nil;

@implementation PHPhoenix

+ (BOOL)checkReachabilityStatus
{
    return [sharedNetworkClient checkReachabilityStatus];
}

+ (void)checkReachabilityStatusWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure
{
    return [sharedNetworkClient checkReachabilityStatusWithSuccess:success failure:failure];
}


#pragma mark - Sigleton methods

+ (PHNetworkManager *)HTTPClient
{
    dispatch_once(&NetworkToken, ^{
        sharedNetworkClient = [[PHNetworkManager alloc] initWithBaseURL:nil];
    });
	
    return sharedNetworkClient;
}

#pragma mark - Lifecycle

+ (void)initHTTPClientWithRootPath:(NSString*)baseURL
{
    dispatch_once(&NetworkToken, ^{
        sharedNetworkClient = [[PHNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
}

+ (NSURLSessionTask*)getGenderInfoWithSuccessBlock:(void (^)(NSDictionary *genderAttributes))success
                                             failure:(void (^)(NSError *error, BOOL isCanceled))failure
{
    PHInfoRequest * infoRequest = [PHInfoRequest new];
    NSURLSessionTask* task = [[PHPhoenix HTTPClient] enqueueOperationWithNetworkRequest:infoRequest success:^(NSURLSessionTask *operation) {
//        if (success) {
//            success(((PHInfoRequest*)operation.networkRequest).genderAttributes);
//        }
    } failure:failure];
    return task;
}


@end

