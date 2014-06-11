//
//  PHImageDownloadRequest.h
//  Phoenix
//
//  Created by Iegor Borodai on 1/30/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "NCNetworkRequest.h"

typedef NS_OPTIONS(NSUInteger, OutputType)
{
    OutputTypeImage,
    OutputTypeGIF,
};

@interface PHImageDownloadRequest : NCNetworkRequest

-(instancetype)initWithURL:(NSString*)url imageOutputType:(OutputType)type;

@property (nonatomic, readonly) OutputType outputType;
@property (nonatomic, strong) UIImage* image;

@end
