//
//  EpmAppDelegate.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    LATEST = 0,       //无更新
    OPTION = 1,          //有更新，但可选
    MUST = 2,      //必须更新
  
} UpdatePolicy;
@interface EpmAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
