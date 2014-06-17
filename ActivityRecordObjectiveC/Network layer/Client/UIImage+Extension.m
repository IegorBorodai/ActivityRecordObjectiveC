
//  UIImageExtension.m
//  TouchAVision
//
//  Created by Stanislav Kovalchuk on 04.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

#import "UIImage+Extension.h"
@import MobileCoreServices;
#import "LoggingDefs.h"

#define MAX_RENDERED_IMAGE_SIZE CGSizeMake(1024, 1024)
#define MAX_THUMBNAIL_IMAGE_SIZE CGSizeMake(256, 256)

@implementation UIImage (UIImageExtension)

+ (UIImage*)downscaledImage:(UIImage*)image
{
	//scale down the image. We do not want to render huge images in the conext
	//because of performance issues
	CGSize renderedImageSize = image.size;
	
	float imageAspect = image.size.width / image.size.height;
	
	if(renderedImageSize.width > MAX_RENDERED_IMAGE_SIZE.width)
	{
		renderedImageSize.width = (int)(MAX_RENDERED_IMAGE_SIZE.width);
		renderedImageSize.height = (int)(renderedImageSize.width / imageAspect);
	}
	
	if(renderedImageSize.height > MAX_RENDERED_IMAGE_SIZE.height)
	{
		renderedImageSize.height = (int)(MAX_RENDERED_IMAGE_SIZE.height);
		renderedImageSize.width = (int)(renderedImageSize.height * imageAspect);
	}
	
    CGSize size = CGSizeMake(renderedImageSize.width, renderedImageSize.height);
    
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(0,
												 size.width,
												 size.height,
												 8,
												 4 * size.width,
												 colorspace,
                                                 kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
	
    if (!context) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
    
    // Draw the original image to the context
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, renderedImageSize.width, renderedImageSize.height), image.CGImage);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	UIImage* imageOut = [UIImage imageWithCGImage:imageRef];
	
	CGColorSpaceRelease(colorspace);
	CGContextRelease(context);
	CGImageRelease(imageRef);
	
    return imageOut;
}

+ (UIImage*)thumbnailForImage:(UIImage*)image
{
	//scale down the image. We do not want to render huge images in the conext
	//because of performance issues
	CGSize renderedImageSize = image.size;
	
	float imageAspect = image.size.width / image.size.height;
	
	if(renderedImageSize.width > MAX_THUMBNAIL_IMAGE_SIZE.width)
	{
		renderedImageSize.width = (int)(MAX_THUMBNAIL_IMAGE_SIZE.width);
		renderedImageSize.height = (int)(renderedImageSize.width / imageAspect);
	}
	
	if(renderedImageSize.height > MAX_THUMBNAIL_IMAGE_SIZE.height)
	{
		renderedImageSize.height = (int)(MAX_THUMBNAIL_IMAGE_SIZE.height);
		renderedImageSize.width = (int)(renderedImageSize.height * imageAspect);
	}
	
    CGSize size = CGSizeMake(renderedImageSize.width, renderedImageSize.height);
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(0,
												 size.width,
												 size.height,
												 8,
												 4 * size.width,
												 colorspace,
                                                 kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
	
    if (!context) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
    
    // Draw the original image to the context
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, renderedImageSize.width, renderedImageSize.height), image.CGImage);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	UIImage* imageOut = [UIImage imageWithCGImage:imageRef];
	
	CGColorSpaceRelease(colorspace);
	CGContextRelease(context);
	CGImageRelease(imageRef);
	
    return imageOut;
}

+(UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height
{
	CGImageRef imageRef = [image CGImage];
    CGBitmapInfo bitmapInfo = kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast;
	
	CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), 4 * width, CGImageGetColorSpace(imageRef), bitmapInfo);
    if (!bitmap) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
	CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;
}

+(UIImage *)clipImage:(UIImage *)image frame:(CGRect)rect
{
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	
	UIImage* result  = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return result;
}


//static inline double radians (double degrees) {return degrees * M_PI/180;}

- (UIImage*)decompressedImage
{
    return [self normalizedImage];
}

- (UIImage*)createTitleImageWithSize:(CGSize) titleSize
{
    UIImage* source = self;
    
    //    CGSize titleSize = CGSizeMake([[SettingsManager shared] videoSize].width, 88);
    
    CGRect imageFrame = CGRectZero;
    imageFrame.size = source.size;
    
    CGImageRef imageRef = [source CGImage];
    CGBitmapInfo bitmapInfo = kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast;
	
	CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                titleSize.width,
                                                titleSize.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4 * titleSize.width,
                                                CGImageGetColorSpace(imageRef),
                                                bitmapInfo);
    if (!bitmap) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
	CGContextDrawTiledImage(bitmap, imageFrame, source.CGImage);
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage *result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return result;
}

