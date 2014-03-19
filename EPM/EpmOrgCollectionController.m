//
//  EpmOrgCollectionController.m
//  EPM
//
//  Created by Shen Tianyi on 14-1-10.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmOrgCollectionController.h"
#import "EpmOrgCellView.h"
#import "EpmOrgCollectionController.h"
#import "EpmDbHeader.h"
#import "AFNetworking.h"
#import "EpmOrgViewController.h"
@interface EpmOrgCollectionController ()
-(void)getData;
@end

@implementation EpmOrgCollectionController
@synthesize Organizations = _Organizations;


-(void)getData{
    
   
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = nil;
    
   
    [manager GET:[NSString stringWithFormat:@"%@%@", [EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"], [EpmSettings getEpmUrlSettingsWithKey:@"org" ]] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    [self.collectionView reloadData];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.Organizations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    EpmOrgCellView *cell = [cv dequeueReusableCellWithReuseIdentifier:@"orgCell" forIndexPath:indexPath];
    
        cell.connectTxt.text = @"EPM Connected";
//    if(indexPath.row==0){
//          cell.connectImg.image = [UIImage imageNamed:@"disconnect.png"];
//        cell.connectTxt.text = @"EPM Not Connected";
//    }
//    else{
          cell.connectImg.image = [UIImage imageNamed:@"connect.png"];
   // }
    
       cell.mainImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",@"organization-item-bg.png"]];
    
        cell.rightImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[self.Organizations objectAtIndex:indexPath.row] objectForKey:@"code"]]];
        cell.orgName.text =[[self.Organizations objectAtIndex:indexPath.row] objectForKey:@"name"];
          cell.orgDetail.text =[[self.Organizations objectAtIndex:indexPath.row] objectForKey:@"description"];
        

    
    //  UICollectionViewCell *cell = [collectionView    dequeueReusableCellWithReuseIdentifier:@"itemCell" forIndexPath:indexPath];
    //cell.title.text = [self.dashboards  objectAtIndex:indexPath.row];
    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        EpmDbHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"orgHead" forIndexPath:indexPath];
        reusableview = headerView;
        
        }
    return reusableview;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
  [self performSegueWithIdentifier:@"viewOrgKpi" sender:[self.Organizations objectAtIndex:indexPath.row]];
    
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"viewOrgKpi"])
    {
        EpmOrgViewController *detailViewController = segue.destinationViewController;
        detailViewController.entityGroup  = (NSDictionary *)sender;
        detailViewController.hidesBottomBarWhenPushed=YES;
    }
    
}




@end
