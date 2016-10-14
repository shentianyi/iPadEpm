//
//  DashboardCollectionViewController.h
//  ClearInsight
//
//  Created by wayne on 16/10/14.
//  Copyright © 2016年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardCollectionViewController : UICollectionViewController
@property (strong,nonatomic) NSArray *Organizations;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;
@end
