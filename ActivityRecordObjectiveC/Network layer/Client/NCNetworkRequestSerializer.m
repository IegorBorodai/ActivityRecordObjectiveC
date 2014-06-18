//
//  ACRequestSerializer.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "NCNetworkRequestSerializer.h"
#import "NCNetworkClient.h"

@implementation NCNetworkRequestSerializer

- (NSMutableURLRequest *)serializeRequestWithMethod:(NSString *)method
                                               path:(NSString *)path
                                         parameters:(NSDictionary *)parameters
                                      customHeaders:(NSDictionary*)customHeaders
                                              error:(NSError *__autoreleasing *)error
{
    NSMutableURLRequest *request = nil;
    __block NSError     *localError = nil;
    
    request = [self requestWithMethod:method
                            URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString]
                           parameters:parameters
                                error:&localError];
    
    if (localError && error != NULL) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = localError;
        return request;
    }
        
    for (NSString* key in customHeaders) {
        [request addValue:customHeaders[key] forHTTPHeaderField:key];
    }

    return request;
}


#pragma - Download methods

-(NSMutableURLRequest *)serializeRequestForDownloadingPath:(NSString*)path error:(NSError* __autoreleasing*)error
{
    NSMutableURLRequest *request = nil;
    __block NSError     *localError = nil;
    
    request = [self requestWithMethod:@"GET"
                            URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString]
                           parameters:nil
                                error:&localError];
    
    if (localError && error != NULL) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = localError;
        return request;
    }
    
    return request;
}


#pragma mark - Upload methods

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path error:(NSError* __autoreleasing*)error
{
    NSMutableURLRequest *request = nil;
    __block NSError     *localError = nil;
    
    request = [self requestWithMethod:@"POST"
                            URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString]
                           parameters:nil
                                error:&localError];
    
    if (localError && error != NULL) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = localError;
        return request;
    }
    
    return request;
}

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path fileURLs:(NSArray*)fileURLs error:(NSError* __autoreleasing*)error
{
    NSMutableURLRequest *request = nil;
    __block NSError     *localError = nil;
    
    request = [self multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (NSURL* fileURL in fileURLs) {
            [formData appendPartWithFileURL:fileURL name:[fileURL lastPathComponent] error:&localError];
        }
    } error:&localError];
    
    if (localError && error != NULL) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = localError;
        return request;
    }
    
    return request;
}

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path dataBlocks:(NSArray*)dataBlocks dataBlockNames:(NSArray*)dataBlockNames mimeTypes:(NSArray*)mimeTypes error:(NSError* __autoreleasing*)error
{
    NSMutableURLRequest *request = nil;
    __block NSError     *localError = nil;
    __weak typeof(self)weakSelf = self;
    
    if (dataBlocks.count != mimeTypes.count) {
#warning Add error message
        
        return request;
    }
    
    request = [self  multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSUInteger count = 0;
        for (NSData* data in dataBlocks) {

            NSString   *fileName = @"";
            if (dataBlockNames && (count < dataBlockNames.count)) {
                fileName = dataBlockNames[count];
            } else {
                CFStringRef mimeType = (__bridge_retained CFStringRef)mimeTypes[count];
                NSString *uti = (__bridge_transfer NSString*)(UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL));
                CFRelease(mimeType);
                
                fileName = [weakSelf temporaryFileNameForUTI: uti];
            }
            
            [formData appendPartWithFileData:data
                                        name:fileName
                                    fileName:@"PhotoUploadForm[file]" //fileName
                                    mimeType:mimeTypes[count]];
            ++count;
        }
    } error:&localError];
    
    if (localError && error != NULL) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = localError;
        return request;
    }
    
    return request;
}

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path images:(NSArray*)images imagesNames:(NSArray*)imagesNames error:(NSError* __autoreleasing*)error
{
    NSMutableURLRequest *request = nil;
    __block NSError     *localError = nil;
    NSMutableArray      *dataArray = [NSMutableArray new];
    NSMutableArray      *mimeTypes = [NSMutableArray new];
    
    for (UIImage* image in imagesNames) {
        NSString   *uti = @"";
        NSData*    imageData = nil;
        if ([image isKindOfClass:[UIImage class]]) {
            if([self imageHasAlphaChannel:image])
            {
                imageData = UIImagePNGRepresentation(image);
                uti = (NSString*)kUTTypePNG;
            }
            else
            {
                imageData = UIImageJPEGRepresentation(image, 1.0f);
                uti = (NSString*)kUTTypeJPEG;
            }
            
            [dataArray addObject:imageData];
            [mimeTypes addObject:[self mimeTypeForImageUTI: uti]];
        } else {
#warning Add error for missed image
        }
    }
    
    request = [self serializeRequestForUploadingPath:path dataBlocks:dataArray dataBlockNames:imagesNames mimeTypes:mimeTypes error:&localError];
    
    if (localError && error != NULL) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        *error = localError;
        return request;
    }
    
    return request;
