//
//  DetailCompareChart.h
//  ClearInsight
//
//  Created by wayne on 14-5-4.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailCompareChart : UIViewController
@property (strong , nonatomic) NSArray *data;
@property (strong , nonatomic) NSMutableArray *date;
@property (strong , nonatomic) NSNumber *frequency;
@property (strong, nonatomic) NSString *label;
@end
