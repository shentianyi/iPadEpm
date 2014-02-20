//
//  EpmSendMailController.h
//  EPM
//
//  Created by tianyi on 14-2-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EpmSendMailController : UIViewController
- (IBAction)btCancel:(UIBarButtonItem *)sender;
- (IBAction)btSend:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITextField *tfTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfNewMail;
- (IBAction)btAdd:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collViewList;
@property (weak, nonatomic) IBOutlet UITextField *tfContent;
@property (weak, nonatomic) IBOutlet UIView *viewAttached;
@property (weak, nonatomic) IBOutlet UILabel *lbEntityGroupName;
@property (weak, nonatomic) IBOutlet UILabel *lbRemark;
- (IBAction)titleTouch:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *wvChart;
- (IBAction)takePicture:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *attachCollection;
@property (strong,nonatomic) NSMutableDictionary *completeData;
@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UITextView *mailBody;
@end
