//
//  EpmMailListController.m
//  EPM
//
//  Created by tianyi on 14-2-25.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmMailListController.h"
#import "EpmMailListCell.h"
#import "AFNetworking.h"

@interface EpmMailListController ()
@property (strong,nonatomic)NSMutableArray *mailList;
@property (strong,nonatomic)NSMutableArray *mailSection;
@end

@implementation EpmMailListController
@synthesize mailList = _mailList;
@synthesize listTableView = _listTableView;
@synthesize scrollView = _scrollView;
@synthesize bigTitle = _bigTitle;
@synthesize mailToIcon = _mailToIcon;


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
    self.leftView.layer.borderWidth = 1.0f;
    
    [self loadData];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)compose:(id)sender {
   }



-(void)loadData{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = nil;
    
    
    [manager GET:[NSString stringWithFormat:@"%@%@", [EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"], [EpmSettings getEpmUrlSettingsWithKey:@"emails" ]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if(result){
            self.mailList = [result objectForKey:@"values"];
            self.mailSection =[result objectForKey:@"titles"];
            [self.listTableView reloadData];
            
        }
        else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Service is temporily down. Please try again later."
                                                         message:@""
                                                        delegate:nil
                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
        }
    }
     
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"%@", [operation response]);
             
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Service is temporily down. Please try again later."
                                                          message:@""
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];
         }];



}

//每个section显示的标题

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.mailSection objectAtIndex:section];
}



//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.mailSection.count;
}



//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *mails = [self.mailList objectAtIndex:section];
    return mails.count;
   }






//绘制Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *mails = [self.mailList objectAtIndex:indexPath.section];
    

    
    
    
    static NSString *CellIdentifier = @"mailCell";
    
    
    EpmMailListCell *cell = (EpmMailListCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *mail = [mails objectAtIndex:indexPath.row];
    
    
    
    cell.title.text =[mail objectForKey:@"title"];
    cell.receiver.text =[mail objectForKey:@"receivers"];
  
    cell.time.text = [EpmUtility convertDatetimeWithString:[mail objectForKey:@"created_at"] WithFormat:ShortEnglishDatetimeFormat];
    
    if([mail objectForKey:@"attachments"] &&[[mail objectForKey:@"attachments"] count]>1){
        cell.phtoIndicator.image =[UIImage imageNamed:@"Photo-colorful.png"];
    }
    
    if([mail objectForKey:@"kpi_id"]){
        cell.chartIndicator.image = [UIImage imageNamed:@"chart-clorful.png"];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *mails = [self.mailList objectAtIndex:indexPath.section];
    NSDictionary *mail = [mails objectAtIndex:indexPath.row];
    
    self.bigTitle.text= [mail objectForKey:@"title"];
    
    self.receiver.text = [mail objectForKey:@"receivers"];
    
    self.content.numberOfLines=0;
    self.content.text = [mail objectForKey:@"content"];
    [self.content sizeToFit];
    

    NSMutableArray *images = [[NSMutableArray   alloc]init];
    
    //add image
    if([[mail objectForKey:@"attachments"] count] > 0) {
        for(NSDictionary *image in [mail objectForKey:@"attachments"]){
            UIImageView *imageView = [[UIImageView alloc]init];
            [images addObject:imageView];
        }
    }
    
    //add webview
    
    
    //



}




@end
