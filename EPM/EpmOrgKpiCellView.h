//
//  EpmOrgKpiCellView.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmOrgKpiCellView : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UILabel *max;
@property (weak, nonatomic) IBOutlet UILabel *min;
@property (weak, nonatomic) IBOutlet UIImageView *category;

@end
