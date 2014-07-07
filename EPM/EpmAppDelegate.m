//
//  EpmAppDelegate.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmAppDelegate.h"
#import "NotificationViewController.h"
#import "AFNetworking.h"

@implementation EpmAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[MobClick startWithAppkey:@"531e863156240bea5d0869ad" reportPolicy:SEND_ON_EXIT channelId:@"InHouse"];
    
    
    UpdatePolicy policy = LATEST;
    
    @try {
        
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        
        NSString *toReplace = (NSString *)[EpmSettings getEpmUrlSettingsWithKey:@"version"];
        
        
        NSString* path  =[NSString stringWithFormat:@"%@%@%@%@",(NSString *)[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl" ],toReplace,@"?version=",version];
        
        NSLog(@"%@",path);
        
        NSURL* url = [NSURL URLWithString:path];
        
        NSString* jsonString = [[NSString alloc]initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        
        
        
        
        if(dic){
            if([[dic objectForKey:@"result"] boolValue]==YES) {
                if([[dic objectForKey:@"is_option"] boolValue]==YES){
                    policy = MUST;
                    
                }
                else {
                    policy = OPTION;
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   
    
    

    
    
    
    NSString *title = @"New version avilable";
    NSString *cancelTxt = @"No,thanks";
    NSString *otherTxt = @"Update now";

    if(policy== OPTION){
        UIAlertView *view = [[UIAlertView alloc ]initWithTitle:title message:nil delegate:self cancelButtonTitle:cancelTxt otherButtonTitles:otherTxt,nil];
        [view show ];
    }
    
    else if (policy == MUST){
        UIAlertView *view = [[UIAlertView alloc ]initWithTitle:title message:@"It's a mere update and you have to update to this version" delegate:self cancelButtonTitle:cancelTxt otherButtonTitles:otherTxt, nil];
        [view show ];
        
    }
    
        return YES;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-services://?action=download-manifest&url=http://121.199.48.53/clearinsight.plist"]];
    }
}




							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        UILocalNotification *notification=[[UILocalNotification alloc] init];
        if(notification!=nil){
            NSDate *now=[NSDate new];
            notification.fireDate=[now dateByAddingTimeInterval:3];
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.alertBody=@"你的主题有了新评论";
            notification.alertAction = @"打开";
            notification.applicationIconBadgeNumber=1;
            notification.soundName= UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    notification.applicationIconBadgeNumber=0;
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tbc = [storyboard instantiateViewControllerWithIdentifier:@"tabbar"];
    self.window.rootViewController = tbc;
//    [self presentViewController:tbc animated:YES completion:nil];
    
    
    
//    NotificationViewController *notificationVC=[[NotificationViewController alloc] init];
    
//     [self.window.rootViewController performSegueWithIdentifier:@"directToNotification" sender:self.window.rootViewController];
//    [self.window.rootViewController presentViewController:notificationVC
//                                                     animated:YES
//                                                  completion:nil];
//    UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
    tbc.selectedIndex = 4;

}
@end
