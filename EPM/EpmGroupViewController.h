//
//  EpmGroupViewController.h
//  ClearInsight
//
//  Created by tianyi on 14-4-2.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmGroupViewController : UIViewController
@property(strong,nonatomic)NSDictionary *currentConditions;
@property (strong, nonatomic) IBOutlet UICollectionView *attributeCollection;
@property (weak, nonatomic) IBOutlet UIView *wrapView;
@end
