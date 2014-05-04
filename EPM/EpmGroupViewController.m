//
//  EpmGroupViewController.m
//  ClearInsight
//
//  Created by tianyi on 14-4-2.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmGroupViewController.h"
#import "XYPieChart.h"
#import "EpmGroupConditionViewController.h"
#import "EpmGroupDetailTableViewCell.h"
#import "PNChart.h"
#import "AFNetworking.h"
#import "EpmSettings.h"

#import "OrgDeailAttributeCellView.h"
#import "DetailPropertyModel.h"
#import "ChooseProperty.h"
#import "DetailCompareChart.h"


@interface EpmGroupViewController ()<XYPieChartDataSource,XYPieChartDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *kpiNameLb;
@property (weak, nonatomic) IBOutlet UILabel *entityNameLb;
@property (weak, nonatomic) IBOutlet UILabel *groupByName;
@property (weak, nonatomic) IBOutlet UIView *groupByView;


@property (weak, nonatomic) IBOutlet UILabel *pieSelectedName;
@property (weak, nonatomic) IBOutlet UILabel *pieSelectedPercentage;
@property (weak, nonatomic) IBOutlet UILabel *pieSelectedValue;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong ,nonatomic) NSString *kpiID;

@property (strong,nonatomic) NSMutableArray *pieData;
@property (weak, nonatomic) IBOutlet XYPieChart *pieContainer;
@property(strong,nonatomic)NSArray *sliceColors;
@property(strong,nonatomic) NSString *currentCondition;
@property(strong,nonatomic)NSArray *groupItems;
@property(strong,nonatomic)NSDictionary *groupData;

@property (weak, nonatomic) IBOutlet UILabel *variableTitle;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UIView *pieView;
@property (weak, nonatomic) IBOutlet PNLineChart *barChart;

//wayne
@property (strong , nonatomic) NSArray *entityArray;
@property (strong , nonatomic) NSURLSession *session;
@property (strong , nonatomic) UIPopoverController *popController;
- (IBAction)assembleAnalyse:(id)sender;


//experiment data


@end

@implementation EpmGroupViewController


- (IBAction)transitionToPie:(id)sender {
    [UIView transitionWithView:self.barView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        
        self.pieView.hidden =NO;
        self.barView.hidden = YES;
        
    } completion:^(BOOL finish){
        
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
    //生成PROPERTY的模型
    NSLog(@"%@",self.currentConditions);
    int kpiID=(int)[self.currentConditions objectForKey:@"kpi_id"];
    [DetailPropertyModel FetchData:[NSString stringWithFormat:@"%d",kpiID]];
    
    self.navigationItem.title=[self.currentConditions objectForKey:@"chosen_time"];
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:1.0],
                       [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1.0],
                       [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:1.0],
                       [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:1.0],
                       [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:1.0],
                       [UIColor colorWithRed:31/255.0 green:186/255.0 blue:162/255.0 alpha:1.0],
                       [UIColor colorWithRed:191/255.0 green:73/255.0 blue:73/255.0 alpha:1.0],
                       nil];
    
    
    
    self.groupByView.layer.borderWidth = 0.5;
    self.groupByView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.groupByView.layer.cornerRadius = 8;
    
    
    [self.pieContainer setDataSource:self];
    [self.pieContainer setDelegate:self];
    [self.pieContainer setStartPieAngle:M_PI_2];
    [self.pieContainer setAnimationSpeed:1.0];
    [self.pieContainer setLabelFont:[UIFont fontWithName:@"DBLCDTempBlack" size:24]];
    [self.pieContainer setLabelRadius:160];
    [self.pieContainer setShowPercentage:YES];
    [self.pieContainer setPieBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.3]];
    [self.pieContainer setPieCenter:CGPointMake(self.pieContainer.bounds.size.width/2, self.pieContainer.bounds.size.height/2)];
    [self.pieContainer setLabelShadowColor:[UIColor blackColor]];
    [self loadDetail];
    
    //collection
    UINib *attributeCell=[UINib nibWithNibName:@"OrgDeailAttributeCellView"
                                        bundle:nil];
    [self.attributeCollection registerNib:attributeCell
               forCellWithReuseIdentifier:@"attributeCollection"];
    self.attributeCollection.delegate=self;
    self.attributeCollection.dataSource=self;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(170,self.attributeCollection.bounds.size.height)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    [self.attributeCollection setCollectionViewLayout:flowLayout];
    

}

