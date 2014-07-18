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
                                            failure:(FailureBlock)failureBlock
{
    NSMutableURLRequest *request = nil;
    
    request = [self requestWithMethod:method
                            URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString]
                           parameters:parameters
                              failure:failureBlock];
    
    if (customHeaders) {
        for (NSString* key in customHeaders) {
            [request addValue:customHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    return request;
}


#pragma - Download methods

-(NSMutableURLRequest *)serializeRequestForDownloadingPath:(NSString*)path failure:(FailureBlock)failureBlock
{
    NSMutableURLRequest *request = nil;
    
    request = [self requestWithMethod:@"GET"
                            URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString]
                           parameters:nil
                              failure:failureBlock];
    
    return request;
}


#pragma mark - Upload methods

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path failure:(FailureBlock)failureBlock
{
    NSMutableURLRequest *request = nil;
    
    request = [self requestWithMethod:@"POST"
                            URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString]
                           parameters:nil
                              failure:failureBlock];
    
    return request;
}

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path fileURLs:(NSArray*)fileURLs failure:(FailureBlock)failureBlock
{
    NSMutableURLRequest *request = nil;
    
    request = [self multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:[NCNetworkClient networkClient].baseURL] absoluteString] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError* localError = nil;
        for (NSURL* fileURL in fileURLs) {
            [formData appendPartWithFileURL:fileURL name:[fileURL lastPathComponent] error:&localError];
            if (localError) {
                //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
                failureBlock(localError, NO);
                break;
            }
        }
    } failure:failureBlock];
    
    return request;
}

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path dataBlocks:(NSArray*)dataBlocks dataBlockNames:(NSArray*)dataBlockNames mimeTypes:(NSArray*)mimeTypes failure:(FailureBlock)failureBlock
{
    NSMutableURLRequest *request = nil;
    __weak typeof(self)weakSelf = self;
    
    if (dataBlocks.count != mimeTypes.count) {
        NSError* error = [NSError errorWithDomain:@"Serialize" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Data blocks count must be equal to mime types"}];
        failureBlock(error, NO);
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
    } failure:failureBlock];
    
    return request;
}

-(NSMutableURLRequest *)serializeRequestForUploadingPath:(NSString*)path images:(NSArray*)images imagesNames:(NSArray*)imagesNames failure:(FailureBlock)failureBlock
{
    NSMutableURLRequest *request = nil;
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
        NSError* error = [NSError errorWithDomain:@"Serialize" code:1 userInfo:@{NSLocalizedDescriptionKey : @"Serialize only works with UIImage class objects"}];
            failureBlock(error, NO);
        }
    }
    
    request = [self serializeRequestForUploadingPath:path dataBlocks:dataArray dataBlockNames:imagesNames mimeTypes:mimeTypes failure:failureBlock];
    
    return request;
}


#pragma mark - Override default methods

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
								 URLString:(NSString *)URLString
								parameters:(NSDictionary *)parameters
                                   failure:(FailureBlock)failureBlock {
    
    NSError* localError = nil;
	NSMutableURLRequest *request = [super requestWithMethod:method
												  URLString:URLString
												 parameters:parameters
													  error:&localError];
    
    if (localError) {
        //        LOG_NETWORK(@"ERROR: serialize request: %@", [localError localizedDescription]);
        failureBlock(localError, NO);
        return request;
    }
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"hios8dc1c8e1" forHTTPHeaderField:@"App-Marker"];
    [request setValue:@"Bearer ca876a2lu2cicjmconihacq463" forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    return request;
    
}

-(NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block failure:(FailureBlock)failureBlock
{
    NSError* localError = nil;
    
    NSMutableURLRequest *request = [super multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:&localError];
    
    if (localError) {
        failureBlock(localError, NO);
        return request;
    }
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"hios8dc1c8e1" forHTTPHeaderField:@"App-Marker"];
    [request setValue:@"Bearer ca876a2lu2cicjmconihacq463" forHTTPHeaderField:@"Authorization"];
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
