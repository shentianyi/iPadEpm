//
//  EpmUrlFiner.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-17.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EpmHttpUtil : NSObject
+ (NSString*) escapeUrl:(NSString*)aUrl;
+ (NSMutableURLRequest *) addCookiesforRequest:(NSMutableURLRequest *)request;
+ (NSMutableURLRequest *) initWithCookiesWithUrl:(NSURL *)aUrl;
+ (int) getLastHttpStatusCodeWithRequest:(NSURLRequest*)aRequest;
+ (NSString *) notificationWithStatusCode:(int)statusCode;
@end
