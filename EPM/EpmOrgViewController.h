//
//  EpmOrgViewController.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EpmOrgViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *hundred;
@property (weak, nonatomic) IBOutlet UIScrollView *bit;
@property (weak, nonatomic) IBOutlet UIScrollView *frequency;

@property (weak, nonatomic) IBOutlet UIView *upperContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *ten;
@property (weak, nonatomic) IBOutlet UIView *chartview;

//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong,nonatomic) NSArray *kpis;
@property(strong,nonatomic) NSDictionary *entityGroup;
@property (strong,nonatomic)NSDictionary *tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *chartHeadTime;
@property (weak, nonatomic) IBOutlet UILabel *chartHeadCompletion;
@property(strong,nonatomic) NSDictionary *preloadKpi;
@property (weak, nonatomic) IBOutlet UIView *chartHead;
@property (weak, nonatomic) IBOutlet UIView *chartBody;
@property (weak, nonatomic) IBOutlet UILabel *chartHeadValue;
@property (weak, nonatomic) IBOutlet UILabel *chartHeadTarget;



@end
