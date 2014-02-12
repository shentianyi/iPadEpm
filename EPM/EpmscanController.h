//
//  EpmscanController.h
//  EPM
//
//  Created by tianyi on 14-2-12.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmscanController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *modalView;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UIImageView *contact1;
@property (weak, nonatomic) IBOutlet UIImageView *contact2;
- (IBAction)details:(UIButton *)sender;
- (IBAction)newScan:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *contactCollection;

@property (weak, nonatomic) IBOutlet UILabel *name;
@end
