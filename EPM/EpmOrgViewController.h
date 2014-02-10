//
//  EpmOrgViewController.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmOrgViewController : UIViewController


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong,nonatomic) NSArray *kpis;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(strong,nonatomic) NSDictionary *entityGroup;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong,nonatomic)NSDictionary *tableData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