- (UIImage *)normalizedImage
{
    UIImage* image = self;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
//        default:
//            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
	
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(0,
												 (int)bounds.size.width,
												 (int)bounds.size.height,
												 8,
												 4 * ((int)bounds.size.width),
												 colorspace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    if (!context) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, 0, -bounds.size.height);
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
	{
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else
	{
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
	CGImageRef img = CGBitmapContextCreateImage(context);
	UIImage *imageCopy = [UIImage imageWithCGImage:img
											 scale:self.scale
									   orientation:UIImageOrientationUp];
    
	CGImageRelease(img);
	CGContextRelease(context);
	CGColorSpaceRelease(colorspace);
    
    return imageCopy;
}

- (UIImage*)imageThatFillsSize:(CGSize)size
{
	UIImage* normalizedImage = [self normalizedImage];
	
	CGRect drawRect;
	
	float resultRatio = size.width / size.height;
	float imageRatio = normalizedImage.size.width / normalizedImage.size.height;
	
	if(resultRatio > imageRatio)
	{
		drawRect.size.width = size.width;
		drawRect.size.height = size.width / imageRatio;
	}
	else
	{
		drawRect.size.height = size.height;
		drawRect.size.width = size.height * imageRatio;
	}
	
	drawRect.origin.x = (size.width - drawRect.size.width) / 2.0f;
	drawRect.origin.y = (size.height - drawRect.size.height) / 2.0f;
	
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextTranslateCTM(context, 0, size.height);
	CGContextScaleCTM(context, 1, -1);
	
	CGContextDrawImage(context, drawRect, normalizedImage.CGImage);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (UIImage*)makeImageWithCornerRadius:(float)radius borderColor:(UIColor*)borderColor borderWidth:(float)borderWidth
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    imageLayer.contents = (id) self.CGImage;
    imageLayer.cornerRadius = radius + 2;
    imageLayer.masksToBounds = YES;
    
    CALayer *imageLayerBorder = [CALayer layer];
    imageLayerBorder.frame = CGRectMake(0, 0, self.size.width, self.size.height);
    imageLayerBorder.cornerRadius = radius;
    imageLayerBorder.borderColor = borderColor.CGColor;
    imageLayerBorder.borderWidth = borderWidth;
    imageLayerBorder.masksToBounds = YES;
    
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    mainViewContentContext = CGBitmapContextCreate (NULL, self.size.width, self.size.height, 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    if (!mainViewContentContext) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(mainViewContentContext, 0, self.size.height);
    CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
    //    UIGraphicsBeginImageContext(self.size);
    [imageLayer renderInContext:mainViewContentContext];
    [imageLayerBorder renderInContext:mainViewContentContext];
    
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    // convert the finished resized image to a UIImage
    UIImage *roundedImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
    // image is retained by the property setting above, so we can
    // release the original
    CGImageRelease(mainViewContentBitmapContext);
    
    //    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    return roundedImage;
}

- (UIImage *)cutBorderFromAvatarWidth:(CGFloat)borderWidth
{
    CGRect maskRect = CGRectMake(borderWidth, borderWidth, self.size.width - 2*borderWidth, self.size.height - 2*borderWidth);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], maskRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}


- (BOOL)hasAlphaChannel
{
	BOOL imageContainsAlpha = YES;
	
	CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
	
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

+ (NSString*)pathExtensionForImageUTI:(NSString*)uti
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

+ (NSString*)mimeTypeForImageUTI:(NSString*)uti
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


- (UIImage *) scaleToSize: (CGSize)size
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast);
    if (!context) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(self.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage: scaledImage];
    
    CGImageRelease(scaledImage);
    
    return image;
}

- (UIImage *) scaleToSize: (CGSize)size andCropToSize:(CGSize)cropSize
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast);
    if (!context) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(self.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    }
    else
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect( scaledImage, CGRectMake(0,0, cropSize.width, cropSize.height));
    
    UIImage *image = [UIImage imageWithCGImage: newImageRef];
    
    CGImageRelease(newImageRef);
    CGImageRelease(scaledImage);
    
    return image;
}


