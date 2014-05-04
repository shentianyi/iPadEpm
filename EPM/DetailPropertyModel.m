//
//  DetailPropertyModel.m
//  ClearInsight
//
//  Created by wayne on 14-4-30.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "DetailPropertyModel.h"
@interface DetailPropertyModel()

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

        self.properties=[[NSMutableArray alloc] init];
        
        for(NSString *keyid in settings){
            NSMutableDictionary *wrapDic=[[NSMutableDictionary alloc] init];
            [wrapDic setObject:keyid forKey:@"id"];
            for(NSString *keyname in settings[keyid]){
                [wrapDic setObject:keyname forKey:@"name"];
                [wrapDic setObject:[settings[keyid][keyname] mutableCopy] forKey:@"property"];
            }
            [wrapDic setObject:[NSMutableDictionary dictionary] forKey:@"checked"];
            [self.properties addObject:wrapDic];
        }

    }
    return self;
}
@end
