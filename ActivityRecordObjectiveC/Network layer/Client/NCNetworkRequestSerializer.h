//
//  ACRequestSerializer.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

typedef void (^FailureBlock)(NSError* error, BOOL isCanceled);

@interface NCNetworkRequestSerializer : AFHTTPRequestSerializer <AFURLRequestSerialization>

- (NSMutableURLRequest *)serializeRequestWithMethod:(NSString *)method
                                               path:(NSString *)path
                                         parameters:(NSDictionary *)parameters
                                      customHeaders:(NSDictionary*)customHeaders
                                            failure:(FailureBlock)failureBlock;

#pragma mark - Download serialize
-(NSMutableURLRequest *)serializeRequestForDownloadingPath:(NSString*)path failure:(FailureBlock)failureBlock;

#pragma mark - Upload serialize
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path failure:(FailureBlock)failureBlock;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path fileURLs:(NSArray*)fileURLs failure:(FailureBlock)failureBlock;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path dataBlocks:(NSArray*)dataBlocks dataBlockNames:(NSArray*)dataBlockNames mimeTypes:(NSArray*)mimeTypes failure:(FailureBlock)failureBlock;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path images:(NSArray*)images imagesNames:(NSArray*)imagesNames failure:(FailureBlock)failureBlock;

#pragma mark - Utils

- (BOOL)imageHasAlphaChannel:(UIImage*)image;


@end
