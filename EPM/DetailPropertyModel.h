//
//  DetailPropertyModel.h
//  ClearInsight
//
//  Created by wayne on 14-4-30.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailPropertyModel : NSObject
@property (strong , nonatomic) NSMutableArray *properties;

+(instancetype)sharedProperty;
+(void)FetchData:(NSString *)kpiID;
@end
