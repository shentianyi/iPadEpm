//
//  DashboardCollectionViewController.m
//  ClearInsight
//
//  Created by wayne on 16/10/14.
//  Copyright © 2016年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "DashboardCollectionViewController.h"
#import "DashCollectionViewCell.h"
#import "EpmOrgCollectionController.h"
#import "EpmDbHeader.h"
#import "AFNetworking.h"
#import "EpmOrgViewController.h"
#import "TOWebViewController.h"
@interface DashboardCollectionViewController ()

@end

@implementation DashboardCollectionViewController
@synthesize Organizations = _Organizations;


-(void)getData{
    
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = nil;
    NSLog(@"%@",[NSString stringWithFormat:@"%@%@", [EpmSettings getEpmUrlSettingsWithKey:@"dashboardbaseUrl"], [EpmSettings getEpmUrlSettingsWithKey:@"dashboards" ]]);
    
    [manager GET:[NSString stringWithFormat:@"%@%@", [EpmSettings getEpmUrlSettingsWithKey:@"dashboardbaseUrl"], [EpmSettings getEpmUrlSettingsWithKey:@"dashboards" ]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *result = (NSArray *)responseObject;
        
        if(result){
            self.Organizations = result;
            [self.collectionView reloadData];
            
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
         }];
    
    
    
    
}


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
    [self getData];
    //[self.collectionView reloadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    //return self.Organizations.count;
    return self.Organizations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    DashCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    cell.dashTitle.text =[[self.Organizations objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSLog([[self.Organizations objectAtIndex:indexPath.row] objectForKey:@"name"]);
    NSLog(@"%@",cell.dashTitle.text);
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        EpmDbHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"dashHead" forIndexPath:indexPath];
        reusableview = headerView;
        
    }
    return reusableview;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSString *ip = [EpmSettings getEpmUrlSettingsWithKey:@"dashboardbaseUrl"];
    NSString *stringForURL = [ip stringByAppendingString:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"dashboardApi"],[[self.Organizations objectAtIndex:indexPath.row] objectForKey:@"id"]]];
    NSURL *url = nil;
#ifdef TO_ONEPASSWORD_EXAMPLE
    url = [NSURL URLWithString:@"https://accounts.google.com/login"];
#else
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        url = [NSURL URLWithString:stringForURL];
    else if ([[[UIDevice currentDevice] model] rangeOfString:@"iPod"].location != NSNotFound)
        url = [NSURL URLWithString:@"www.apple.com/ipod-touch"];
    else
        url = [NSURL URLWithString:@"www.apple.com/iphone"];
#endif
    
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
#ifdef TO_ONEPASSWORD_EXAMPLE
    webViewController.showOnePasswordButton = YES;
#endif
    
//    if (indexPath.row == 0) {
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
//    }
//    else {
//        [self.navigationController pushViewController:webViewController animated:YES];
//    }
    
}
@end