//点击聚合分析
- (IBAction)assembleAnalyse:(id)sender {
    NSMutableDictionary *propertyPost=[NSMutableDictionary dictionary];
    NSMutableArray *property_map_group=[NSMutableArray array];
    
    NSArray *properties=[DetailPropertyModel sharedProperty].properties;
    for(int i =0;i<properties.count;i++){
        NSDictionary *checkedArray=[properties[i] objectForKey:@"checked"];
        NSArray *property=[properties[i] objectForKey:@"property"];
        NSNumber *groupID=[properties[i] objectForKey:@"id"];
        
        if(checkedArray.count>0){
            [property_map_group addObject:groupID];
            [propertyPost setObject:[NSMutableArray array] forKey:groupID];

            for( NSNumber *key in checkedArray){
                int order=[key intValue];
                [propertyPost[groupID] addObject:[property[order] objectForKey:@"id"]];
            }
        }
        else{
            continue ;
        }
    }
//    NSLog(@"property:%@",propertyPost);
//    NSLog(@"property_group:%@",property_map_group);
    
    NSMutableDictionary *parameterCondition=[NSMutableDictionary dictionary];
    //差一个平均or总和 结束时间
    [parameterCondition setObject:[self.currentConditions objectForKey:@"kpi_id"] forKey:@"kpi_id"];
    [parameterCondition setObject:[self.currentConditions objectForKey:@"entity_group_id"] forKey:@"entity_group_id"];
    [parameterCondition setObject:[self.currentConditions objectForKey:@"frequency"] forKey:@"frequency"];
    [parameterCondition setObject:propertyPost forKey:@"property"];
    [parameterCondition setObject:property_map_group forKey:@"property_map_group"];
    [parameterCondition setObject:[NSMutableDictionary dictionary] forKey:@"base_time"];
    
    //时间
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    [formatter setLocale:enUSPOSIXLocale];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[formatter dateFromString:[self.currentConditions objectForKey:@"chosen_time"]];
    NSMutableString *dateString=[NSMutableString stringWithFormat:@"%@",date.description];
    NSRange range=NSMakeRange(10, 1);
    [dateString replaceOccurrencesOfString:@" "
                                withString:@"T"
                                   options:NSCaseInsensitiveSearch
                                     range:range];
    NSRange Zrange=NSMakeRange(19, 1);
    [dateString replaceOccurrencesOfString:@" "
                                withString:@"Z"
                                   options:NSCaseInsensitiveSearch
                                     range:Zrange];
    
   [[parameterCondition objectForKey:@"base_time"] setObject:[dateString substringToIndex:20]
                                                      forKey:@"start_time"];
//    NSLog(@"date %@",[dateString substringToIndex:20]);
    
    
    NSString *requestURL=[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"%@", [EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"]],[NSString stringWithFormat:@"%@", [EpmSettings getEpmUrlSettingsWithKey:@"detailCompare"]]];
//    NSLog(@"%@",requestURL);
    //请求加载数据在
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:requestURL
       parameters:parameterCondition
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
    
}

-(void)loadDetail{
    NSString *requestURL=[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@", [EpmSettings getEpmUrlSettingsWithKey:@"kpiDetail"]]];
    requestURL=[requestURL stringByAppendingPathComponent:self.kpiID];
    //请求加载数据在
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:requestURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             self.entityArray=responseObject;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
         }];
    
 
    
    //experiment data
    //wayne

    //tianyi
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"tmpGroupDetails" ofType:@"plist"];
    NSDictionary *settings   = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    self.kpiID=@"127";
    
    self.groupItems = [[settings objectForKey:@"groupItem"] objectForKey:self.kpiID];
    self.groupData = [[settings objectForKey:@"groupData"] objectForKey:self.kpiID];
    

    if(!self.currentCondition && self.groupItems.count>0) {
        self.currentCondition = [self.groupItems objectAtIndex:0];
    }
    
    self.groupByName.text = self.currentCondition;
    self.variableTitle.text = self.currentCondition;
    
    self.pieData = [self.groupData objectForKey:self.currentCondition];
    
         
    [self.pieContainer reloadData];
    [self.tableView reloadData];
  
}

