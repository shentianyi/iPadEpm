//
//  EpmMailListController.h
//  EPM
//
//  Created by tianyi on 14-2-25.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmMailListController : UIViewController
- (IBAction)compose:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UITextField *bigTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *openSendMailBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navigateItem;
@property (weak, nonatomic) IBOutlet UIImageView *mailToIcon;
@property (weak, nonatomic) IBOutlet UITextView *receiver;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UILabel *content;

@end
