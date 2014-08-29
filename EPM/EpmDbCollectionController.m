//
//  EpmDbCollectionController.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmDbCollectionController.h"
#import "EpmDbCellView.h"
#import "EpmDbDetailViewController.h"
#import "EpmDbHeader.h"
#import "AFNetworking.h"

@interface EpmDbCollectionController ()
-(void)loadData;
@end

@implementation EpmDbCollectionController
@synthesize dashboards = _dashboards;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//     NSLog(@"%@",@"fired");
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 //   if (self) {
        // Custom initialization
 //   }
 //   return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    
}


-(void)loadData{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *params = nil;
    
    
//    [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey: @"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"dashboards"] ] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSArray *result = (NSArray *)responseObject;
//        self.dashboards = result;
//        [self.collectionView reloadData];
//    }
//     
//          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//              int status = [[operation response]statusCode];
//              NSString *msg = [EpmHttpUtil notificationWithStatusCode:status];
//              
//              UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
//                                                           message:@""
//                                                          delegate:nil
//                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
//              [av show];
//          }];
    self.dashboards = @[@{@"name":@"Daily BU Performance",@"id":@21}];
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.dashboards.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
     EpmDbCellView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];

    NSLog(@"%@",[[self.dashboards  objectAtIndex:indexPath.row] objectForKey:@"name"]);
    cell.title.text = [[self.dashboards  objectAtIndex:indexPath.row] objectForKey:@"name"];
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        EpmDbHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"dbHeader" forIndexPath:indexPath];
               reusableview = headerView;

        headerView.largeTitle.text = @"Insight.";
    }
    
    return reusableview;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"viewDashboardDetail" sender:[self.dashboards objectAtIndex:indexPath.row]];

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"viewDashboardDetail"])
    {
        EpmDbDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.dashboardId = (NSString *)[sender objectForKey:@"id"];
 
    }
    
}

@end
