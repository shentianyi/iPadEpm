//
//  EpmLoginViewController.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-11.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//


#import "EpmLoginViewController.h"
#import "AFNetworking.h"
@interface EpmLoginViewController ()

@end

@implementation EpmLoginViewController


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 //   if (self) {
        // Custom initialization
 ////   }
//    return self;
//}

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

-(void)doLogin{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"urlSetting" ofType:@"plist"];
    NSMutableDictionary *urlSetting = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = @{@"user_session[email]": self.email.text,
                             @"user_session[password]": self.psw .text};
    
   
    [manager POST:[NSString stringWithFormat:@"%@%@",[urlSetting objectForKey:@"baseUrl"],[urlSetting objectForKey:@"login"] ] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *result = (NSDictionary *)responseObject;
        if([result objectForKey:@"result"] == [NSNumber numberWithBool:YES]){
            
            [self performSegueWithIdentifier:@"loginSegue" sender:self];
            
        }
        else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"WRONG_LOGIN", nil)
                                                         message:@""
                                                        delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
     
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@", [operation response]);
              
              UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SERVICE_DOWN_NETWORK", nil)
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [av show];
          }];
}

- (IBAction)btLogin:(UIButton *)sender {
    
    [self doLogin];
    
    
    }

- (IBAction)txtEnter:(UITextField *)sender {
   
}

- (BOOL)textFieldShouldReturn:(UITextField *)psw {
    [self doLogin];
    return YES;
}
	


@end
