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

@interface EpmGroupViewController ()
@property (weak, nonatomic) IBOutlet UILabel *kpiNameLb;
@property (weak, nonatomic) IBOutlet UILabel *entityNameLb;
@property (weak, nonatomic) IBOutlet UILabel *groupByName;
@property (weak, nonatomic) IBOutlet UIView *groupByView;
@property (weak, nonatomic) IBOutlet UILabel *pieSelectedName;
@property (weak, nonatomic) IBOutlet UILabel *pieSelectedValue;
@property (weak, nonatomic) IBOutlet UILabel *pieSelectedPercentage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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


@end

@implementation EpmGroupViewController
- (IBAction)selectGroupCondition:(id)sender {
}


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
    
    
    
    self.kpiId = @"127";
    
    self.sliceColors =[NSArray arrayWithObjects:
                       [UIColor colorWithRed:246/255.0 green:155/255.0 blue:0/255.0 alpha:0.8],
                       [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:0.8],
                       [UIColor colorWithRed:62/255.0 green:173/255.0 blue:219/255.0 alpha:0.8],
                       [UIColor colorWithRed:229/255.0 green:66/255.0 blue:115/255.0 alpha:0.8],
                       [UIColor colorWithRed:148/255.0 green:141/255.0 blue:139/255.0 alpha:0.8],nil];
    
    self.entityNameLb.text = self.entityName;
    self.kpiNameLb.text = self.kpiName;
    
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
   
}


-(void)loadDetail{
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"tmpGroupDetails" ofType:@"plist"];
    
    NSDictionary *settings   = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
   
    
    self.groupItems = [[settings objectForKey:@"groupItem"] objectForKey:self.kpiId];
    self.groupData = [[settings objectForKey:@"groupData"] objectForKey:self.kpiId];
    

    if(!self.currentCondition && self.groupItems.count>0) {
        self.currentCondition = [self.groupItems objectAtIndex:0];
    }
    
    self.groupByName.text = self.currentCondition;
    self.variableTitle.text = self.currentCondition;
    
    self.pieData = [self.groupData objectForKey:self.currentCondition];
    
         
    [self.pieContainer reloadData];
    [self.tableView reloadData];
  
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pieContainer reloadData];
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
    NSLog(@"will select slice at index %ld",index);
}


- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %ld",index);
}


- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
   
}


- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %ld",index);
    self.pieSelectedName.text = [[self.pieData objectAtIndex:index] objectForKey:@"name"];
    self.pieSelectedValue.text = [[self.pieData objectAtIndex:index] objectForKey:@"value"];
    self.pieSelectedPercentage.text = [[self.pieData objectAtIndex:index ] objectForKey:@"percentage"];
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
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int current = [[[self.pieData objectAtIndex:indexPath.row] objectForKey:@"value"] integerValue];
    
    
    
    //draw
    
    NSArray *axis =@[@"2008",@"2009",@"2010",@"2011",@"2012",@"2013",@"2014"];
    [self.barChart setXLabels:axis];
    NSArray * data01Array =  @[[NSNumber numberWithInt:(int)(current-current*0.2)],[NSNumber numberWithInt:(int)(current-current*0.1)],[NSNumber numberWithInt:(int)(current-current*0.3)],[NSNumber numberWithInt:(int)(current+current*0.1)],[NSNumber numberWithInt:(int)(current-current*0.4)],[NSNumber numberWithInt:(int)(current-current*0.2)],[NSNumber numberWithInt:current]];
    
    
    PNLineChartData *data01 = [PNLineChartData new];

    data01.color = PNWhite;
    
    data01.lineWidth = 1;
    data01.itemCount = self.barChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [[data01Array objectAtIndex:index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };

    
     [self.barChart setChartData:@[data01]];
    [self.barChart setBackgroundColor:[UIColor clearColor]];
   
    [self.barChart strokeChart];

    
    [UIView transitionWithView:self.barView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        
        self.pieView.hidden =YES;
        self.barView.hidden =NO;
        
    } completion:^(BOOL finish){
        
    }];
    
    
}









- (IBAction)unwindToGroupDetail:(UIStoryboardSegue *)unwindSegue {
    EpmGroupConditionViewController* source = unwindSegue.sourceViewController;
    self.currentCondition = source.selected;
    self.groupByName.text = self.currentCondition;
    self.variableTitle.text = self.currentCondition;
    [self loadDetail];
}






@end
