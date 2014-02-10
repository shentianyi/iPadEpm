//
//  EpmOrgViewController.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmOrgViewController.h"
#import "EpmOrgKpiCellView.h"
#import "LineLayout.h"
#import "AFNetworking.h"
#import "EpmTableCell.h"
@interface EpmOrgViewController ()

@end

@implementation EpmOrgViewController
@synthesize collectionView  = _collectionView;
@synthesize kpis = _kpis;
@synthesize entityGroup = _entityGroup;
@synthesize webView = _webView;
@synthesize indicator = _indicator;
@synthesize tableData = _tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)getDataForTableWithKpi:(NSDictionary*)Kpi{

     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[Kpi objectForKey:@"id"],@"kpi_id",@"100",@"frequency",[self.entityGroup objectForKey:@"id"],@"entity_group_id",[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-1296000]],@"start_time",[formatter stringFromDate:[NSDate date]], @"end_time",nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"data"]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *result = (NSDictionary *)responseObject;
        
        self.tableData = result;
        [self.tableView reloadData];
    }
     
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             int statusCode = [operation.response statusCode];
             
             NSString *msg=[EpmHttpUtil notificationWithStatusCode:statusCode];
             
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                          message:@""
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];

         }];
}


-(void)loadData{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = nil;
   

    NSString *toReplace = (NSString *)[EpmSettings getEpmUrlSettingsWithKey:@"kpis"];
    toReplace = [toReplace stringByReplacingOccurrencesOfString:@":id:"
                                               withString:[self.entityGroup objectForKey:@"id"]];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],toReplace] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *result = (NSArray *)responseObject;
        self.kpis = result;
        [self.collectionView reloadData];
    }
     
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             int statusCode = [operation.response statusCode];
             
             NSString *msg=[EpmHttpUtil notificationWithStatusCode:statusCode];
             
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                          message:@""
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];
         }];
}




- (void)viewDidLoad
{
    [super viewDidLoad];

    LineLayout * flowLayout = [[LineLayout alloc] init];
    self.collectionView.collectionViewLayout = flowLayout;
    self.webView.delegate=self;
    [self loadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.kpis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    EpmOrgKpiCellView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"orgKpi" forIndexPath:indexPath];
    NSDictionary *currentDic = [self.kpis objectAtIndex:indexPath.row];
       cell.label.text = [currentDic objectForKey:@"name"];
    cell.desc.text = [currentDic  objectForKey:@"description"];
    cell.max.text = [[currentDic objectForKey:@"target_max"] stringValue];
    cell.min.text=[[currentDic   objectForKey:@"target_min"] stringValue];
    cell.category.image = [UIImage imageNamed:[NSString stringWithFormat:@"Catergory_%@",[[currentDic    objectForKey:@"kpi_category_id"]stringValue ]]];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self BeginLoadWebWithKpi:[self.kpis objectAtIndex:indexPath.row]];
    [self getDataForTableWithKpi:[self.kpis objectAtIndex:indexPath.row]];
    
    self.navigationItem.title = [self.entityGroup objectForKey:@"name"];
    
}



-(void)BeginLoadWebWithKpi:(NSDictionary*)Kpi
{
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *queryString = [NSString stringWithFormat:@"kpi_id=%@&kpi_name=%@&frequency=%@&entity_group_id=%@&entity_group_name=%@&average=YES&start_time=%@&end_time=%@",[Kpi objectForKey:@"id"],[Kpi objectForKey:@"name" ],@"100",[self.entityGroup objectForKey:@"id"],[self.entityGroup objectForKey:@"name"],[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-1296000]],[formatter stringFromDate:[NSDate date]]];

    
    NSString *urlTxt =[EpmHttpUtil escapeUrl:[NSString stringWithFormat:@"%@%@?%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey:@"graph"],queryString]];
    
    NSURL* url = [[ NSURL alloc] initWithString :urlTxt];
    
    NSMutableURLRequest *request = [EpmHttpUtil initWithCookiesWithUrl:url];
    
    [self.webView loadRequest:request];
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.indicator stopAnimating];
    
    int status = [EpmHttpUtil getLastHttpStatusCodeWithRequest:self.webView.request];
    
    if (status>=400){
        
        NSString *msg=[EpmHttpUtil notificationWithStatusCode:status];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                     message:@""
                                                    delegate:nil
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];

    }
}




- (void )webViewDidStartLoad:(UIWebView *)webView {
    [self.indicator startAnimating];
    
}





//每个section显示的标题

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Details";
}



//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[self.tableData objectForKey:@"current" ] count];
}



//绘制Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *CellIdentifier = @"infoCell";
    
    
    EpmTableCell *cell = (EpmTableCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    
   // NSDictionary *data =[self.tableData objectForKey:@"current" ];
    
   // NSDictionary *target = [self.tableData objectForKey:@"target_min"];
    
   // NSDictionary *target_max = [self.tableData objectForKey:@"target_max"];
    
 //
   // NSDictionary *current = [data objectForKey:[[data allKeys] objectAtIndex:indexPath.row]];
    
    //NSLog(@"%@",[[data allKeys] objectAtIndex:indexPath.row]);
   
    NSDate *date =[[self.tableData objectForKey:@"date"] objectAtIndex:indexPath.row];
    NSNumber *current =[[self.tableData objectForKey:@"current"] objectAtIndex:indexPath.row];
    NSNumber *min=[[self.tableData objectForKey:@"target_min"] objectAtIndex:indexPath.row];
    NSNumber *max=[[self.tableData objectForKey:@"target_max"] objectAtIndex:indexPath.row];
    NSString *unit = [[self.tableData objectForKey:@"unit"] objectAtIndex:indexPath.row];

    NSLog(@"%@",date);
    NSLog(@"%@",current);
    NSLog(@"%@",min);
    NSLog(@"%@",max);
    
    
    cell.time.text = [[self.tableData objectForKey:@"date"] objectAtIndex:indexPath.row];
    cell.value.text = [[NSString stringWithFormat:@"%0.2f",[current doubleValue]] stringByAppendingString:unit];
    cell.range.text = [NSString stringWithFormat:@"%@-%@",[NSString stringWithFormat:@"%0.2f",[min doubleValue]],[NSString stringWithFormat:@"%0.2f",[max doubleValue]]];
    
    if([current doubleValue] < [min doubleValue]|| [current doubleValue] > [max doubleValue]){
        cell.inrange.text = @"Out of range";
        cell.inrange.textColor = [UIColor redColor];
    }
    else{
        cell.inrange.text = @"In Range";
        cell.inrange.textColor = [UIColor greenColor];
      
    }
    
    return cell;
}






@end
