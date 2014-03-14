//
//  EpmUtility.h
//  EPM
//
//  Created by tianyi on 14-2-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EpmUtility : NSObject
+ (BOOL) validateEmail: (NSString *) candidate ;
+ (NSString *) convertDatetimeWithDate:(NSDate *)date WithFormat:(NSString *) format;
+ (NSString *) convertDatetimeWithString:(NSString *)dateString WithFormat:(NSString *) format;
+ (NSString *) convertDatetimeWithString:(NSString *)dateString OfPattern:(NSString *)pattern WithFormat:(NSString *) format;
+(NSString *)timeStringOfFrequency:(int)frequency;

@end
