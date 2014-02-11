//
//  EpmOrgCollectionController.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmOrgCollectionController : UICollectionViewController
@property (strong,nonatomic) NSArray *Organizations;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;

@end
