//
//  EpmUtility.m
//  EPM
//
//  Created by tianyi on 14-2-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmUtility.h"

@implementation EpmUtility
+(BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}




+ (NSString *) convertDatetimeWithDate:(NSDate *)date WithFormat:(NSString *) format {

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSString *) convertDatetimeWithString:(NSString *)dateString WithFormat:(NSString *) format{

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *date = [formatter dateFromString:dateString];
    return [EpmUtility convertDatetimeWithDate:date WithFormat:format];
}

+ (NSString *) convertDatetimeWithString:(NSString *)dateString OfPattern:(NSString *)pattern WithFormat:(NSString *) format{
    
    NSLog(@"###########PARTTERN :%@",pattern);
    //pattern=@"yyyy-MM-dd HH:mm:ss";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
   [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:pattern];
    NSLog(@"###########datestring :%@",dateString);
    NSDate *date = [formatter dateFromString:dateString];
   NSLog(@"############date :%@",date); 
    
    return [EpmUtility convertDatetimeWithDate:date WithFormat:format];
}

+(NSString *)timeStringOfFrequency:(int)frequency{
    NSString *format=@"";
    if(frequency == 100) {
        	format = @"yyyy-MM-dd";
    }
    else if(frequency==200) {
        format = @"yyyy 'week' w";
    
    }
    else if(frequency==300) {
        format = @"yyyy MMM";
    }
    else if(frequency==400) {
        format = @"yyyy QQQ";
        
    }
    else if(frequency==500) {
        format = @"yyyy";
    }
    
    return format;

}
@end