//
//    
//    
////    __weak typeof(self)weakSelf = self;
//    
//    request = [self  multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient HTTPClient].baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        
//        NSUInteger count = 0;
//        for (UIImage* image in imagesNames) {
//            if ([image isKindOfClass:[UIImage class]]) {
//                NSString   *uti = @"";
//                NSData*    imageData = nil;
//                NSString   *fileName = @"";
//                
//                if([image hasAlphaChannel])
//                {
//                    imageData = UIImagePNGRepresentation(image);
//                    uti = (NSString*)kUTTypePNG;
//                }
//                else
//                {
//                    imageData = UIImageJPEGRepresentation(image, 1.0f);
//                    uti = (NSString*)kUTTypeJPEG;
//                }
//                
//                if (imagesNames && (count < imagesNames.count)) {
//                    fileName = imagesNames[count];
//                } else {
//                    fileName = [weakSelf temporaryFileNameForUTI: uti];
//                }
//                
//                if (imageData) {
//                    [formData appendPartWithFileData:imageData
//                                                name:fileName
//                                            fileName:@"PhotoUploadForm[file]" //fileName
//                                            mimeType:[UIImage mimeTypeForImageUTI: uti]];
//                }
//            }
//            ++count;
//        }
//        
//    } error:&localError];
//
}


#pragma mark - Override default methods

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
								 URLString:(NSString *)URLString
								parameters:(NSDictionary *)parameters
									 error:(NSError *__autoreleasing *)error {
	NSMutableURLRequest *request = [super requestWithMethod:method
												  URLString:URLString
												 parameters:parameters
													  error:error];
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"hios8dc1c8e1" forHTTPHeaderField:@"App-Marker"];
//    [request setValue:@"Bearer qrjjo5jrmmh9loq1saha57iu77" forHTTPHeaderField:@"Authorization"];
//    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    return request;
    
}

-(NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block error:(NSError *__autoreleasing *)error
{
    NSMutableURLRequest *request = [super multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"hios8dc1c8e1" forHTTPHeaderField:@"App-Marker"];
    [request setValue:@"Bearer qrjjo5jrmmh9loq1saha57iu77" forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}

#pragma mark - Support methods

- (NSString*)temporaryFileNameForUTI:(NSString*)uti
{
	NSString* extension = [self pathExtensionForImageUTI: uti];
	
    if([extension isEqualToString:@"jpeg"])
    {
        extension = @"jpg";
    }
    
	NSString* fileName = [[@"tempLocalsGoWildImage_" stringByAppendingString:[self currentTimeString]]
						  stringByAppendingPathExtension: extension];
	
	return fileName;
}

- (NSString*)currentTimeString
{
	NSDateFormatter *formatter;
	NSString        *dateString;
	
	formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd-MM-yyyy_HH_mm_ss"];
	
	dateString = [formatter stringFromDate:[NSDate date]];
    
	return dateString;
}

- (BOOL)imageHasAlphaChannel:(UIImage*)image
{
	BOOL imageContainsAlpha = YES;
	
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(image.CGImage);
	
	if(alphaInfo == kCGImageAlphaNone)
	{
		imageContainsAlpha = NO;
		
	} else if(alphaInfo == kCGImageAlphaNoneSkipFirst)
	{
		imageContainsAlpha = NO;
		
	} else if(alphaInfo == kCGImageAlphaNoneSkipLast)
	{
		imageContainsAlpha = NO;
	}
	
	return imageContainsAlpha;
}

- (NSString*)pathExtensionForImageUTI:(NSString*)uti
{
	NSDictionary* utiInfo = (__bridge NSDictionary*)UTTypeCopyDeclaration((__bridge CFStringRef)uti);
	NSDictionary* tagInfo = utiInfo[(NSString*)kUTTypeTagSpecificationKey];
	
    CFRelease((CFDictionaryRef)utiInfo);
    
	NSString* extension = tagInfo[(NSString*)kUTTagClassFilenameExtension];
	
	if([extension isKindOfClass: [NSArray class]])
	{
		NSArray* extensions = (NSArray*)extension;
		
		return extensions[0];
	}
	
	return extension;
}

- (NSString*)mimeTypeForImageUTI:(NSString*)uti
{
	NSDictionary* utiInfo = (__bridge NSDictionary*)UTTypeCopyDeclaration((__bridge CFStringRef)uti);
	NSDictionary* tagInfo = utiInfo[(NSString*)kUTTypeTagSpecificationKey];
	
    CFRelease((CFDictionaryRef)utiInfo);
    
	NSString* mime = tagInfo[(NSString*)kUTTagClassMIMEType];
	
	if([mime isKindOfClass: [NSArray class]])
	{
		NSArray* mimes = (NSArray*)mime;
		
		return mimes[0];
	}
	
	return mime;
}


@end
