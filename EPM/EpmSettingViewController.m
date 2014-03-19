//
//  EpmSettingViewController.m
//  ClearInsight
//
//  Created by tianyi on 14-3-18.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmSettingViewController.h"
#import "AFNetworking.h"
@interface EpmSettingViewController ()

@end

@implementation EpmSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (IBAction)logout:(id)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = nil;
    
    
    [manager DELETE: [NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey: @"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"logout"] ] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self performSegueWithIdentifier:@"logout" sender:nil];
       
    }
     
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", [operation response]);
              
              UIAlertView *av = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"SERVICE_DOWN_NETWORK", nil)
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [av show];
          }];

}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
