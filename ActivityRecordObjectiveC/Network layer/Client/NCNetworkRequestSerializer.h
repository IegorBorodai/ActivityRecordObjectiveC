//
//  ACRequestSerializer.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

@interface NCNetworkRequestSerializer : AFHTTPRequestSerializer <AFURLRequestSerialization>

- (NSMutableURLRequest *)serializeRequestWithMethod:(NSString *)method
                                               path:(NSString *)path
                                         parameters:(NSDictionary *)parameters
                                      customHeaders:(NSDictionary*)customHeaders
                                              error:(NSError *__autoreleasing *)error;

#pragma mark - Download serialize
-(NSMutableURLRequest *)serializeRequestForDownloadingPath:(NSString*)path error:(NSError* __autoreleasing*)error;

#pragma mark - Upload serialize
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path error:(NSError* __autoreleasing*)error;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path fileURLs:(NSArray*)fileURLs error:(NSError* __autoreleasing*)error;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path dataBlocks:(NSArray*)dataBlocks dataBlockNames:(NSArray*)dataBlockNames mimeTypes:(NSArray*)mimeTypes error:(NSError* __autoreleasing*)error;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path images:(NSArray*)images imagesNames:(NSArray*)imagesNames error:(NSError* __autoreleasing*)error;

#pragma mark - Utils

- (BOOL)imageHasAlphaChannel:(UIImage*)image;


@end
