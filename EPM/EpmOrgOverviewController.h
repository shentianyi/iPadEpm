//
//  EpmOrgOverviewController.h
//  EPM
//
//  Created by tianyi on 14-2-28.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmOrgOverviewController : UIViewController


@property(strong,nonatomic) NSArray *kpis;

@property(strong,nonatomic) NSDictionary *entityGroup;

@property(strong,nonatomic) NSDictionary *tableData;

@property(strong,nonatomic) NSArray *contacts;

@property(strong,nonatomic) NSArray *mailList;

@property(strong,nonatomic) NSArray *mailSection;
@property (weak, nonatomic) IBOutlet UICollectionView *kpiCollection;

@property (weak, nonatomic) IBOutlet UILabel *kpiNumber;

@property (weak, nonatomic) IBOutlet UITableView *improveTable;

@property (weak, nonatomic) IBOutlet UICollectionView *contactCollection;

@property (weak, nonatomic) IBOutlet UILabel *entityGroupName;
@property (weak, nonatomic) IBOutlet UILabel *entityGroupDesc;

@end
