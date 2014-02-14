//
//  PNBarChart.h
//  PNChartDemo
//
//  Created by kevin on 11/7/13.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define chartMargin     10
//#define xLabelMargin    15
//#define yLabelMargin    15
//#define yLabelHeight    11

#define chartMargin     0
#define xLabelMargin    0
#define yLabelMargin    0
#define yLabelHeight    0

@interface PNBarChart : UIView

/**
 * This method will call and stroke the line in animation
 */

-(void)strokeChart;

@property (strong, nonatomic) NSArray * xLabels;

@property (strong, nonatomic) NSArray * yLabels;

@property (strong, nonatomic) NSArray * yValues;

@property (nonatomic) CGFloat xLabelWidth;

@property (nonatomic) int yValueMax;

@property (nonatomic, strong) UIColor * strokeColor;

@property (nonatomic, strong) NSArray * strokeColors;

@property (nonatomic, strong) UIColor * barBackgroundColor;

@property (nonatomic) BOOL showLabel;

@end
