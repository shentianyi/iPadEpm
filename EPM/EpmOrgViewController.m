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
#import "EpmSendMailController.h"
#import "AttachedPhoto.h"
#import "PNChart.h"
#import "EpmGroupViewController.h"


#import "JBLineChartView.h"
#import "JBLineChartFooterView.h"
#import "JBChartTooltipTipView.h"
#import "JBChartTooltipView.h"
#import "EpmUtility.h"

CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartPadding = 10.0f;

@interface EpmOrgViewController ()<JBLineChartViewDataSource,JBLineChartViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *selectedE1;
@property (weak, nonatomic) IBOutlet UILabel *outOfRange;
@property (weak, nonatomic) IBOutlet UILabel *average;
@property (weak, nonatomic) IBOutlet UILabel *sum;
@property (strong,nonatomic) NSMutableDictionary *currentConditions;
@property (weak, nonatomic) IBOutlet UISegmentedControl *seg;
@property (weak, nonatomic) IBOutlet UILabel *range;

@property (weak, nonatomic) IBOutlet UILabel *kpiName;
@property (weak, nonatomic) IBOutlet UILabel *kpiDesc;
@property (strong, nonatomic) NSMutableArray *lineData;
@property (strong, nonatomic) JBLineChartView *lineChartView;
@property (weak, nonatomic) IBOutlet UILabel *minCurrent;
@property (weak, nonatomic) IBOutlet UILabel *maxCurrent;
@property (nonatomic, strong) JBChartTooltipView *tooltipView;
@property (nonatomic, strong) JBChartTooltipTipView *tooltipTipView;
@property (nonatomic, assign) BOOL tooltipVisible;
@property (nonatomic, strong) NSMutableArray *dateLocate;
@end

@implementation EpmOrgViewController
//@synthesize collectionView  = _collectionView;
@synthesize kpis = _kpis;
@synthesize entityGroup = _entityGroup;
@synthesize tableData = _tableData;
@synthesize upperContainer = _upperContainer;
@synthesize currentConditions = _currentConditions;

//segue 传来
//detail.entityGroup = [sender objectForKey:@"entityGroup"];
//detail.preloadKpi = [sender objectForKey:@"kpi"];

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self initAppearance];
    [self loadData];
    
    if(self.preloadKpi){
        [self loadDataForKpi:self.preloadKpi];
    }
    
    [self.hundred addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(respondToTapGesture:)]];
    [self.ten addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(respondToTapGesture:)]];
    [self.bit addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                    initWithTarget:self action:@selector(respondToTapGesture:)]];
    [self.frequency addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(respondToTapGesture:)]];
}
-(void) initAppearance{
    [self DatePickerAppearance];
}
-(void)loadData{
    self.navigationItem.title=[self.entityGroup objectForKey:@"name"];
    self.kpiName.text=[self.preloadKpi objectForKey:@"name"];
    self.kpiDesc.text=[self.preloadKpi objectForKey:@"description"];
    
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
        //        [self.collectionView reloadData];
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)viewDidAppear:(BOOL)animated{
    // [self changeLayoutWithOrientation:(UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation];
  
    [self moveScrollView:self.ten ToPage:1];
    [self moveScrollView:self.bit ToPage:4];
}


