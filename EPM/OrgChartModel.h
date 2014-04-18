//
//  OrgChartModel.h
//  ClearInsight
//
//  Created by wayne on 14-4-18.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrgChartModel : NSObject
@property(strong , nonatomic) NSString *average;
@property(strong , nonatomic) NSString *total;
@property(strong , nonatomic) NSString *unit;
@property(strong , nonatomic) NSString *targetMax;
@property(strong , nonatomic) NSString *targetMin;
@property(strong , nonatomic) NSString *currentMax;
@property(strong , nonatomic) NSString *currentMin;
@property(strong , nonatomic) NSMutableArray *current;
@property(strong , nonatomic) NSMutableArray *date;
@property(strong , nonatomic) NSMutableArray *entity;

+(instancetype)sharedChartDate;
-(void)updateData:(NSDictionary *)responds;
-(void)addCurrent:(NSArray *)current;
-(void)clearEntity;
@end
