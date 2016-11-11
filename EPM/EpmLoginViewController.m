//
//  EpmLoginViewController.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-11.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//


#import "EpmLoginViewController.h"
#import "AFNetworking.h"
#import "KeychainItemWrapper.h"
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    KeychainItemWrapper *keychain=[[KeychainItemWrapper alloc] initWithIdentifier:@"clearinsight"
                                                                      accessGroup:nil];
    if( [keychain objectForKey:(__bridge id)kSecAttrAccount]){
        self.email .text = [keychain objectForKey:(__bridge id)kSecAttrAccount];
    }
    
    
    
    //self.email.text=@"admin@leoni.com";
    //self.psw.text=@"123456@*";
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
    
    NSLog(@"%@",[urlSetting objectForKey:@"baseUrl"]);
    
    [manager POST:[NSString stringWithFormat:@"%@%@",[urlSetting objectForKey:@"baseUrl"],[urlSetting objectForKey:@"login"] ] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *result = (NSDictionary *)responseObject;
        if([result objectForKey:@"result"] == [NSNumber numberWithBool:YES]){
            //save user name
            KeychainItemWrapper *keychain=[[KeychainItemWrapper alloc] initWithIdentifier:@"clearinsight"
                                                                              accessGroup:nil];
            [keychain setObject:self.psw.text forKey:(__bridge id)kSecValueData];
            [keychain setObject:self.email.text forKey:(__bridge id)kSecAttrAccount];
            
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