-(void)getDataForTable{

     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
  //  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:[Kpi objectForKey:@"id"],@"kpi_id",@"100",@"frequency",[self.entityGroup objectForKey:@"id"],@"entity_group_id",[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-1296000]],@"start_time",[formatter stringFromDate:[NSDate date]], @"end_time",nil];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"data"]] parameters:self.currentConditions success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *result = (NSDictionary *)responseObject;
        
        self.tableData = result;
        [self.tableView reloadData];
        [self loadKpiSummery];
        [self loadChart];
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

/////////////////////////////////////////////////////////////////////////  load chart
-(void)loadChart{
    if(self.tableData){
        self.dateLocate=[[self.tableData objectForKey:@"date"] mutableCopy];
        for(int i=0;i<[self.dateLocate count];i++){
            [self.dateLocate replaceObjectAtIndex:i withObject:[EpmUtility convertDatetimeWithString:[[self.dateLocate objectAtIndex:i] substringToIndex:18] OfPattern:@"yyyy-MM-dd HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]]]];
        }
        
        NSLog(@"%@",self.tableData);
        self.lineData=[NSMutableArray array];
        [self.lineData addObject:[self.tableData objectForKey:@"current"]];
//        NSLog(@"%@",self.lineData);
        
        for (UIView *view in self.chartBody.subviews){
            [view removeFromSuperview];
        }
        if(self.lineChartView){
            [self.lineChartView removeFromSuperview];
            self.lineChartView=nil;
        }

        self.lineChartView=[[JBLineChartView alloc] init];
        self.lineChartView.frame=[self.view convertRect:self.chartBody.frame fromView:self.chartview];
        [self.view addSubview:self.lineChartView];
        self.lineChartView.delegate=self;
        self.lineChartView.dataSource=self;
        [self.lineChartView reloadData];
        
        NSComparator cmptr = ^(id obj1, id obj2){
            if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        NSArray *currentOrderArray = [[self.tableData objectForKey:@"current"] sortedArrayUsingComparator:cmptr];
        self.minCurrent.text=[NSString stringWithFormat:@"%d",[currentOrderArray.firstObject intValue]];
        self.maxCurrent.text=[NSString stringWithFormat:@"%d",[currentOrderArray.lastObject intValue]];
        
        JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartFooterHeight)];
        footerView.backgroundColor = [UIColor clearColor];
        footerView.leftLabel.text = @"2014-04-16";
        footerView.leftLabel.textColor = [UIColor whiteColor];
        footerView.rightLabel.text = @"2014-04-30";
        footerView.rightLabel.textColor = [UIColor whiteColor];
        footerView.sectionCount = [[self.tableData objectForKey:@"current"] count];
        self.lineChartView.footerView = footerView;
        
        
        
//         PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:self.chartBody.bounds];
//        NSArray *axis =[self prepareTimeAxis:[self.tableData objectForKey:@"date"] WithLimit:5];
//        [lineChart setXLabels:axis];
//        NSArray * data01Array = [self.tableData objectForKey:@"target_max"];
//        PNLineChartData *data01 = [PNLineChartData new];
//        data01.color = [[UIColor alloc] initWithRed:128.0 green:128.0 blue:128.0 alpha:0.25];
//        
//        data01.lineWidth = 1;
//        data01.itemCount = lineChart.xLabels.count;
//        data01.getData = ^(NSUInteger index) {
//            CGFloat yValue = [[data01Array objectAtIndex:index] floatValue];
//            return [PNLineChartDataItem dataItemWithY:yValue];
//        };
//        // Line Chart No.2
//        NSArray * data02Array = [self.tableData objectForKey:@"target_min"];
//        PNLineChartData *data02 = [PNLineChartData new];
//        data02.color = [[UIColor alloc] initWithRed:128.0 green:128.0 blue:128.0 alpha:0.25];;
//        data02.lineWidth = 1;
//        data02.itemCount = lineChart.xLabels.count;
//        data02.getData = ^(NSUInteger index) {
//            CGFloat yValue = [[data02Array objectAtIndex:index] floatValue];
//            return [PNLineChartDataItem dataItemWithY:yValue];
//        };
//        
//        // Line Chart No.2
//        NSArray * data03Array = [self.tableData objectForKey:@"current"];
//        PNLineChartData *data03 = [PNLineChartData new];
//        data03.color = PNWhite;
//        data03.lineWidth = 2;
//        data03.itemCount = lineChart.xLabels.count;
//        data03.getData = ^(NSUInteger index) {
//            CGFloat yValue = [[data03Array objectAtIndex:index] floatValue];
//            return [PNLineChartDataItem dataItemWithY:yValue];
//        };
//        
//        //lineChart.chartData = @[data01, data02,data03];
//        [lineChart setChartData:@[data01,data02,data03]];
//        lineChart.backgroundColor = [UIColor clearColor];
//        [lineChart strokeChart];
//        lineChart.delegate = self;
//        [self.chartBody addSubview:lineChart];
    }

}

//-(NSArray *)prepareTimeAxis:(NSArray *)axis WithLimit:(int)limit{
//    if(limit<2){
//        limit =2;
//    }
//    
//    if(!axis){
//        axis = [[NSArray alloc]init];
//    }
//    
//    if(axis.count<=limit){
//        return axis;
//    }
//    else{
//        NSMutableArray  *tmp = [NSMutableArray arrayWithArray:axis];
//        int *last = axis.count-1;
//        
//        int inteval = (int)(((axis.count -2)/(limit-2))+0.5);
//        int next = inteval;
//        for(int i=0; i<axis.count;i++){
//            if(i>0){
//                if(i!=next && i!=last){
//                    [tmp replaceObjectAtIndex:i withObject:@""];
//                    
//                }
//                else {
//                    [tmp replaceObjectAtIndex:i withObject:[EpmUtility convertDatetimeWithString:[[tmp objectAtIndex:i] substringToIndex:18] OfPattern:@"yyyy-MM-dd HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]]]];
//                    
//
//                    next = i + inteval;
//                }
//                
//            }
//            else {
//                  [tmp replaceObjectAtIndex:i withObject:[EpmUtility convertDatetimeWithString:[[tmp objectAtIndex:i] substringToIndex:18] OfPattern:@"yyyy-MM-dd HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]]]];
//            
//            }
//        }
//        axis=tmp;
//    }
//    
//    return axis;
//
//}

-(void)loadKpiSummery{
    self.average.text = [NSString stringWithFormat:@"%0.2f",[[self.tableData objectForKey:@"average" ]floatValue]];
    self.sum.text =  [NSString stringWithFormat:@"%0.2f",[[self.tableData objectForKey:@"total" ]floatValue]];

    self.selectedE1.text = [self.currentConditions objectForKey:@"kpi_name"];

    NSArray *current =[self.tableData objectForKey:@"current"];
    NSArray *min=[self.tableData objectForKey:@"target_min"];
    NSArray *max=[self.tableData objectForKey:@"target_max"];
    int abnormal = 0;
    for(int i= 0; i<current.count;i++){
        if([[current objectAtIndex:i] floatValue] > [[max objectAtIndex:i]floatValue] || [[current objectAtIndex:i ]floatValue]<[[min objectAtIndex:i ]floatValue ]){
            abnormal ++;
        }
    }
    self.outOfRange.text = [NSString stringWithFormat:@"%d",abnormal];
}






- (IBAction)changeAverage:(id)sender {
     NSInteger index = self.seg.selectedSegmentIndex;
    
    if(index==0){
         [self.currentConditions setObject:@YES forKey:@"average"];
    }
    else{
     [self.currentConditions setObject:@NO forKey:@"average"];
    }
    
}



-(void)respondToTapGesture:(UITapGestureRecognizer*)sender {
    UIScrollView *source = (UIScrollView* )sender.view;
    source.delaysContentTouches = NO;
    // source.delaysContentTouches = YES;

    
//    frame.origin.y = frame.origin.y - 40;
//    [source scrollRectToVisible:frame animated:YES];
    
    //    CGRect frame = sender.view.frame;
//    frame.origin.y = frame.origin.y +5;
    
    
//    CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
//    anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, -10.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, 10.0f, 0.0f) ] ] ;
//    anim.autoreverses = YES ;
//    anim.repeatCount = 1.0f ;
//    anim.duration = 2.0f ;
//    
//    [ sender.view.layer addAnimation:anim forKey:nil ] ;
    
 


}


-(NSArray *)numberSequence:(BOOL)hasZero{
    if(hasZero){
        return @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    }
    
    else {
        return @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    }
}

-(NSArray *)freqSequence{
    return @[NSLocalizedString(@"DAY", nil),NSLocalizedString(@"WEEK", nil),NSLocalizedString(@"MONTH", nil),NSLocalizedString(@"QUARTER", nil),NSLocalizedString(@"YEAR", nil)];
}




-(void)DatePickerAppearance{
    UIColor *color = [UIColor whiteColor];
    CGFloat borderWidth = 0.5f;
    CGFloat radius = 3.0f;
    
    
    
    NSArray *arr = @[self.hundred,self.ten,self.bit,self.frequency];
    
    for(UIScrollView* view in arr){
        view.layer.borderColor = [color CGColor];
        view.layer.borderWidth = borderWidth;
        view.layer.cornerRadius =radius;
        //add content for
    }
    
    self.hundred.contentSize = CGSizeMake(self.hundred.bounds.size.width, self.hundred.bounds.size.height*10);
    self.ten.contentSize = CGSizeMake(self.ten.bounds.size.width, self.ten.bounds.size.height*10);
    self.bit.contentSize = CGSizeMake(self.bit.bounds.size.width, self.bit.bounds.size.height*10);
    self.frequency.contentSize = CGSizeMake(self.frequency.bounds.size.width, self.frequency.bounds.size.height*[[self freqSequence]count]);
    
     CGPoint last  = CGPointMake(0,0);
    
    for(NSString *text in [self numberSequence:YES]){
        [self.hundred addSubview:[self scrollerMaker:text inRect:CGRectMake(0, last.y, self.hundred.bounds.size.width, self.hundred.bounds.size.height) fontSize:75]];
        [self.ten addSubview:[self scrollerMaker:text inRect:CGRectMake(0, last.y, self.ten.bounds.size.width, self.ten.bounds.size.height) fontSize:75]];
        last.y=last.y + self.hundred.bounds.size.height;
    }
    last.y=0;
    
    for(NSString *text in [self numberSequence:NO]){
        [self.bit addSubview:[self scrollerMaker:text inRect:CGRectMake(0, last.y, self.bit.bounds.size.width, self.bit.bounds.size.height) fontSize:75]];
        last.y =last.y + self.bit.bounds.size.height;

    }
    last.y=0;
    for(NSString *text in [self freqSequence]){
        [self.frequency addSubview:[self scrollerMaker:text inRect:CGRectMake(0, last.y, self.frequency.bounds.size.width, self.frequency.bounds.size.height) fontSize:35]];
        last.y =last.y + self.frequency.bounds.size.height;
    }
    
   
    
}



-(UIView *)scrollerMaker:(NSString *)text inRect:(CGRect)frame fontSize:(int)size{
    

    UIView *view = [[UIView alloc]initWithFrame:frame];
    
    CGRect labelRect = view.frame;
    
    labelRect.origin.y = 0;
    
    UILabel *label = [[UILabel alloc]initWithFrame:labelRect];
    
    label.textAlignment=NSTextAlignmentCenter;
    
    view.backgroundColor = [UIColor clearColor];
    
    label.text = text;
    
    label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size];
    
    label.textColor = [UIColor whiteColor];
    
    [view addSubview:label];
    
//    NSLog(@"%@",view);
    
    return view;
}



-(void)loadDataForKpi:(NSDictionary *)kpi{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    if(self.currentConditions){
        [self.currentConditions setObject:[kpi objectForKey:@"id"] forKey:@"kpi_id"];
         [self.currentConditions setObject:[kpi objectForKey:@"name"] forKey:@"kpi_name"];
    
    }
    else {
        self.currentConditions = [NSMutableDictionary dictionaryWithObjectsAndKeys:[kpi objectForKey:@"id"],@"kpi_id",@"100",@"frequency",[self.entityGroup objectForKey:@"id"],@"entity_group_id",[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-1*14*24*60*60]],@"start_time",[formatter stringFromDate:[NSDate date]], @"end_time",[self.entityGroup objectForKey:@"name"],@"entity_group_name",[kpi objectForKey:@"name"],@"kpi_name",nil];
    
    }

    
     [self getDataForTable];
    
}



