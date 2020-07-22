//
//  UIImage+image.m
//  SwiftApp
//
//  Created by jia on 2020/5/8.
//  Copyright © 2020 RJ. All rights reserved.
//

#import "UIImage+image.h"

@implementation UIImage (image)
- (UIImage *)grayImage {
    // Adapted from this thread: http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
    const int RED =1;
    const int GREEN =2;
    const int BLUE =3;
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, self.size.width * self.scale, self.size.height * self.scale);
    int width = imageRect.size.width;
    int height = imageRect.size.height;
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t*) malloc(width * height *sizeof(uint32_t));
    // clear the pixels so any transparency is preserved
    memset(pixels,0, width * height *sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,8, width *sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), [self CGImage]);
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t*) &pixels[y * width + x];
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:UIImageOrientationUp];
    // we're done with image now too
    CGImageRelease(imageRef);
    return resultUIImage;
//    
//    int width = self.size.width;
//    int height = self.size.height;
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//    CGContextRef context = CGBitmapContextCreate (nil, width, height, 8, 0, colorSpace, kCGImageAlphaNone);
//    CGColorSpaceRelease(colorSpace);
//    if (context == NULL) {
//        return nil;
//    }
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
//    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
//    CGContextRelease(context);
//    return grayImage;
}

#pragma mark - 高斯模糊
- (UIImage *)gaussianBlur {
    //转换图片
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *midImage = [CIImage imageWithData:UIImagePNGRepresentation(self)];
    //图片开始处理
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:midImage forKey:kCIInputImageKey];
    //value 改变模糊效果值
    [filter setValue:@10.0f forKey:@"inputRadius"];
    CIImage *result =[filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage =[context createCGImage:result fromRect:[result extent]];
    //转化为 UIImage
    UIImage *resultImage =[UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return resultImage;
}

#pragma mark - 滤镜处理
- (UIImage *)setFilterWithFilterName:(NSString *)filterName {
    //转换图片
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *midImage = [CIImage imageWithData:UIImagePNGRepresentation(self)];
    //图片开始处理
    CIFilter *filter = [CIFilter filterWithName:filterName];
    @try {
        [filter setValue:midImage forKey:kCIInputImageKey];
    }
    @catch (NSException *exception) {
    } @finally {
    }
    CIImage *result =[filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage =[context createCGImage:result fromRect:[result extent]];
    //转化为 UIImage
    UIImage *resultImage =[UIImage imageWithCGImage:outImage];     CGImageRelease(outImage);
    return resultImage;
    
}

@end
