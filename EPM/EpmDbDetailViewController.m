//
//  EpmDbDetailViewController.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmDbDetailViewController.h"

@interface EpmDbDetailViewController ()

@end

@implementation EpmDbDetailViewController
@synthesize dashboardId = _dashboardId;
@synthesize webView = _webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)viewDidLoad

{
    [super viewDidLoad];
     self.webView.delegate = self;
    [self BeginLoadWeb];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)BeginLoadWeb
{
    
 
    NSString *urlTxt =[NSString stringWithFormat:@"%@%@/%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey:@"dbFullsize"],self.dashboardId];

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


-  (void)didRotateFromInterfaceOrientation:
(UIInterfaceOrientation)fromInterfaceOrientation
{
   
}

@end
