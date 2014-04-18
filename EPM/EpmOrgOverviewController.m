//
//  EpmOrgOverviewController.m
//  EPM
//
//  Created by tianyi on 14-2-28.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmOrgOverviewController.h"
#import "EpmOrgKpiCellView.h"
#import "EpmMailListCell.h"
#import "AFNetworking.h"
#import "EpmContactCell.h"
#import "EpmSendMailController.h"
#import "EpmOrgViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"


@interface EpmOrgOverviewController ()

@end

@implementation EpmOrgOverviewController

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
    [self loadAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadContact{
    if(self.entityGroup){
        NSLog(@"%@",self.entityGroup);
        self.contacts = [NSMutableArray arrayWithArray:[self.entityGroup objectForKey:@"contacts"]];
        [self.contactCollection reloadData];
    }
}


-(void)loadTitle{
    if(self.entityGroup){
        self.entityGroupName.text = [self.entityGroup objectForKey:@"name"];
        self.entityGroupDesc.text = [self.entityGroup objectForKey:@"description"];
        
    }

}


-(void) loadKpi {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params = nil;
    
    NSString *toReplace = (NSString *)[EpmSettings getEpmUrlSettingsWithKey:@"kpis"];
    
    NSString *entityId;
    if([[self.entityGroup objectForKey:@"id"] isKindOfClass:[NSString class]]){
        entityId = [self.entityGroup objectForKey:@"id"];
    }
    else{
        entityId = [[self.entityGroup objectForKey:@"id"] stringValue];
    }
    
    toReplace = [toReplace stringByReplacingOccurrencesOfString:@":id"
                                                     withString:entityId];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],toReplace] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *result = (NSArray *)responseObject;
        self.kpis = result;
        self.kpiNumber.text = [NSString stringWithFormat:@"%lu",self.kpis.count];
        
        [self.kpiCollection reloadData];
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

-(void)loadImprovement{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = @{@"conditions":@{@"entity_group_id":[self.entityGroup objectForKey:@"id"]}};
    
    
    [manager GET:[NSString stringWithFormat:@"%@%@", [EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"], [EpmSettings getEpmUrlSettingsWithKey:@"emails" ]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *result = (NSMutableDictionary *)responseObject;
        if(result){
            self.mailList = [result objectForKey:@"values"];
            self.mailSection =[result objectForKey:@"titles"];
           [self.improveTable reloadData];
            
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
             
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SERVICE_DOWN_NETWORK", nil)
                                                          message:@""
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];
            }];

}


-(void)loadAll{
    [self loadTitle];
    [self loadContact];
       [self loadKpi];
    [self loadImprovement];
}






#pragma tableview delegate

//每个section显示的标题

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.mailSection objectAtIndex:section];
}



//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return 0;
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
    
    static NSString *CellIdentifier = @"overviewmailCell";
    
    
    EpmMailListCell *cell = (EpmMailListCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *mail = [mails objectAtIndex:indexPath.row];
    
    // NSLog(@"%d .section,%d .row:%@",indexPath.section,indexPath.row,mail);
    
    cell.title.text =[mail objectForKey:@"title"];
    
    cell.time.text = [EpmUtility convertDatetimeWithString:[mail objectForKey:@"created_at"] WithFormat:ShortEnglishDatetimeFormat];
    
    cell.phtoIndicator.hidden=!([mail objectForKey:@"attachments"] &&[[mail objectForKey:@"attachments"] count]>=1);
    
   
    cell.chartIndicator.hidden = !([mail objectForKey:@"kpi_id"] && ![[mail objectForKey:@"kpi_id" ] isKindOfClass:[NSNull class]]);
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
       return cell;
}


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.improveTable.bounds.size.width, 15)];
  
        [headerView setBackgroundColor:[UIColor clearColor]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.text = [self.mailSection objectAtIndex:section];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"viewMail" sender:nil];
    
}



#pragma collectionview delegate


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    if (view == self.kpiCollection){
      return self.kpis.count;
    }
    else if (view== self.contactCollection){
        return self.contacts.count;
    }
    else {
        return 0;
    }
  
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    if(cv == self.kpiCollection){
        EpmOrgKpiCellView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"overviewkpiCell" forIndexPath:indexPath];
        NSDictionary *currentDic = [self.kpis objectAtIndex:indexPath.row];
        cell.label.text = [currentDic objectForKey:@"name"];
        cell.desc.text = [currentDic  objectForKey:@"description"];
        cell.max.text = [[currentDic objectForKey:@"target_max"] stringValue];
        cell.min.text=[[currentDic   objectForKey:@"target_min"] stringValue];
        cell.category.image = [UIImage imageNamed:[NSString stringWithFormat:@"kpiCategory-%@",[[currentDic    objectForKey:@"kpi_category_id"]stringValue ]]];
        return cell;
    
    }
    else if(cv==self.contactCollection){
        NSDictionary *data = [self.contacts objectAtIndex:indexPath.row];
        EpmContactCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"overviewContactCell" forIndexPath:indexPath];
        
        
        cell.img.layer.cornerRadius = 10.0;
        cell.img.layer.masksToBounds = YES;
        
        cell.name.text = [data objectForKey:@"name"];
        cell.email.text=[data objectForKey:@"email"];
        cell.tel.text= [data objectForKey:@"tel"];
        cell.mobil.text = [data objectForKey:@"phone"];
        cell.title.text = [data objectForKey:@"title"];
        [cell.img setImageWithURL:[NSURL URLWithString:[data objectForKey:@"image_url"]]];
        
        return cell;
   }
    else {
        return nil;
    }
}
- (IBAction)compose:(id)sender {
    [self performSegueWithIdentifier:@"composeMail" sender:[self composeMailData]];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == self.kpiCollection){
        
        //push to detail segue
        [self performSegueWithIdentifier:@"toDetail" sender:@{@"entityGroup":self.entityGroup,@"kpi":[self.kpis objectAtIndex:indexPath.row]}];
    }
    else if(collectionView == self.contactCollection){
        [self performSegueWithIdentifier:@"composeMail" sender:[self composeMailData]];
    }
    

    
}



#pragma segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"composeMail"]){
        EpmSendMailController *mail = segue.destinationViewController;
        mail.completeData = (NSMutableDictionary*)sender;
        
    }
    if([segue.identifier isEqualToString:@"toDetail"]){
        EpmOrgViewController *detail = segue.destinationViewController;
        detail.entityGroup = [sender objectForKey:@"entityGroup"];
//        NSLog(@"%@",[sender objectForKey:@"kpi"]);
        detail.preloadKpi = [sender objectForKey:@"kpi"];
        detail.hidesBottomBarWhenPushed = YES;
    }
    
}

-(NSDictionary *)composeMailData {
    return @{@"contacts":[self.entityGroup objectForKey:@"contacts"]};
}







@end
