//
//  NotificationTableViewCell.m
//  ClearInsight
//
//  Created by wayne on 14-7-7.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "NotificationTableViewCell.h"
@interface NotificationTableViewCell()


@end
@implementation NotificationTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.content.adjustsFontSizeToFitWidth=YES;
    self.count.adjustsFontSizeToFitWidth=YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
