//
//  DetailCompareChart.m
//  ClearInsight
//
//  Created by wayne on 14-5-4.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "DetailCompareChart.h"
#import "JBBarChartView.h"
#import "JBBarChartFooterView.h"
#import "JBChartTooltipTipView.h"
#import "JBChartTooltipView.h"
#import "EpmUtility.h"

//CGFloat const kJBBarChartViewControllerChartFooterHeight = 30.0f;
//CGFloat const kJBBarChartViewControllerChartFooterPadding = 5.0f;
//CGFloat const kJBBarChartViewControllerChartPadding = 10.0f;

@interface DetailCompareChart ()<JBBarChartViewDataSource,JBBarChartViewDelegate>
@property (nonatomic, strong) JBChartTooltipView *tooltipView;
@property (nonatomic, strong) JBChartTooltipTipView *tooltipTipView;
@property (nonatomic, assign) BOOL tooltipVisible;
@property (strong, nonatomic) JBBarChartView *barChartView;

@end

@implementation DetailCompareChart

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.barChartView=[[JBBarChartView alloc] init];
    self.barChartView.frame=CGRectMake(25, 70, 500, 270);
    [self.view addSubview:self.barChartView];
    self.barChartView.dataSource=self;
    self.barChartView.delegate=self;
    self.barChartView.mininumValue=0.0f;
    [self.barChartView reloadData];
    
    for(int i=0;i<[self.date count];i++){
    [self.date replaceObjectAtIndex:i withObject:[EpmUtility convertDatetimeWithString:[[self.date objectAtIndex:i] substringToIndex:19] OfPattern:@"yyyy-MM-dd'T'HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[self.frequency intValue]]]];
    }
    
    
    JBBarChartFooterView *footerView = [[JBBarChartFooterView alloc] initWithFrame:CGRectMake(10.0f, ceil(self.view.bounds.size.height * 0.5) - ceil(30.0f * 0.5), self.view.bounds.size.width - (10.0f * 2), 30.0f)];
    footerView.padding = 5.0f;
    footerView.leftLabel.text = [self.date firstObject];
    footerView.leftLabel.textColor = [UIColor blackColor];
    footerView.rightLabel.text = [self.date lastObject];
    footerView.rightLabel.textColor = [UIColor blackColor];
    self.barChartView.footerView = footerView;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UILabel *label=[[UILabel alloc] init];
    label.text=self.label;
    [label sizeToFit];
    label.frame=CGRectMake(30, 22, 300, 50);
    [self.view addSubview:label];
    
    UILabel *labelTitle=[[UILabel alloc] init];
    labelTitle.text=@"Compare in last 10 years";
    labelTitle.frame=CGRectMake(30, 0, 300, 50);
    labelTitle.font=[UIFont systemFontOfSize:21];
    [self.view addSubview:labelTitle];
}

#pragma jbbar delegate
- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return [self.data count]; // number of bars in chart
}
- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{

    return [self.data[index] floatValue]; // height of bar at index
}
- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setText:[NSString stringWithFormat:@"%@",self.date[index]]];
    [self.tooltipView setValue:[NSString stringWithFormat:@"%@",self.data[index]]];
}

- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
{
    [self setTooltipVisible:NO animated:YES];
}



- (UIView *)barChartView:(JBBarChartView *)barChartView barViewAtIndex:(NSUInteger)index
{
    UIView *barView = [[UIView alloc] init];
    barView.backgroundColor=[UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1.0];
    return barView; // color of line in chart
}
- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [[UIColor redColor] colorWithAlphaComponent:0.5]; // color of selection view
}

//tooltip
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint
{
    self.tooltipVisible = tooltipVisible;
    JBChartView *chartView = self.barChartView;
    
    if (!self.tooltipView)
    {
        self.tooltipView = [[JBChartTooltipView alloc] init];
        self.tooltipView.alpha = 0.0;
        [self.view addSubview:self.tooltipView];
    }
    
    if (!self.tooltipTipView)
    {
        self.tooltipTipView = [[JBChartTooltipTipView alloc] init];
        self.tooltipTipView.alpha = 0.0;
        [self.view addSubview:self.tooltipTipView];
    }
    
    dispatch_block_t adjustTooltipPosition = ^{
        CGPoint originalTouchPoint = [self.view convertPoint:touchPoint fromView:chartView];
        CGPoint convertedTouchPoint = originalTouchPoint; // modified
        JBChartView *chartView = self.barChartView;
        
        if (chartView)
        {
            CGFloat minChartX = (chartView.frame.origin.x + ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x < minChartX)
            {
                convertedTouchPoint.x = minChartX;
            }
            CGFloat maxChartX = (chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x > maxChartX)
            {
                convertedTouchPoint.x = maxChartX;
            }
            self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5), self.barChartView.frame.origin.y+85, self.tooltipView.frame.size.width, self.tooltipView.frame.size.height);
            
            CGFloat minTipX = (chartView.frame.origin.x + self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x < minTipX)
            {
                originalTouchPoint.x = minTipX;
            }
            CGFloat maxTipX = (chartView.frame.origin.x + chartView.frame.size.width - self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x > maxTipX)
            {
                originalTouchPoint.x = maxTipX;
            }
            self.tooltipTipView.frame = CGRectMake(originalTouchPoint.x - ceil(self.tooltipTipView.frame.size.width * 0.5),self.barChartView.frame.origin.y+85+self.tooltipView.frame.size.height, self.tooltipTipView.frame.size.width, self.tooltipTipView.frame.size.height);
        }
    };
    
    dispatch_block_t adjustTooltipVisibility = ^{
        self.tooltipView.alpha = _tooltipVisible ? 1.0 : 0.0;
        self.tooltipTipView.alpha = _tooltipVisible ? 1.0 : 0.0;
	};
    
    if (tooltipVisible)
    {
        adjustTooltipPosition();
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.25f animations:^{
            adjustTooltipVisibility();
        } completion:^(BOOL finished) {
            if (!tooltipVisible)
            {
                adjustTooltipPosition();
            }
        }];
    }
    else
    {
        adjustTooltipVisibility();
    }
}
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated
{
    [self setTooltipVisible:tooltipVisible animated:animated atTouchPoint:CGPointZero];
}


@end
