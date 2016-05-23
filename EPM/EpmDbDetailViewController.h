//
//  EpmDbDetailViewController.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmDbDetailViewController : UIViewController
@property(strong,nonatomic) NSString *dashboardId;
@property(strong,nonatomic)NSString *entityGroupId;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end
