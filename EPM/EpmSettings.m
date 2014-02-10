//
//  EpmSettings.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-17.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmSettings.h"

@implementation EpmSettings
+(NSString *)getEpmUrlSettingsWithKey:(NSString *)aKey{
   
    return [[[self class]urlSettings] objectForKey:aKey];
};

+(NSDictionary*) urlSettings {
    
    static  NSMutableDictionary *urls;
    
    static dispatch_once_t once;
    
    dispatch_once(&once,^{
         NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"urlSetting" ofType:@"plist"];
        
        urls   = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    });
    return urls;
};


@end
