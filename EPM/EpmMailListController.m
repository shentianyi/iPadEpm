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
#import <SDWebImage/UIImageView+WebCache.h>

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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadData:) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PULL_TO_UPDATE", nil)];
    
    [self.listTableView addSubview:refreshControl];
    
    [self loadData:nil];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)compose:(id)sender {
    [self performSegueWithIdentifier:@"mailCompose" sender:nil];
   }

-(void)resetRefreshControl:(UIRefreshControl*)refreshControl{
    [refreshControl endRefreshing];
    [refreshControl setAttributedTitle: [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PULL_TO_UPDATE", nil)]];

}

-(void)loadData:(id) sender{
    if(sender){
        
    [sender setAttributedTitle: [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LOADING", nil)]];
    
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = nil;
    
    
    [manager GET:[NSString stringWithFormat:@"%@%@", [EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"], [EpmSettings getEpmUrlSettingsWithKey:@"emails" ]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
      
        if(result){
            self.mailList = [result objectForKey:@"values"];
            self.mailSection =[result objectForKey:@"titles"];

            if(sender){
                [self resetRefreshControl:sender];}
            [self.listTableView reloadData];
            
        }
        else {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SERVICE_DOWN_NETWORK", nil)
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
             if(sender){
                 [self resetRefreshControl:sender];}
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
    
    if([mail objectForKey:@"attachments"] &&[[mail objectForKey:@"attachments"] count]>=1){
        cell.phtoIndicator.image =[UIImage imageNamed:@"Photo-colorful.png"];
    }
    else {
        cell.phtoIndicator.image =[UIImage imageNamed:@"Photo-gray.png"];
    }

    
    if([mail objectForKey:@"kpi_id"] && ![[mail objectForKey:@"kpi_id" ] isKindOfClass:[NSNull class]]){
        cell.chartIndicator.image = [UIImage imageNamed:@"chart-clorful.png"];
    }
    else{
        cell.chartIndicator.image = [UIImage imageNamed:@"chart-gray.png"];

    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat margin = 40.0f;
    
    NSArray *mails = [self.mailList objectAtIndex:indexPath.section];
    NSDictionary *mail = [mails objectAtIndex:indexPath.row];
    
    for(UIView *subView in self.scrollView.subviews){
        if(([subView isMemberOfClass:[UIImageView class]]&& subView.tag != 991) || [subView isMemberOfClass:[UIWebView class]]){
            [subView removeFromSuperview];
        }
    }
    
    
    self.bigTitle.text= [mail objectForKey:@"title"];
    
    self.receiver.text = [mail objectForKey:@"receivers"];
    
    
    
    NSMutableAttributedString *attributed =[[NSMutableAttributedString alloc]initWithString:[mail objectForKey:@"content"] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    
    //[attributed addAttribute:NSFontAttributeName value:@"system" range:NSMakeRange(0,[[mail objectForKey:@"content" ] length])];
 
    [self.content setAttributedText:attributed];
    [self.content sizeToFit];
    [self.content layoutIfNeeded];
    NSString *mailContent =[mail objectForKey:@"content"];
    CGRect rect = [mailContent  boundingRectWithSize:CGSizeMake(self.scrollView.bounds.size.width-55, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19.0f]} context:NULL];
    [self.content setFrame:CGRectMake(self.content.frame.origin.x,self.content.frame.origin.y, self.scrollView.bounds.size.width-55,rect.size.height+30)];

   
     CGPoint lastPosition = CGPointMake(self.content.frame.origin.x, self.content.frame.origin.y + self.content.bounds.size.height+margin);
    //add image
    if([[mail objectForKey:@"attachments"] count] > 0) {
        for(NSDictionary *image in [mail objectForKey:@"attachments"]){
            UIImageView *imageView = [[UIImageView alloc]init];
           
           imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.scrollView addSubview:imageView];
             [imageView setFrame:CGRectMake(lastPosition.x, lastPosition.y, self.scrollView.bounds.size.width-55, self.scrollView.bounds.size.width-55)];
           lastPosition.y = lastPosition.y + imageView.bounds.size.height +margin;
                        [imageView setImageWithURL:[NSURL URLWithString:[image objectForKey:@"path"]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
               
           }];
        }
   }
    
    //add webview
    
    if([mail objectForKey:@"kpi_id"] && ![[mail objectForKey:@"kpi_id" ] isKindOfClass:[NSNull class]]){
        
        
        UIWebView *webView = [[UIWebView alloc]init];
        
        webView.delegate =self;
        
        [self.scrollView addSubview:webView];
        
        [webView setFrame:CGRectMake(lastPosition.x, lastPosition.y, self.scrollView.bounds.size.width-55, self.scrollView.bounds.size.width-45)];
        
        lastPosition.y = lastPosition.y + webView.bounds.size.height + margin;
        
        NSString *urlTxt =[EpmHttpUtil escapeUrl:[NSString stringWithFormat:@"%@%@/%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey:@"mailGraph"],[mail objectForKey:@"id"]]];
        
        NSURL* url = [[ NSURL alloc] initWithString :urlTxt];
        
        NSMutableURLRequest *request = [EpmHttpUtil initWithCookiesWithUrl:url];
        
        [webView loadRequest:request];

            }
    
    
     //


    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, lastPosition.y);

}




@end
