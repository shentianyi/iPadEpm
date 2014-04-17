//
//  JBChartTooltipView.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 3/12/14.
//  Copyright (c) 2014 Jawbone. All rights reserved.
//

#import "JBChartTooltipView.h"
#define kJBFontTooltipText [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
#define kJBColorTooltipColor [UIColor colorWithWhite:1.0 alpha:0.9]
#define kJBColorTooltipTextColor UIColorFromHex(0x313131)
// Drawing
#import <QuartzCore/QuartzCore.h>

// Numerics
CGFloat static const kJBChartTooltipViewCornerRadius = 5.0;
CGFloat const kJBChartTooltipViewDefaultWidth = 55.0f;
CGFloat const kJBChartTooltipViewDefaultHeight = 40.0f;

@interface JBChartTooltipView ()

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation JBChartTooltipView

#pragma mark - Alloc/Init

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kJBChartTooltipViewDefaultWidth, kJBChartTooltipViewDefaultHeight)];
    if (self)
    {
        self.backgroundColor = kJBColorTooltipColor;
        self.layer.cornerRadius = kJBChartTooltipViewCornerRadius;
        
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = kJBFontTooltipText;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.numberOfLines = 1;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
        
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = kJBFontTooltipText;
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textColor = [UIColor blackColor];
        _valueLabel.adjustsFontSizeToFitWidth = YES;
        _valueLabel.numberOfLines = 1;
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_valueLabel];
    }
    return self;
}

#pragma mark - Setters

- (void)setText:(NSString *)text
{
    self.textLabel.text = text;
    [self setNeedsLayout];
}
- (void)setValue:(NSString *)value
{
    self.valueLabel.text = value;
    [self setNeedsLayout];
}
- (void)setTooltipColor:(UIColor *)tooltipColor
{
    self.backgroundColor = tooltipColor;
    [self setNeedsDisplay];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textLabel.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/2);
    _valueLabel.frame = CGRectMake(0, self.bounds.size.height/3+5, self.bounds.size.width, self.bounds.size.height/2);
}

@end
