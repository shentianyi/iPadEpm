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
@property (weak, nonatomic) IBOutlet UITextField *oldPsw;
@property (weak, nonatomic) IBOutlet UITextField *confirmPsw;
@property (weak, nonatomic) IBOutlet UIView *chgPswView;
@property (weak, nonatomic) IBOutlet UITextField *pswToChange;


@end

@implementation EpmSettingViewController
@synthesize oldPsw = _oldPsw;
@synthesize pswToChange = _pswToChange;
@synthesize confirmPsw = _confirmPsw;
@synthesize chgPswView = _chgPswView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)changePsw:(id)sender {
    if ([self.pswToChange.text length]==0 || ![self.pswToChange.text isEqualToString:self.confirmPsw.text]){
        UIAlertView *av = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"CONFIRM_NEW_PASSWORD", nil)
                                                     message:@""
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    else{
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        
        NSDictionary *params = @{@"password":self.oldPsw.text,@"new_password":self.pswToChange.text,@"new_password_confirmation":self.confirmPsw.text};
        
        
        [manager POST: [NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey: @"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"newPsw"] ] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *result = (NSDictionary *)responseObject;
            NSString *msg;
            if([[result objectForKey:@"result"] boolValue]==YES){
                msg =NSLocalizedString(@"PASSWORD_CHANGE_DONE", nil);
                 [self performSegueWithIdentifier:@"logout" sender:nil];
            }
            else{
                msg =NSLocalizedString(@"PASSWORD_CHANGE_FAILED", nil);
            
            }
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle: msg
                                                         message:@""
                                                        delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            
            
        }
         
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@",error);
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"SERVICE_DOWN_NETWORK", nil)
                                                                 message:@""
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                }];

    
    
    
    }
    
    
}

- (void) logout{
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

- (IBAction)logout:(id)sender {
    [self logout];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.chgPswView.layer.borderWidth = 0.5;
    self.chgPswView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.chgPswView.layer.cornerRadius = 8;
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
