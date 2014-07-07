//
//  NotificationViewController.m
//  ClearInsight
//
//  Created by wayne on 14-7-7.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationTableViewCell.h"
@interface NotificationViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *notificationTable;
@property (strong,nonatomic)NSArray *notificationArray;
@end

@implementation NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.notificationTable.dataSource=self;
    self.notificationTable.delegate=self;
    
    NSString *baseURL=[NSString stringWithFormat:@"%@", [EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"]];
    NSString *requestURL=[NSString stringWithFormat:@"%@/users/message",baseURL];

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              self.notificationArray=responseObject;
              NSLog(@"%@",self.notificationArray[0] );
              NSLog(@"%@",[self.notificationArray[0] objectForKey:@"content"]);
              [self.notificationTable reloadData];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
          }];
    
    UINib *nib=[UINib nibWithNibName:@"NotificationTableViewCell" bundle:nil];
    [self.notificationTable registerNib:nib forCellReuseIdentifier:@"notificationCell"];

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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notificationArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"notificationCell" forIndexPath:indexPath];
    NSDictionary *item=self.notificationArray[indexPath.row];
    cell.content.text=[item objectForKey:@"content"];
    cell.count.text=[NSString stringWithFormat:@"%@", [item objectForKey:@"count"]];
    return cell;
}

@end
