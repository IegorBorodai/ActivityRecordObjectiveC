//
//  PHNetworkManager.m
//  Phoenix
//
//  Created by Iegor Borodai on 1/23/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "NCNetworkManager.h"

#import "NCNetworkRequestSerializer.h"
#import "NCNetworkResponseSerializer.h"

#define MAX_CONCURENT_REQUESTS 100

typedef void (^failBlock)(NSError* error);

@interface NCNetworkManager ()


@property (nonatomic)                    AFNetworkReachabilityStatus           reachabilityStatus;
@property (nonatomic, strong, readwrite) AFHTTPSessionManager                  *manager;
@property (nonatomic, strong)            AFHTTPSessionManager                  *downloadManager;
@property (nonatomic, readwrite)         NSString                              *rootPath;
@property (nonatomic, readwrite)         NSURL                                 *baseURL;


@property (nonatomic, strong)           NCNetworkRequestSerializer            *networkRequestSerializer;

@end

@implementation NCNetworkManager

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
        
        self.networkRequestSerializer = [NCNetworkRequestSerializer serializer];
        
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:taskConfig];
        [self.manager setRequestSerializer:self.networkRequestSerializer];
        NCNetworkResponseSerializer* jsonSerializer = [NCNetworkResponseSerializer serializer];
        NSMutableSet* contentWithHTMLMutableSet = [jsonSerializer.acceptableContentTypes mutableCopy];
        [contentWithHTMLMutableSet addObject:@"text/html"];
        jsonSerializer.acceptableContentTypes = contentWithHTMLMutableSet;
        [self.manager setResponseSerializer:jsonSerializer];
        
        self.downloadManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:taskConfig];
        [self.downloadManager setRequestSerializer:self.networkRequestSerializer];
        
        AFImageResponseSerializer* imageSerializer = [AFImageResponseSerializer serializer];
        contentWithHTMLMutableSet = [imageSerializer.acceptableContentTypes mutableCopy];
        [contentWithHTMLMutableSet addObject:@"text/html"];
        imageSerializer.acceptableContentTypes = contentWithHTMLMutableSet;
        [self.downloadManager setResponseSerializer:imageSerializer];
        
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


- (NSURLSessionTask*)enqueueTaskWithMethod:(NSString*)method
                                      path:(NSString*)path
                                parameters:(NSDictionary*)parameters
                             customHeaders:(NSDictionary*)customHeaders
                                   success:(SuccessBlock)successBlock
                                   failure:(FailureBlock)failureBlock
{
    __block  NSError             *error = nil;
    NSURLSessionTask            *task = nil;
    
    if ([self checkReachabilityStatusWithError:&error]) {
        
        NSMutableURLRequest *request = [self.networkRequestSerializer serializeRequestWithMethod:method path:path parameters:parameters customHeaders:customHeaders error:&error];
        if (error) {
            failureBlock(error, NO);
        }
        task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                //            LOG_NETWORK(@"Response <<< : %li \n%@\n%@", (long)weakself.requestNumber, [NSString stringWithString:[weakself.urlRequest.URL absoluteString]], [[NSString alloc] initWithData:responseObject encoding: NSUTF8StringEncoding]);
                if (successBlock) {
                    successBlock(responseObject[@"data"]);
                }
            } else {
                BOOL requestCanceled = NO;
                if (error.code == 500 || error.code == 404 || error.code == -1011)
                {
                    //                NSString* path = [task.currentRequest.URL path];
                    //            LOG_NETWORK(@"STATUS: request %@ failed with error: %@", path, [error localizedDescription]);
                    error = [NSError errorWithDomain:error.domain
                                                               code:error.code
                                                           userInfo:@{NSLocalizedDescriptionKey: @"serverIsOnMaintenance"}];
                }
                else if (error.code == NSURLErrorCancelled)
                {
                    error = error;
                    requestCanceled = YES;
                }
                
                if (failureBlock) {
                    failureBlock(error,requestCanceled);
                }

            }
        }];
        
        [task resume];
        
        
    } else if (failureBlock) {
        failureBlock(error, NO);
    }
    
    return task;
}

#pragma mark - Download data