- (IBAction)btCompose:(id)sender {
    NSMutableDictionary *completeData = [[NSMutableDictionary alloc]init];
    
    
        
    if(self.currentConditions){
        [completeData setObject:self.currentConditions forKey:@"orgCondition"];
    }
    
    
    if(self.tableData){
        [completeData setObject:self.tableData forKey:@"orgKpiData"];
    }
    
    AttachedPhoto *screen = [[AttachedPhoto alloc]initWithIdFilledAndImage: [EpmGraphicUtility FullScreenshotForCurrentWindow:self.view]];
   
    [completeData setObject:[NSArray arrayWithObjects:screen, nil] forKey:@"photos"];
    
    [self performSegueWithIdentifier:@"composeFromDetail" sender:completeData];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"composeFromDetail"]){
        EpmSendMailController *mail = segue.destinationViewController;
        mail.completeData = (NSMutableDictionary*)sender;
    }
    else if([segue.identifier isEqualToString:@"viewGroupDetail"]){
        EpmGroupViewController *group = segue.destinationViewController;
        group.entityName = [sender objectForKey:@"entity_group_name"];
        group.kpiName = [sender objectForKey:@"kpi_name"];
        group.kpiId = [[sender objectForKey:@"kpi_id"] stringValue];
    }
}



//每个section显示的标题

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}



