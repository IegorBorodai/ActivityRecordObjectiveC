//
//  PHNetworkManager.h
//  Phoenix
//
//  Created by Iegor Borodai on 1/23/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

typedef void (^SuccessBlock)(id jsonResponse);
typedef void (^SuccessImageBlock)(UIImage *image);
typedef void (^SuccessFileURLBlock)(NSURL *fileURL);
typedef void (^FailureBlock)(NSError* error, BOOL isCanceled);
typedef void (^FailureBlockWithOperation)(NSURLSessionTask* task, NSError* error, BOOL isCanceled);

@interface NCNetworkManager : NSObject

@property (nonatomic, readonly)    NSURL                                 *baseURL;
@property (nonatomic, readonly)    AFHTTPSessionManager                  *manager;

- (id)initWithBaseURL:(NSURL*)url;

- (BOOL)checkReachabilityStatusWithError:(NSError* __autoreleasing*)error;

- (NSURLSessionTask*)enqueueTaskWithMethod:(NSString*)method
                                      path:(NSString*)path
                                parameters:(NSDictionary*)parameters
                             customHeaders:(NSDictionary*)customHeaders
                                   success:(SuccessBlock)successBlock
                                   failure:(FailureBlock)failureBlock;


#pragma mark - Download data

- (NSURLSessionTask*)downloadImageFromPath:(NSString*)path
                                   success:(SuccessImageBlock)successBlock
                                   failure:(FailureBlock)failureBlock;

- (NSURLSessionDownloadTask*)downloadFileFromPath:(NSString*)path
                                       toFilePath:(NSString*)filePath
                                          success:(SuccessFileURLBlock)successBlock
                                          failure:(FailureBlock)failureBlock
                                         progress:(NSProgress * __autoreleasing *)progress;


#pragma mark - Upload single data

- (NSURLSessionUploadTask*)uploadFileToPath:(NSString*)path
                                    fileURL:(NSURL*)fileURL
                                    success:(SuccessBlock)successBlock
                                    failure:(FailureBlock)failureBlock
                                   progress:(NSProgress * __autoreleasing *)progress;

- (NSURLSessionUploadTask*)uploadDataToPath:(NSString*)path
                                    data:(NSData*)data
                                    success:(SuccessBlock)successBlock
                                    failure:(FailureBlock)failureBlock
                                   progress:(NSProgress * __autoreleasing *)progress;

- (NSURLSessionUploadTask*)uploadImageToPath:(NSString*)path
                                    image:(UIImage*)image
                                    success:(SuccessBlock)successBlock
                                    failure:(FailureBlock)failureBlock
                                   progress:(NSProgress * __autoreleasing *)progress;


#pragma mark - Upload multiple data

- (NSURLSessionTask*)uploadDataBlockToPath:(NSString*)path
                                dataBlocks:(NSArray*)dataBlocks
                            dataBlockNames:(NSArray*)dataBlockNames
                                 mimeTypes:(NSArray*)mimeTypes
                                   success:(SuccessBlock)successBlock
                                   failure:(FailureBlock)failureBlock;

- (NSURLSessionTask*)uploadImagesToPath:(NSString*)path
                                 images:(NSArray*)images
                             imageNames:(NSArray*)imageNames
                                success:(SuccessBlock)successBlock
                                failure:(FailureBlock)failureBlock;

- (NSURLSessionTask*)uploadFilesToPath:(NSString*)path
                                    fileURLs:(NSArray*)fileURLs
                                    success:(SuccessBlock)successBlock
                                    failure:(FailureBlock)failureBlock;



@end
