//
//  DetailPropertyModel.m
//  ClearInsight
//
//  Created by wayne on 14-4-30.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "DetailPropertyModel.h"
@interface DetailPropertyModel()
@property (strong , nonatomic) NSMutableArray *dimension;
@property (strong , nonatomic) NSMutableArray *properties;
@end

@implementation DetailPropertyModel
+(instancetype)sharedProperty
{
    static DetailPropertyModel *propertyModel=nil;
    if(!propertyModel){
        propertyModel=[[self alloc] initPrivate];
    }
    return propertyModel;
}
-(instancetype)initPrivate
{
    self=[super init];
    if(self){
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"propertyFake" ofType:@"plist"];
        NSDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"%@",settings);
        
        self.dimension=[[NSMutableArray alloc] init];
        self.properties=[[NSMutableArray alloc] init];
    }
    return self;
}
@end
