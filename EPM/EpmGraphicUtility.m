//
//  EpmGraphicUtility.m
//  EPM
//
//  Created by tianyi on 14-2-20.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmGraphicUtility.h"

@implementation EpmGraphicUtility
+ (UIImage*)ScreenshotforView:(UIView*)view{
    CGRect rect = [view bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return capturedImage;
}


+ (UIImage*)FullScreenshotForCurrentWindow:(UIView *)window{
//    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
//    
//    CGRect rect = [keyWindow bounds];
//    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [keyWindow.layer renderInContext:context];
//    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return capturedScreen;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(window.bounds.size);
   
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end