//指定有多少个分区(Section)，默认为1

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}



//指定每个分区中有多少行，默认为1

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[self.tableData objectForKey:@"current" ] count];
}

- (IBAction)transactionTable:(id)sender {
//    [UIView transitionFromView:self.chartview
//                        toView:self.tableView
//                      duration:1
//                       options:UIViewAnimationOptionTransitionFlipFromRight | UIViewAnimationCurveEaseIn | UIViewAnimationOptionShowHideTransitionViews
//                    completion:^(BOOL finished)
//     {
//         self.chartview.hidden =YES;
//         self.tableView.hidden =NO;
//         
//     }
//     ];
    
    [UIView transitionWithView:self.lineChartView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.lineChartView.hidden =YES;
        self.tableView.hidden =NO;
    
    } completion:^(BOOL finish){
      
    }];
    
}

- (IBAction)transactionChart:(id)sender {
    
    [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
    
        self.lineChartView.hidden =NO;
        self.tableView.hidden =YES;

    } completion:^(BOOL finish){

    }];

}

//绘制Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *CellIdentifier = @"infoCell";
    
    
    EpmTableCell *cell = (EpmTableCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    
      NSString *date =[[self.tableData objectForKey:@"date"] objectAtIndex:indexPath.row];
    NSNumber *current =[[self.tableData objectForKey:@"current"] objectAtIndex:indexPath.row];
    NSString *unit = [[self.tableData objectForKey:@"unit"] objectAtIndex:indexPath.row];
    NSNumber *min=[[self.tableData objectForKey:@"target_min"] objectAtIndex:indexPath.row];
    NSNumber *max=[[self.tableData objectForKey:@"target_max"] objectAtIndex:indexPath.row];
    
    NSString *convert = [EpmUtility convertDatetimeWithString:[date substringToIndex:18] OfPattern:@"yyyy-MM-dd HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]] ];
    
    cell.time.text = convert;

    cell.value.text = [[NSString stringWithFormat:@"%0.2f",[current doubleValue]] stringByAppendingString:unit];
    
    cell.range.text = [NSString stringWithFormat:@"%0.2f-%0.2f %@",[min floatValue],[max floatValue],unit];

    if(indexPath.row > 0 ) {
          NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        float last =[[[self.tableData objectForKey:@"current"] objectAtIndex:newPath.row] floatValue];
        float trend = [current floatValue] - last ;
        if(last==0.0){
            last = 1.0;
        }
        if(trend > 0){
            cell.trend.image = [UIImage imageNamed:@"trend-up"];
        }
        
        else if (trend == 0){
            cell.trend.image = [UIImage imageNamed:@"trend-level"];
        }
        
        else{
            cell.trend.image = [UIImage imageNamed:@"trend-down"];
        }
        
    
    }
    
    
    float completion=0.0;
    if([current doubleValue] < [min doubleValue]){
        completion = [current floatValue] / ([min floatValue]+0.0000000001);
        cell.inrange.text = [NSString stringWithFormat:@"%d%% %@",(int)completion*100,NSLocalizedString(@"LOWER", nil)];
        cell.inrange.textColor = PNRed;
    }
    
    if([current doubleValue] > [max doubleValue]){
        completion = [current floatValue] / ([max floatValue]+0.0000000001);

        cell.inrange.text = [NSString stringWithFormat:@"%d%% %@",(int)completion*100,NSLocalizedString(@"UPPER", nil)];
        cell.inrange.textColor = PNRed;
    }
    
    
    else{
        cell.inrange.text = NSLocalizedString(@"NORMAL", nil);
        cell.inrange.textColor = [UIColor whiteColor];
      
    }

    //trend
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return nil;
}



#pragma scrollview delegate
-(void)didScrollViewEndToUpdateCondition:(UIScrollView*)scrollView{
    BOOL needRefresh = NO;
    
    if(scrollView == self.frequency){
        NSString *freq = [[self freqSequence] objectAtIndex: [self scrollViewCurrentPage:scrollView]];
//        NSLog(@"%@",freq);
        if([freq isEqualToString:NSLocalizedString(@"DAY", nil)]){
            [self.currentConditions setObject:@"100" forKey:@"frequency"];
            needRefresh = YES;
        
        }
        if([freq isEqualToString:NSLocalizedString(@"WEEK", nil)]){
            [self.currentConditions setObject:@"200" forKey:@"frequency"];
            needRefresh = YES;
            
        }
        if([freq isEqualToString:NSLocalizedString(@"MONTH", nil)]){
            [self.currentConditions setObject:@"300" forKey:@"frequency"];
            needRefresh = YES;
            
        }
        if([freq isEqualToString:NSLocalizedString(@"QUARTER", nil)]){
            [self.currentConditions setObject:@"400" forKey:@"frequency"];
            needRefresh = YES;
            
        }
        if([freq isEqualToString:NSLocalizedString(@"YEAR", nil)]){
            [self.currentConditions setObject:@"500" forKey:@"frequency"];
            needRefresh = YES;
            
        }
    }
    
    if(scrollView == self.hundred || scrollView== self.ten || scrollView || self.bit) {
        NSString *number = [NSString stringWithFormat:@"%@%@%@",[[self numberSequence:YES]objectAtIndex:[self scrollViewCurrentPage:self.hundred]],[[self numberSequence:YES]objectAtIndex:[self scrollViewCurrentPage:self.ten]],[[self numberSequence:YES]objectAtIndex:[self scrollViewCurrentPage:self.bit]]];
    
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        [self.currentConditions setObject:[self dateSinceNow:[number integerValue]* -1 OfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]] forKey:@"start_time"];
        needRefresh = YES;
        NSLog(@"%@",self.currentConditions);
    }
    if(needRefresh){
        [self getDataForTable];
    
    }
}

