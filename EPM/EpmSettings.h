//
//  EpmSettings.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-17.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EpmSettings : NSObject
+(NSString *)getEpmUrlSettingsWithKey:(NSString *)aKey;
+(NSDictionary*) urlSettings;

@end
