//
//  EpmOrgCellView.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmOrgCellView : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *connectImg;
@property (weak, nonatomic) IBOutlet UILabel *connectTxt;
@property (weak, nonatomic) IBOutlet UIImageView *mainImg;
@property (weak, nonatomic) IBOutlet UILabel *orgName;
@property (weak, nonatomic) IBOutlet UIImageView *rightImg;
@property (weak, nonatomic) IBOutlet UILabel *orgDetail;
@end
