//
//  EpmDbDetailViewController.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmDbDetailViewController.h"
#import "EpmAppDelegate.h"

@interface EpmDbDetailViewController ()

@end

@implementation EpmDbDetailViewController
//@synthesize dashboardId = _dashboardId;
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    [UIView setAnimationsEnabled:NO];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
  //  [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.tabBarController.tabBar.hidden=YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    [UIView setAnimationsEnabled:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:NO];
    
    [UIView setAnimationsEnabled:NO];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    
    self.tabBarController.tabBar.hidden=NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:NO];
    [UIView setAnimationsEnabled:YES];

}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSLog(@"----------------------");
    NSLog(self.dashboardId);
    
     self.webView.delegate = self;
    [self BeginLoadWeb];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)BeginLoadWeb
{
    NSString *urlTxt;
    if(self.dashboardId){
      urlTxt =[NSString stringWithFormat:@"%@%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],@"/reports?from_ipad=true&part=",self.dashboardId];
    }else if(self.entityGroupId){
    urlTxt =[NSString stringWithFormat:@"%@%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],@"/reports?from_ipad=true&part=103&entity_group_id=",self.entityGroupId];
    }
    
   //NSString *urlTxt =[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey:@"dash"]];
    
    urlTxt = [EpmHttpUtil escapeUrl:urlTxt];
      NSURL* url = [[ NSURL alloc ] initWithString :urlTxt];
    NSMutableURLRequest *request = [EpmHttpUtil initWithCookiesWithUrl:url];
    
    [self.webView loadRequest:request];

}



- (void )webViewDidStartLoad:(UIWebView *)webView {
    [self.indicator startAnimating];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
    
    int status = [EpmHttpUtil getLastHttpStatusCodeWithRequest:self.webView.request];
    
    if (status>=400){
        NSString *msg;
        
        msg = [EpmHttpUtil notificationWithStatusCode:status];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}


//-  (void)didRotateFromInterfaceOrientation:
//(UIInterfaceOrientation)fromInterfaceOrientation
//{
//   
//}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//}


//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
//    
//    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
//    
//}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

@end