-(NSDate *)dateSinceNow:(int)offset OfFrequency:(int)frequency{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSDateComponents *timeOffset = [[NSDateComponents alloc]init];
    

    if(frequency==100) {
        [timeOffset setDay:offset ];
        
    }
    if(frequency==200) {
        [timeOffset setWeek:offset ];

    }
    if(frequency==300) {
        [timeOffset setMonth:offset];

    }
    if(frequency==400) {
        [timeOffset setMonth:offset*3];
       
    }
    if(frequency==500) {
        [timeOffset setYear:offset];
    }
    
    return  [calender dateByAddingComponents:timeOffset toDate:[NSDate date] options:0];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(scrollView != self.tableView){
         [self moveToNearest:scrollView];
        [self didScrollViewEndToUpdateCondition:scrollView];
    }
   
}


-(int)scrollViewCurrentPage:(UIScrollView *)scrollView {
    return (int)((scrollView.contentOffset.y / scrollView.frame.size.height)+ 0.5);
}



-(CGRect)scrollTargetRect:(UIScrollView*)scrollView{
    CGRect frame = scrollView.frame;
    frame.origin.y = frame.size.height * [self scrollViewCurrentPage:scrollView];
    frame.origin.x = 0;
    return frame;
}





-(void)moveToNearest:(UIScrollView *)scrollView{
    CGRect frame = [self scrollTargetRect:scrollView];
    [scrollView scrollRectToVisible:frame animated:YES];
    
}

