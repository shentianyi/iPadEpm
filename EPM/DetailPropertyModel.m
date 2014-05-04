//
//  DetailPropertyModel.m
//  ClearInsight
//
//  Created by wayne on 14-4-30.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "DetailPropertyModel.h"
#import "AFNetworking.h"
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
+(void)FetchData:(NSString *)kpiID
{
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    NSString *attributeAddress=[EpmSettings getEpmUrlSettingsWithKey:@"groupAttrbute"];
    NSString *baseAddress=[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],attributeAddress];
    NSString *getAddress=[baseAddress stringByAppendingPathComponent:kpiID];
    [manager GET:getAddress
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *settings = responseObject;
             DetailPropertyModel *model=[DetailPropertyModel sharedProperty];
             model.properties=[[NSMutableArray alloc] init];
             for(NSString *keyid in settings){
                 NSMutableDictionary *wrapDic=[[NSMutableDictionary alloc] init];
                 [wrapDic setObject:keyid forKey:@"id"];
                 for(NSString *keyname in settings[keyid]){
                     [wrapDic setObject:keyname forKey:@"name"];
                     [wrapDic setObject:[settings[keyid][keyname] mutableCopy] forKey:@"property"];
                 }
                 [wrapDic setObject:[NSMutableDictionary dictionary] forKey:@"checked"];
                 [model.properties addObject:wrapDic];
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             int statusCode = [operation.response statusCode];
             
             NSString *msg=[EpmHttpUtil notificationWithStatusCode:statusCode];
             
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                          message:@""
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];
         }];
}
-(instancetype)initPrivate
{
    self=[super init];
    if(self){
        //在这里请求KPI相应地attribute数据
        //真实数据下面全部都要注释掉
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
