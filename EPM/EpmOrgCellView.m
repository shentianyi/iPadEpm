//
//  EpmOrgCellView.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmOrgCellView.h"

@implementation EpmOrgCellView
@synthesize connectImg = _connectImg;
@synthesize connectTxt = _connectTxt;
@synthesize mainImg = _mainImg;
@synthesize orgName = _orgName;
@synthesize orgDetail = _orgDetail;
@synthesize rightImg = _rightImg;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
