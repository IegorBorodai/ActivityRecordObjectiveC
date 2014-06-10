//
//  Phoenix.m
//  Phoenix
//
//  Created by Boroday on 25.04.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

#import "NCNetworkClient.h"
#import "PHInfoRequest.h"

static dispatch_once_t NetworkToken;
static NCNetworkManager *sharedNetworkClient = nil;

@implementation NCNetworkClient

- (BOOL)checkReachabilityStatusWithError:(NSError* __autoreleasing*)error;
{
    return [sharedNetworkClient checkReachabilityStatusWithError:error];
}

#pragma mark - Sigleton methods

+ (NCNetworkManager *)HTTPClient
{
    dispatch_once(&NetworkToken, ^{
        sharedNetworkClient = [[NCNetworkManager alloc] initWithBaseURL:nil];
    });
	
    return sharedNetworkClient;
}

#pragma mark - Lifecycle

+ (void)initHTTPClientWithRootPath:(NSString*)baseURL
{
    dispatch_once(&NetworkToken, ^{
        sharedNetworkClient = [[NCNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    });
}

+ (NSURLSessionTask*)getGenderInfoWithSuccessBlock:(void (^)(NSDictionary *genderAttributes))success
                                             failure:(void (^)(NSError *error, BOOL isCanceled))failure
{
    PHInfoRequest * infoRequest = [PHInfoRequest new];
    NSURLSessionTask* task = [[NCNetworkClient HTTPClient] enqueueTaskWithNetworkRequest:infoRequest success:^(NSURLSessionTask *task) {
        if (success) {
            success(infoRequest.genderAttributes);
        }
    } failure:failure progress:nil];
    return task;
}


@end

