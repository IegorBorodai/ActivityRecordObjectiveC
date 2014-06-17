//
//  ACRequestSerializer.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "NCNetworkRequest.h"
#import "UIImage+Extension.h"

@interface NCNetworkRequestSerializer : AFHTTPRequestSerializer <AFURLRequestSerialization>

-(NSMutableURLRequest *)serializeRequestFromNetworkRequest:(NCNetworkRequest*)networkRequest error:(NSError* __autoreleasing*)error;

-(NSMutableURLRequest *)serializeRequestForDownloadingPath:(NSString*)path error:(NSError* __autoreleasing*)error;

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path error:(NSError* __autoreleasing*)error;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path fileURLs:(NSArray*)fileURLs error:(NSError* __autoreleasing*)error;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path dataBlocks:(NSArray*)dataBlocks dataBlockNames:(NSArray*)dataBlockNames mimeTypes:(NSArray*)mimeTypes error:(NSError* __autoreleasing*)error;
-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path images:(NSArray*)images imagesNames:(NSArray*)imagesNames error:(NSError* __autoreleasing*)error;


@end
