//
//  Phoenix.h
//  localsgowild
//
//  Created by Artem Rizhov on 28.01.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//


#import "PHNetworkManager.h"

@interface PHPhoenix : NSObject

// Public
+ (void)initHTTPClientWithRootPath:(NSString*)baseURL;

// Singletons
+ (PHNetworkManager *)HTTPClient;

// Network status
+ (BOOL)checkReachabilityStatus;
+ (void)checkReachabilityStatusWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

//Requests
+ (NSURLSessionTask*)getGenderInfoWithSuccessBlock:(void (^)(NSDictionary *genderAttributes))success
                                             failure:(void (^)(NSError *error, BOOL isCanceled))failure;

@end
