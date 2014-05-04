//
//  EpmGroupDetailTableViewCell.h
//  ClearInsight
//
//  Created by tianyi on 14-4-3.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmGroupDetailTableViewCell : UITableViewCell
- (IBAction)tapCompare:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *conditionTitle;
@property (weak, nonatomic) IBOutlet UILabel *conditionValue;
@property (weak, nonatomic) IBOutlet UILabel *conditionPercentage;
@property (weak, nonatomic) IBOutlet UILabel *conditionLast;
@property (weak, nonatomic) IBOutlet UILabel *conditionLastPercent;
@property (weak, nonatomic) IBOutlet UIImageView *conditionLastTrend;
@property (copy, nonatomic) void(^compare)();

@end
