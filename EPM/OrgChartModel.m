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
//    NSLog(@"orgChartModel receive %@",responds);
    self.date=[[responds objectForKey:@"date"] mutableCopy];
    self.dateStandard=[[responds objectForKey:@"date"] mutableCopy];
//    NSLog(@"%@",self.date);
    for(int i=0;i<[self.date count];i++){
//        NSLog(@"%@",[self.date objectAtIndex:i]);
        [self.date replaceObjectAtIndex:i withObject:[EpmUtility convertDatetimeWithString:[[self.date objectAtIndex:i] substringToIndex:19] OfPattern:@"yyyy-MM-dd'T'HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[responds objectForKey:@"frequency"] intValue]]]];
    }
    if(!self.current){
       self.current=[[NSMutableArray alloc] init];
       self.units=[[NSMutableArray alloc] init];
    }
    [self addCurrent:[responds objectForKey:@"current"]];
    [self addUnit:[responds objectForKey:@"unit"]];
}
-(void)addCurrent:(NSArray *)current
{
    [self.current addObject:current];
}
-(void)addUnit:(NSArray *)unit
{
    [self.units addObject:unit];
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
-(void)clearAll
{
    [self.date removeAllObjects];
    [self.entity removeAllObjects];
    [self.current removeAllObjects];
    self.currentMax=nil;
    self.currentMin=nil;
}
-(NSString *)getCurrentMin{
    int min;
    for(int i=0;i<self.current.count;i++){
        NSArray *currentSingle=self.current[i];
        for(int j=0;j<currentSingle.count;j++){
            if(i==0 && j==0){
                min=[currentSingle[j] intValue];
            }
            else{
                min=[currentSingle[j] intValue]<min?[currentSingle[j] intValue]:min;
            }
        }
    }
    return [NSString stringWithFormat:@"%d",min];
}
-(NSString *)getCurrentMax{
    int max=0;
    for(int i=0;i<self.current.count;i++){
        NSArray *currentSingle=self.current[i];
        for(int j=0;j<currentSingle.count;j++){
                max=[currentSingle[j] intValue]>max?[currentSingle[j] intValue]:max;
        }
    }
    return [NSString stringWithFormat:@"%d",max];
}
@end
