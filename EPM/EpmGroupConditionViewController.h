//
//  EpmGroupConditionViewController.h
//  ClearInsight
//
//  Created by tianyi on 14-4-3.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmGroupConditionViewController : UITableViewController
@property(strong,nonatomic) NSString *kpiId;
//@property (strong,nonatomic) NSString *selected;

//wayne
@property(strong , nonatomic) NSArray *entities;
@property (strong,nonatomic) NSDictionary *selected;
@property(strong , nonatomic) void (^dismiss)();
@end
