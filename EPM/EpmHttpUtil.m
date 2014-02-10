//
//  EpmUrlFiner.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-17.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmHttpUtil.h"

@implementation EpmHttpUtil

+ (NSString *) notificationWithStatusCode:(int)statusCode{
    NSString *msg;
    if (statusCode==401){
        msg = @"You are not login, please login again";
    }
    else if(statusCode==403){
        msg = @"Sorry, you are not authorized to view the content";
    }
    else {
        msg = @"You might encounter an unknown problem. Try later.";
    }
    return msg;
}


+(NSString *)escapeUrl:(NSString *)aUrl {
    return [aUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}



+ (NSMutableURLRequest*) addCookiesforRequest:(NSMutableURLRequest *)request{
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    [request setHTTPShouldHandleCookies:YES];
    
    if ([cookies count] > 0)
    {
        NSHTTPCookie *cookie;
        NSString *cookieHeader = nil;
        for (cookie in cookies)
        {
            if (!cookieHeader)
            {
                cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
            }
            else
            {
                cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
            }
        }
        if (cookieHeader)
        {
            [request setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
        }
    }
    
    return request;
}


+(NSMutableURLRequest *) initWithCookiesWithUrl:(NSURL *)aUrl {
   NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:aUrl];
    return  [[self class]addCookiesforRequest:request];
}


+ (int) getLastHttpStatusCodeWithRequest:(NSURLRequest*)aRequest{
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:aRequest];
    return [[[(NSHTTPURLResponse*)resp.response allHeaderFields] objectForKey:@"Status"] intValue];
};



@end