- (NSURLSessionTask*)downloadImageFromPath:(NSString*)path
                                   success:(SuccessImageBlock)successBlock
                                   failure:(FailureBlock)failureBlock
{
    NSError                     *error        = nil;
    NSURLSessionTask            *downloadTask = nil;
    
    if ([self checkReachabilityStatusWithError:&error]) {
        
        downloadTask = [self.downloadManager GET:path parameters:nil success:^(NSURLSessionDataTask *task, UIImage* image) {
            successBlock(image);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            failureBlock(error, NO);
        }];
        
        [downloadTask resume];
        
    } else if (failureBlock) {
        failureBlock(error, NO);
    }
    
    return downloadTask;
}


- (NSURLSessionDownloadTask*)downloadFileFromPath:(NSString*)path
                                       toFilePath:(NSString*)filePath
                                          success:(SuccessFileURLBlock)successBlock
                                          failure:(FailureBlock)failureBlock
                                         progress:(NSProgress * __autoreleasing *)progress
{
    __block NSError             *error        = nil;
    NSURLSessionDownloadTask    *downloadTask = nil;
    //    NSProgress                  *localProgress;
    
    if ([self checkReachabilityStatusWithError:&error]) {
        NSMutableURLRequest* request = [self.networkRequestSerializer serializeRequestForDownloadingPath:path error:&error];
        if (error) {
            failureBlock(error, NO);
        }
        downloadTask = [self.downloadManager downloadTaskWithRequest:request progress:progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSString* localFilePath = nil;
            if(!filePath) {
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                localFilePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [[[targetPath path] componentsSeparatedByString:@"/"] lastObject]]];
            }
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager moveItemAtPath:[targetPath path] toPath:filePath?:localFilePath error:&error];
            
            if (error) {
                //                LOG_GENERAL(@"FILE MOVE ERROR = %@", error.localizedDescription);
            }
            return [NSURL fileURLWithPath:filePath?:localFilePath];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (!error) {
                successBlock(filePath);
            } else {
                failureBlock(error, NO);
            }
        }];
        
        [downloadTask resume];
        
    } else if (failureBlock) {
#warning Add 500 & other handlers
        failureBlock(error, NO);
    }
    
    return downloadTask;
}

#pragma mark - Upload single data

- (NSURLSessionUploadTask*)uploadFileToPath:(NSString*)path
                                    fileURL:(NSURL*)fileURL
                                    success:(SuccessBlock)successBlock
                                    failure:(FailureBlock)failureBlock
                                   progress:(NSProgress * __autoreleasing *)progress
{
    __block NSError             *error      = nil;
    NSURLSessionUploadTask      *uploadTask = nil;
    
    if ([self checkReachabilityStatusWithError:&error]) {
        if (fileURL) {
            
            NSMutableURLRequest* request = [self.networkRequestSerializer serializeRequestForUploadingPath:path error:&error];
            if (error) {
                failureBlock(error, NO);
            }
            
            uploadTask = [self.manager uploadTaskWithRequest:request fromFile:fileURL progress:progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    successBlock(uploadTask);
                } else {
                    failureBlock(error, NO);
                }
            }];
        } else {
#warning Add 500 & other handlers
        }
    } else if (failureBlock) {
#warning Add 500 & other handlers
        failureBlock(error, NO);
    }
    
    return uploadTask;
}


- (NSURLSessionUploadTask*)uploadDataToPath:(NSString*)path
                                       data:(NSData*)data
                                    success:(SuccessBlock)successBlock
                                    failure:(FailureBlock)failureBlock
                                   progress:(NSProgress * __autoreleasing *)progress
{
    __block NSError             *error      = nil;
    NSURLSessionUploadTask      *uploadTask = nil;
    
    if ([self checkReachabilityStatusWithError:&error]) {
        if (data) {
            NSMutableURLRequest* request = [self.networkRequestSerializer serializeRequestForUploadingPath:path error:&error];
            if (error) {
                failureBlock(error, NO);
            }
            
            uploadTask = [self.manager uploadTaskWithRequest:request fromData:data progress:progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                if (!error) {
                    successBlock(uploadTask);
                } else {
                    failureBlock(error, NO);
                }
            }];
        } else
        {
#warning Add 500 & other handlers
        }
        
    } else if (failureBlock) {
#warning Add 500 & other handlers
        failureBlock(error, NO);
    }
    
    return uploadTask;
}

