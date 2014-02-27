//
//  EpmGraphicUtility.h
//  EPM
//
//  Created by tianyi on 14-2-20.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EpmGraphicUtility : NSObject
+ (UIImage*)ScreenshotforView:(UIView*)view;
+ (UIImage*)FullScreenshotForCurrentWindow:(UIView *)window;
@end
