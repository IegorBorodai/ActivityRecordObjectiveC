//
//  PHImageDownloadRequest.m
//  Phoenix
//
//  Created by Iegor Borodai on 1/30/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHImageDownloadRequest.h"
//#import "UIImage+AnimatedGIF.h"

@interface PHImageDownloadRequest ()
@property (nonatomic, readwrite) OutputType outputType;
@end

@implementation PHImageDownloadRequest

- (instancetype)initWithURL:(NSString*)url imageOutputType:(OutputType)type
{
    (self = [super init]);
    if (self) {
        _outputType = type;
        _path = url;
		_method = @"GET";
//        _autorizationRequired = NO;
    }
    return self;
}

- (BOOL)parseJSON:(id)responseObject error:(NSError* __autoreleasing *)error;
{
    NSData* imageData = nil;
    
    if ([responseObject isKindOfClass:[NSURL class]] ) {
        imageData = [NSData dataWithContentsOfFile:[(NSURL*)responseObject path]];
    } else if ([responseObject isKindOfClass:[NSData class]] ) {
        imageData = responseObject;
    }
    
    if (imageData) {
        
//        if (self.outputType == OutputTypeGIF) {
//            self.image = [UIImage animatedImageWithAnimatedGIFData:imageData];
//        }
//        else {
            self.image = [UIImage imageWithData:imageData];
//        }
        if (self.image) {
            if ([responseObject isKindOfClass:[NSURL class]] ) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError* error = nil;
                [fileManager removeItemAtPath:[(NSURL*)responseObject path] error:&error];
                if (error) {
//                    LOG_GENERAL(@"REMOVE FILE AFTER DOWNLOAD ERROR = %@", error.localizedDescription);
                }
            }
            return YES;
        }
    }
    return NO;
}

@end
