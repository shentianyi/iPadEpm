//
//  EpmMailListCell.h
//  EPM
//
//  Created by tianyi on 14-2-25.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmMailListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *receiver;
@property (weak, nonatomic) IBOutlet UIImageView *phtoIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *chartIndicator;

@end
