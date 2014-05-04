//
//  OrgDeailAttributeCellView.m
//  ClearInsight
//
//  Created by wayne on 14-4-28.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "OrgDeailAttributeCellView.h"

@interface OrgDeailAttributeCellView()
- (IBAction)tapCollectionCell:(id)sender;
@end

@implementation OrgDeailAttributeCellView

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

- (IBAction)tapCollectionCell:(id)sender {
    if(self.tapCollection){
        self.tapCollection();
    }
}
@end
