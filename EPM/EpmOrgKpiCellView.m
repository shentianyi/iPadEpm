//
//  EpmOrgKpiCellView.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmOrgKpiCellView.h"

@implementation EpmOrgKpiCellView
@synthesize label   = _label;
@synthesize desc     = _desc;
@synthesize category = _category;
@synthesize max =_max   ;
@synthesize min = _min  ;

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
