//
//  EpmTableCell.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-14.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *value;
@property (weak, nonatomic) IBOutlet UILabel *range;
@property (weak, nonatomic) IBOutlet UILabel *inrange;
@property (weak, nonatomic) IBOutlet UIImageView *trend;
@property (weak, nonatomic) IBOutlet UIView *chart;

@end
