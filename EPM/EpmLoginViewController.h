//
//  EpmLoginViewController.h
//  EPM
//
//  Created by Shen Tianyi on 14-1-11.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Security;

@interface EpmLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *psw;
- (IBAction)btLogin:(UIButton *)sender;
- (IBAction)txtEnter:(UITextField *)sender;

@end