- (NSURLSessionUploadTask*)uploadImageToPath:(NSString*)path
                                       image:(UIImage*)image
                                     success:(SuccessBlock)successBlock
                                     failure:(FailureBlock)failureBlock
                                    progress:(NSProgress * __autoreleasing *)progress
{
    __block NSError             *error      = nil;
    NSURLSessionUploadTask      *uploadTask = nil;
    NSData                      *imageData  = nil;
    
    if ([image isKindOfClass:[UIImage class]]) {
        if([self.networkRequestSerializer imageHasAlphaChannel:image])
        {
            imageData = UIImagePNGRepresentation(image);
        }
        else
        {
            imageData = UIImageJPEGRepresentation(image, 1.0f);
        }
        
        uploadTask = [self uploadDataToPath:path data:imageData success:successBlock failure:false progress:progress];
    } else {
#warning Add 500 & other handlers
        failureBlock(error, NO);
    }
    
    return uploadTask;
}


#pragma mark - Upload multiple data

- (NSURLSessionTask*)uploadDataBlockToPath:(NSString*)path
                                dataBlocks:(NSArray*)dataBlocks
                            dataBlockNames:(NSArray*)dataBlockNames
                                 mimeTypes:(NSArray*)mimeTypes
                                   success:(SuccessBlock)successBlock
                                   failure:(FailureBlock)failureBlock
{
    __block NSError             *error        = nil;
    NSURLSessionTask            *uploadTask = nil;
    
    if ([self checkReachabilityStatusWithError:&error]) {
        NSMutableURLRequest* request = [self.networkRequestSerializer serializeRequestForUploadingPath:path dataBlocks:dataBlocks dataBlockNames:dataBlockNames mimeTypes:mimeTypes error:&error];
        
        if (error) {
            failureBlock(error, NO);
        }
        
        uploadTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                successBlock(uploadTask);
            } else {
                failureBlock(error, NO);
            }
        }];
    } else if (failureBlock) {
#warning Add 500 & other handlers
        failureBlock(error, NO);
    }
    
    return uploadTask;
}

- (NSURLSessionTask*)uploadImagesToPath:(NSString*)path
                                 images:(NSArray*)images
                             imageNames:(NSArray*)imageNames
                                success:(SuccessBlock)successBlock
                                failure:(FailureBlock)failureBlock
{
    __block NSError             *error        = nil;
    NSURLSessionTask            *uploadTask = nil;
    
    if ([self checkReachabilityStatusWithError:&error]) {
        NSMutableURLRequest* request = [self.networkRequestSerializer serializeRequestForUploadingPath:path images:images imagesNames:imageNames error:&error];
        
        if (error) {
            failureBlock(error, NO);
        }
        
        uploadTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                successBlock(uploadTask);
            } else {
                failureBlock(error, NO);
            }
        }];
    } else if (failureBlock) {
#warning Add 500 & other handlers
        failureBlock(error, NO);
    }
    
    return uploadTask;
}


- (NSURLSessionTask*)uploadFilesToPath:(NSString*)path
                              fileURLs:(NSArray*)fileURLs
                               success:(SuccessBlock)successBlock
                               failure:(FailureBlock)failureBlock
{
    __block NSError             *error        = nil;
    NSURLSessionTask            *uploadTask = nil;
    
    if ([self checkReachabilityStatusWithError:&error]) {
        NSMutableURLRequest* request = [self.networkRequestSerializer serializeRequestForUploadingPath:path fileURLs:fileURLs error:&error];
        
        if (error) {
            failureBlock(error, NO);
        }
        
        uploadTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (!error) {
                successBlock(uploadTask);
            } else {
                failureBlock(error, NO);
            }
        }];
    } else if (failureBlock) {
#warning Add 500 & other handlers
        failureBlock(error, NO);
    }
    
    return uploadTask;
}

@end