-(void)moveScrollView:(UIScrollView *)scrollView ToPage:(int)page{
    CGRect frame = scrollView.frame;
    frame.origin.y = frame.size.height * page;
    frame.origin.x = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
   
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if(!decelerate && scrollView != self.tableView){
        
        [self moveToNearest:scrollView];
        [self didScrollViewEndToUpdateCondition:scrollView];
        
    }
    
}
- (IBAction)viewGroup:(id)sender {
    [self performSegueWithIdentifier:@"viewGroupDetail" sender:self.currentConditions];
}


#pragma chart delegate
-(void)userClickedOnLineKeyPoint:(CGPoint)point lineIndex:(NSInteger)lineIndex andPointIndex:(NSInteger)pointIndex{
   
    
    //not target line
    if(lineIndex!=0 && lineIndex !=2){
        NSString *date =[[self.tableData objectForKey:@"date"] objectAtIndex:pointIndex];
        NSNumber *current =[[self.tableData objectForKey:@"current"] objectAtIndex:pointIndex];
        NSString *unit = [[self.tableData objectForKey:@"unit"] objectAtIndex:pointIndex];
        NSNumber *min=[[self.tableData objectForKey:@"target_min"] objectAtIndex:pointIndex];
        NSNumber *max=[[self.tableData objectForKey:@"target_max"] objectAtIndex:pointIndex];
        
        NSString *convert = [EpmUtility convertDatetimeWithString:[date substringToIndex:18] OfPattern:@"yyyy-MM-dd HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]] ];
        
        self.chartHeadTime.text = convert;
        
        self.chartHeadValue.text = [[NSString stringWithFormat:@"%0.2f",[current doubleValue]] stringByAppendingString:unit];
        
        self.chartHeadTarget.text = [NSString stringWithFormat:@"%0.2f-%0.2f %@",[min floatValue],[max floatValue],unit];
        
        
        if([current doubleValue] < [min doubleValue]){
            self.chartHeadCompletion.text = NSLocalizedString(@"LOWER", nil);
            self.chartHeadCompletion.textColor = PNRed;
        }
        
        if([current doubleValue] > [max doubleValue]){
            
            self.chartHeadCompletion.text = NSLocalizedString(@"UPPER", nil);
            self.chartHeadCompletion.textColor = PNRed;

        }
        
        
        else{
            self.chartHeadCompletion.text = NSLocalizedString(@"NORMAL", nil);
            self.chartHeadCompletion.textColor = [UIColor whiteColor];
        }

        
    }
}

-(void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex{
    }

#pragma jbline delegate
- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return [self.lineData count];
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [[self.tableData objectForKey:@"date"] count];
}
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    
    return [[[self.lineData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue];
}
//event

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setText:[self.dateLocate objectAtIndex:horizontalIndex]];
    [self.tooltipView setValue:[NSString stringWithFormat:@"%d",[[[self.lineData objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] intValue]]];
}
- (void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    [self setTooltipVisible:NO animated:YES];
}
//custom
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor];
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 3.0f; // width of line in chart
}
- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex{
    return YES;
}
//- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
//{
//    return JBLineChartViewLineStyleDashed; // style of line in chart
//}
//tooltip
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated atTouchPoint:(CGPoint)touchPoint
{
    self.tooltipVisible = tooltipVisible;
    
    JBChartView *chartView = self.lineChartView;
    
    if (!self.tooltipView)
    {
        self.tooltipView = [[JBChartTooltipView alloc] init];
        self.tooltipView.alpha = 0.0;
        [self.view addSubview:self.tooltipView];
    }
    
    if (!self.tooltipTipView)
    {
        self.tooltipTipView = [[JBChartTooltipTipView alloc] init];
        self.tooltipTipView.alpha = 0.0;
        [self.view addSubview:self.tooltipTipView];
    }
    
    dispatch_block_t adjustTooltipPosition = ^{
        CGPoint originalTouchPoint = [self.view convertPoint:touchPoint fromView:chartView];
        CGPoint convertedTouchPoint = originalTouchPoint; // modified
        JBChartView *chartView = self.lineChartView;

        if (chartView)
        {
            CGFloat minChartX = (chartView.frame.origin.x + ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x < minChartX)
            {
                convertedTouchPoint.x = minChartX;
            }
            CGFloat maxChartX = (chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5));
            if (convertedTouchPoint.x > maxChartX)
            {
                convertedTouchPoint.x = maxChartX;
            }
            self.tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5), self.chartview.frame.origin.y+85, self.tooltipView.frame.size.width, self.tooltipView.frame.size.height);
            
            CGFloat minTipX = (chartView.frame.origin.x + self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x < minTipX)
            {
                originalTouchPoint.x = minTipX;
            }
            CGFloat maxTipX = (chartView.frame.origin.x + chartView.frame.size.width - self.tooltipTipView.frame.size.width);
            if (originalTouchPoint.x > maxTipX)
            {
                originalTouchPoint.x = maxTipX;
            }
            self.tooltipTipView.frame = CGRectMake(originalTouchPoint.x - ceil(self.tooltipTipView.frame.size.width * 0.5),self.chartview.frame.origin.y+85+self.tooltipView.frame.size.height, self.tooltipTipView.frame.size.width, self.tooltipTipView.frame.size.height);
        }
    };
    
    dispatch_block_t adjustTooltipVisibility = ^{
        self.tooltipView.alpha = _tooltipVisible ? 1.0 : 0.0;
        self.tooltipTipView.alpha = _tooltipVisible ? 1.0 : 0.0;
	};
    
    if (tooltipVisible)
    {
        adjustTooltipPosition();
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.25f animations:^{
            adjustTooltipVisibility();
        } completion:^(BOOL finished) {
            if (!tooltipVisible)
            {
                adjustTooltipPosition();
            }
        }];
    }
    else
    {
        adjustTooltipVisibility();
    }
}
- (void)setTooltipVisible:(BOOL)tooltipVisible animated:(BOOL)animated
{
    [self setTooltipVisible:tooltipVisible animated:animated atTouchPoint:CGPointZero];
}

@end
