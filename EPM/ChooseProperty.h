//
//  ChooseProperty.h
//  ClearInsight
//
//  Created by wayne on 14-5-4.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseProperty : UITableViewController
@property (strong , nonatomic) NSDictionary *property;
@property (strong) void(^chosedAmount)(int amount);
@end
