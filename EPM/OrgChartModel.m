//
//  OrgChartModel.m
//  ClearInsight
//
//  Created by wayne on 14-4-18.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "OrgChartModel.h"
#import "AFNetworking.h"
#import "EpmUtility.h"
@interface OrgChartModel()

@end
@implementation OrgChartModel
+(instancetype)sharedChartDate
{
    static OrgChartModel *chart=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        chart=[[self alloc] init];
    });
    return chart;
}
-(instancetype)init
{
    self=[super init];
    if(self){
        self.entity=[[NSMutableArray alloc] init];
    }
    return self;
}
//responds need add frequency
-(void)updateData:(NSDictionary *)responds
{
    self.date=[[responds objectForKey:@"date"] mutableCopy];
    for(int i=0;i<[self.date count];i++){
        [self.date replaceObjectAtIndex:i withObject:[EpmUtility convertDatetimeWithString:[[self.date objectAtIndex:i] substringToIndex:18] OfPattern:@"yyyy-MM-dd HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[responds objectForKey:@"frequency"] integerValue]]]];
    }
    if(!self.current){
       self.current=[[NSMutableArray alloc] init];
    }
    [self addCurrent:[responds objectForKey:@"current"]];
}
-(void)addCurrent:(NSArray *)current
{
    [self.current addObject:current];
    NSComparator cmptr = ^(id obj1, id obj2){
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    int tempCurrentMin=self.currentMin?[self.currentMin intValue]:[[current firstObject] intValue];
    int tempCurrentMax=self.currentMax?[self.currentMax intValue]:0;
    NSArray *currentOrderArray = [[current copy] sortedArrayUsingComparator:cmptr];
    NSLog(@"%@",currentOrderArray);
    tempCurrentMin=[[currentOrderArray firstObject] intValue]<tempCurrentMin?[[currentOrderArray firstObject] intValue]:tempCurrentMin;
    tempCurrentMax=[[currentOrderArray lastObject] intValue]>tempCurrentMax?[[currentOrderArray lastObject] intValue]:tempCurrentMax;
    self.currentMin=[NSString stringWithFormat:@"%d",tempCurrentMin];
    self.currentMax=[NSString stringWithFormat:@"%d",tempCurrentMax];
}
-(NSArray *)getCurrent
{
    return [self.current copy];
}
-(void)clearEntityAndCurrent{
    int count=self.entity.count;
    if(count>1){
        for(int i =1;i<count;i++){
            [self.entity removeLastObject];
        }
    }
    NSArray *current=[[self.current firstObject] copy];
    [self.current removeAllObjects];
    self.currentMax=nil;
    self.currentMin=nil;
    [self addCurrent:current];
}
@end
