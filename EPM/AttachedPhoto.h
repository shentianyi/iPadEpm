//
//  AttachedPhoto.h
//  EPM
//
//  Created by tianyi on 14-2-19.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachedPhoto : NSObject
@property (strong,nonatomic) NSString *photo_id;
@property (strong,nonatomic) UIImage *image;
-(id)initWithId;
-(id)initWithIdFilledAndImage:(UIImage *)image;

@end