- (UIImage *)scaleToSize:(CGSize)size andCropToRect:(CGRect)cropRect
{
    // Scalling selected image to targeted size
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast);
    if (!context) {
//        LOG_GENERAL_L(2, @"ERROR: CGBitmapContextCreate");
    }
    CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
    
    if(self.imageOrientation == UIImageOrientationRight)
    {
        CGContextRotateCTM(context, -M_PI_2);
        CGContextTranslateCTM(context, -size.height, 0.0f);
        CGContextDrawImage(context, CGRectMake(0, 0, size.height, size.width), self.CGImage);
    }
    else {
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    }
    
    CGImageRef scaledImage=CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    CGImageRef newImageRef = CGImageCreateWithImageInRect(scaledImage, cropRect);
    
    UIImage *image = [UIImage imageWithCGImage: newImageRef];
    
    CGImageRelease(newImageRef);
    CGImageRelease(scaledImage);
    
    return image;
}


- (UIImage *)scaleProportionalToSize: (CGSize)size withCrop:(BOOL)crop topIndent:(CGFloat)topIndent
{
    CGFloat scaleK = 1;
    CGFloat scaleKHeight = 1;
    CGFloat scaleKWidth = 1;
    
    scaleKHeight = size.height / self.size.height;
    scaleKWidth = size.width / self.size.width;
    
    scaleK = MAX(scaleKHeight, scaleKWidth);
    
    CGSize aspectRatioSize;
    aspectRatioSize.height = scaleK * self.size.height;
    aspectRatioSize.width = scaleK * self.size.width;
    
    if (crop) {
        CGFloat cropX = (aspectRatioSize.width - size.width) / 2;
        return [self scaleToSize:aspectRatioSize andCropToRect:CGRectMake(cropX, topIndent, size.width, size.height)];
    }
    else {
        return [self scaleToSize:aspectRatioSize];
    }
}

- (UIImage *)faceImageFromImage:(CIDetector *)faceDetector
{
    CIImage *cIImage = [CIImage imageWithCGImage:self.CGImage];
    //CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
    
    NSArray *features = [faceDetector featuresInImage:cIImage];
    if (features && features.count > 0)
    {
        CIFaceFeature *faceFeature = features[0];
        
        CGFloat faceImageX = faceFeature.bounds.origin.x;
        CGFloat faceImageY = self.size.height - faceFeature.bounds.size.height - faceFeature.bounds.origin.y;
        CGFloat faceImageWidth = faceFeature.bounds.size.width;
        CGFloat faceImageHeight = faceFeature.bounds.size.height;
        
        CGRect faceImageRect = CGRectMake(faceImageX, faceImageY, faceImageWidth, faceImageHeight);
        
        if (features.count > 1)
        {
            for (NSUInteger i = 1; i < features.count; i++)
            {
                CIFaceFeature *faceFeature = features[i];
                
                if (faceFeature.bounds.origin.x < faceImageX)
                {
                    faceImageX = faceFeature.bounds.origin.x;
                }
                if (self.size.height - faceFeature.bounds.size.height - faceFeature.bounds.origin.y < faceImageY)
                {
                    faceImageY = self.size.height - faceFeature.bounds.size.height - faceFeature.bounds.origin.y;
                }
                if (faceFeature.bounds.origin.x + faceFeature.bounds.size.width > faceImageWidth)
                {
                    faceImageWidth = (faceFeature.bounds.origin.x + faceFeature.bounds.size.width) - faceImageX;
                }
                if (faceFeature.bounds.origin.y + faceFeature.bounds.size.height > faceImageHeight)
                {
                    faceImageHeight = (faceFeature.bounds.origin.y + faceFeature.bounds.size.height) - faceImageY;
                }
            }
            
            faceImageRect = CGRectMake(faceImageX, faceImageY, faceImageWidth, faceImageHeight);
        }
        
        CGImageRef cgFaceImage = CGImageCreateWithImageInRect(self.CGImage, faceImageRect);
        UIImage *faceImage = [UIImage imageWithCGImage:cgFaceImage];
        CGImageRelease(cgFaceImage);
        
        return faceImage;
    }
    else
    {
        return nil;
    }
}

- (UIImage *)blurImage
{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:8.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *resImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return resImage;
}

- (UIImage *)fixOrientation
{
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
    {
        return self;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

- (UIImage *)colorizeImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContext(self.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -area.size.height);
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, area, self.CGImage);
    
    [color set];
    CGContextFillRect(context, area);
    
    CGContextRestoreGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    CGContextDrawImage(context, area, self.CGImage);
    
    UIImage *colorizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return colorizedImage;
}


@end