- (IBAction)selectGroupCondition:(id)sender {
    NSArray *entity=[self.entityArray copy];
    void (^dismiss)()=^(){
        
    };
    [self performSegueWithIdentifier:@"selectGroupCondition" sender:@{
                                                                      @"entity":entity,
                                                                      @"dismiss":dismiss
                                                                      }];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"selectGroupCondition"]){
        EpmGroupConditionViewController  *tableEntity= segue.destinationViewController;
        tableEntity.entities=[sender objectForKey:@"entity"];
        tableEntity.dismiss=[sender objectForKey:@"dismiss"];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pieContainer reloadData];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.kpiID = [[self.currentConditions objectForKey:@"kpi_id"] stringValue];
    self.entityNameLb.text = [self.currentConditions objectForKey:@"entity_group_name"];
    self.kpiNameLb.text = [self.currentConditions objectForKey:@"kpi_name"];
    [self.kpiNameLb sizeToFit];
    self.entityNameLb.adjustsFontSizeToFitWidth=YES;
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


//pie delegate
#pragma mark - datasource
- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return self.pieData.count;
}


- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[[self.pieData objectAtIndex:index] objectForKey:@"value"] intValue];
}


- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [self.sliceColors objectAtIndex:(index % self.sliceColors.count)];
}


#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
   
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
   
}


- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    self.pieSelectedName.text = [[self.pieData objectAtIndex:index] objectForKey:@"name"];
    self.pieSelectedName.adjustsFontSizeToFitWidth=YES;
    self.pieSelectedName.hidden=NO;
