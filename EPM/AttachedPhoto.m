//
//  AttachedPhoto.m
//  EPM
//
//  Created by tianyi on 14-2-19.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "AttachedPhoto.h"

@implementation AttachedPhoto
@synthesize image = _image;
@synthesize photo_id = _photo_id;

-(id)initWithId {
    if(self=[super init]){
        self.photo_id = [[NSUUID UUID] UUIDString];
    }

    return self;
}

-(id)initWithIdFilledAndImage:(UIImage *)image{
    if(self=[super init]){
        self.photo_id = [[NSUUID UUID] UUIDString];
        self.image = image;
    }
    return self;
}

@end
