//
//  UIImageExtension.h
//  TouchAVision
//
//  Created by Stanislav Kovalchuk on 04.07.11.
//  Copyright 2011 iGeneration Ukraine. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface UIImage (UIImageExtension)

+ (UIImage*)downscaledImage:(UIImage*)image;
+ (UIImage*)thumbnailForImage:(UIImage*)image;
+ (UIImage *)resizeImage:(UIImage *)image width:(int)width height:(int)height;
+ (UIImage *)clipImage:(UIImage *)image frame:(CGRect)rect;
- (UIImage*)decompressedImage;

- (UIImage*)createTitleImageWithSize:(CGSize) sizeOfTitle;
- (UIImage*)normalizedImage;
- (UIImage*)imageThatFillsSize:(CGSize)size;
- (UIImage*)makeImageWithCornerRadius:(float)radius borderColor:(UIColor*)borderColor borderWidth:(float)borderWidth;
- (UIImage*)cutBorderFromAvatarWidth:(CGFloat)borderWidth;

- (BOOL)hasAlphaChannel;

+ (NSString*)pathExtensionForImageUTI:(NSString*)uti;
+ (NSString*)mimeTypeForImageUTI:(NSString*)uti;

- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)scaleProportionalToSize: (CGSize)size withCrop:(BOOL)crop topIndent:(CGFloat)topIndent;
- (UIImage *)faceImageFromImage:(CIDetector *)faceDetector;
- (UIImage *)blurImage;
- (UIImage *)fixOrientation;
- (UIImage *)colorizeImageWithColor:(UIColor *)color;

@end
