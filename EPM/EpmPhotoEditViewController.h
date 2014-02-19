//
//  EpmPhotoEditViewController.h
//  EPM
//
//  Created by tianyi on 14-2-19.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachedPhoto.h"

@interface EpmPhotoEditViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *text;
@property (strong,nonatomic) NSString *operation;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *drawingImage;
@property (strong,nonatomic) AttachedPhoto *editedPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (strong,nonatomic) AttachedPhoto *backGround;
@end