//    self.pieSelectedValue.text = [[self.pieData objectAtIndex:index] objectForKey:@"value"];
    self.pieSelectedPercentage.text = [[self.pieData objectAtIndex:index ] objectForKey:@"percentage"];
    self.pieSelectedPercentage.hidden=NO;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pieData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EpmGroupDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupDetailCell" forIndexPath:indexPath];
    // Configure the cell...
    cell.conditionTitle.text = [[self.pieData objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.conditionValue.text = [[self.pieData objectAtIndex:indexPath.row] objectForKey:@"value"];
    cell.conditionPercentage.text = [[self.pieData objectAtIndex:indexPath.row ] objectForKey:@"percentage"];
    cell.conditionLast.text =[[self.pieData objectAtIndex:indexPath.row ] objectForKey:@"last"];
    cell.conditionLastPercent.text =[[self.pieData objectAtIndex:indexPath.row ] objectForKey:@"lastCompare"];
    if([[[self.pieData objectAtIndex:indexPath.row ] objectForKey:@"last"] integerValue]>[[[self.pieData objectAtIndex:indexPath.row] objectForKey:@"value"] integerValue]){
        cell.conditionLastTrend.image =[UIImage imageNamed:@"trend-down.png"];
    
    
    }
    else if ([[[self.pieData objectAtIndex:indexPath.row ] objectForKey:@"last"] integerValue]==[[[self.pieData objectAtIndex:indexPath.row] objectForKey:@"value"] integerValue]){
    cell.conditionLastTrend.image =[UIImage imageNamed:@"trend-level.png"];
    }
    
    else if ([[[self.pieData objectAtIndex:indexPath.row ] objectForKey:@"last"] integerValue]<[[[self.pieData objectAtIndex:indexPath.row] objectForKey:@"value"] integerValue]){
        cell.conditionLastTrend.image =[UIImage imageNamed:@"trend-up.png"];
    
    }
    cell.backgroundColor = [UIColor clearColor];
    __weak EpmGroupDetailTableViewCell *weakCell=cell;
    cell.compare=^(){
        CGRect rect=[self.view convertRect:weakCell.frame
                                fromView:weakCell.superview];
        DetailCompareChart *compareChart=[[DetailCompareChart alloc] init];
        compareChart.data=[NSArray arrayWithObjects:@1,@2,@10,@123,@13, nil];
        compareChart.date=[NSArray arrayWithObjects:@"2011",@"2012",@"2013",@"2014",@"2015", nil];
        self.popController=[[UIPopoverController alloc] initWithContentViewController:compareChart];
        self.popController.delegate=self;
        self.popController.popoverContentSize=CGSizeMake(550, 350);
        [self.popController presentPopoverFromRect:rect
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionDown
                                          animated:YES];
    };
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    int current = [[[self.pieData objectAtIndex:indexPath.row] objectForKey:@"value"] integerValue];
    
    
    
    //draw
//    
//    NSArray *axis =@[@"2008",@"2009",@"2010",@"2011",@"2012",@"2013",@"2014"];
//    [self.barChart setXLabels:axis];
//    NSArray * data01Array =  @[[NSNumber numberWithInt:(int)(current-current*0.2)],[NSNumber numberWithInt:(int)(current-current*0.1)],[NSNumber numberWithInt:(int)(current-current*0.3)],[NSNumber numberWithInt:(int)(current+current*0.1)],[NSNumber numberWithInt:(int)(current-current*0.4)],[NSNumber numberWithInt:(int)(current-current*0.2)],[NSNumber numberWithInt:current]];
//    
//    
//    PNLineChartData *data01 = [PNLineChartData new];
//
//    data01.color = PNWhite;
//    
//    data01.lineWidth = 1;
//    data01.itemCount = self.barChart.xLabels.count;
//    data01.getData = ^(NSUInteger index) {
//        CGFloat yValue = [[data01Array objectAtIndex:index] floatValue];
//        return [PNLineChartDataItem dataItemWithY:yValue];
//    };
//
//    
//     [self.barChart setChartData:@[data01]];
//    [self.barChart setBackgroundColor:[UIColor clearColor]];
//   
//    [self.barChart strokeChart];
//
//    
//    [UIView transitionWithView:self.barView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
//        
//        self.pieView.hidden =YES;
//        self.barView.hidden =NO;
//        
//    } completion:^(BOOL finish){
//        
//    }];
    
    
}


//collection delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [DetailPropertyModel sharedProperty].properties.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DetailPropertyModel *propertyModel=[DetailPropertyModel sharedProperty];
    OrgDeailAttributeCellView *cell=[self.attributeCollection dequeueReusableCellWithReuseIdentifier:@"attributeCollection" forIndexPath:indexPath];
    cell.attributeName.text=[[propertyModel.properties objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.attributeCount.text=@"0";

    __weak OrgDeailAttributeCellView *weakCell=cell;
  
    cell.tapCollection=^{
        ChooseProperty *chooseProperty=[[ChooseProperty alloc] init];
        chooseProperty.property=propertyModel.properties[indexPath.row];
        chooseProperty.chosedAmount=^(int number){
            weakCell.attributeCount.text=[NSString stringWithFormat:@"%d",number];
        };
        CGRect rect=[self.view convertRect:weakCell.frame
                                  fromView:weakCell.superview];
        self.popController=[[UIPopoverController alloc] initWithContentViewController:chooseProperty];
        self.popController.delegate=self;

        self.popController.popoverContentSize=CGSizeMake(200, 200);
        [self.popController presentPopoverFromRect:rect
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionUp
                                          animated:YES];
    };
    return cell;
    
}
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popController=nil;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}





//选择一个entity后返回回来
- (IBAction)unwindToGroupDetail:(UIStoryboardSegue *)unwindSegue {
    EpmGroupConditionViewController* source = unwindSegue.sourceViewController;
    self.groupByName.text = [source.selected objectForKey:@"name"];
    self.variableTitle.text = [source.selected objectForKey:@"name"];
//    [self loadDetail];
}

//选择一个entity后加载pie以及tabledata
-(void)loadDataByEntity:(int)kpi_group_id
{
   
    
}




@end
