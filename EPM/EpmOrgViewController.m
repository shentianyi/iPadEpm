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

@interface EpmOrgViewController ()
@property (weak, nonatomic) IBOutlet UILabel *selectedE1;
@property (weak, nonatomic) IBOutlet UILabel *outOfRange;
@property (weak, nonatomic) IBOutlet UILabel *average;
@property (weak, nonatomic) IBOutlet UILabel *sum;
@property (strong,nonatomic) NSMutableDictionary *currentConditions;
@property (weak, nonatomic) IBOutlet UISegmentedControl *seg;
@property (weak, nonatomic) IBOutlet UILabel *range;
@end

@implementation EpmOrgViewController
@synthesize collectionView  = _collectionView;
@synthesize kpis = _kpis;
@synthesize entityGroup = _entityGroup;
@synthesize tableData = _tableData;
@synthesize upperContainer = _upperContainer;
@synthesize currentConditions = _currentConditions;


-(void)viewDidAppear:(BOOL)animated{
    // [self changeLayoutWithOrientation:(UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation];
  
    [self moveScrollView:self.ten ToPage:1];
    [self moveScrollView:self.bit ToPage:4];
     }



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    
    }
    return self;
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


-(void)loadChart{
    if(self.tableData){
        for (UIView *view in self.chartBody.subviews){
            [view removeFromSuperview];
        }
         PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:self.chartBody.bounds];
        NSArray *axis =[self prepareTimeAxis:[self.tableData objectForKey:@"date"] WithLimit:5];
        [lineChart setXLabels:axis];
        NSArray * data01Array = [self.tableData objectForKey:@"target_max"];
        PNLineChartData *data01 = [PNLineChartData new];
        data01.color = [[UIColor alloc] initWithRed:128.0 green:128.0 blue:128.0 alpha:0.25];
        
        data01.lineWidth = 1;
        data01.itemCount = lineChart.xLabels.count;
        data01.getData = ^(NSUInteger index) {
            CGFloat yValue = [[data01Array objectAtIndex:index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        // Line Chart No.2
        NSArray * data02Array = [self.tableData objectForKey:@"target_min"];
        PNLineChartData *data02 = [PNLineChartData new];
        data02.color = [[UIColor alloc] initWithRed:128.0 green:128.0 blue:128.0 alpha:0.25];;
        data02.lineWidth = 1;
        data02.itemCount = lineChart.xLabels.count;
        data02.getData = ^(NSUInteger index) {
            CGFloat yValue = [[data02Array objectAtIndex:index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        // Line Chart No.2
        NSArray * data03Array = [self.tableData objectForKey:@"current"];
        PNLineChartData *data03 = [PNLineChartData new];
        data03.color = PNWhite;
        data03.lineWidth = 2;
        data03.itemCount = lineChart.xLabels.count;
        data03.getData = ^(NSUInteger index) {
            CGFloat yValue = [[data03Array objectAtIndex:index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        
        //lineChart.chartData = @[data01, data02,data03];
        [lineChart setChartData:@[data01,data02,data03]];
        lineChart.backgroundColor = [UIColor clearColor];
        [lineChart strokeChart];
        lineChart.delegate = self;
        [self.chartBody addSubview:lineChart];
    }

}

-(NSArray *)prepareTimeAxis:(NSArray *)axis WithLimit:(int)limit{
    if(limit<2){
        limit =2;
    }
    
    if(!axis){
        axis = [[NSArray alloc]init];
    }
    
    if(axis.count<=limit){
        return axis;
    }
    else{
        NSMutableArray  *tmp = [NSMutableArray arrayWithArray:axis];
        int *last = axis.count-1;
        
        int inteval = (int)(((axis.count -2)/(limit-2))+0.5);
        int next = inteval;
        for(int i=0; i<axis.count;i++){
            if(i>0){
                if(i!=next && i!=last){
                    [tmp replaceObjectAtIndex:i withObject:@""];
                    
                }
                else {
                    [tmp replaceObjectAtIndex:i withObject:[EpmUtility convertDatetimeWithString:[[tmp objectAtIndex:i] substringToIndex:18] OfPattern:@"yyyy-MM-dd HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]]]];
                    

                    next = i + inteval;
                }
                
            }
            else {
                  [tmp replaceObjectAtIndex:i withObject:[EpmUtility convertDatetimeWithString:[[tmp objectAtIndex:i] substringToIndex:18] OfPattern:@"yyyy-MM-dd HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]]]];
            
            }
        }
        axis=tmp;
    }
    
    return axis;

}

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



-(void)loadData{
    self.entityName.text = [self.entityGroup objectForKey:@"name"];
    self.entityDesc.text = [self.entityGroup objectForKey:@"description"];
    
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


- (IBAction)changeAverage:(id)sender {
     NSInteger index = self.seg.selectedSegmentIndex;
    
    if(index==0){
         [self.currentConditions setObject:@YES forKey:@"average"];
    }
    else{
     [self.currentConditions setObject:@NO forKey:@"average"];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

    LineLayout * flowLayout = [[LineLayout alloc] init];
    self.collectionView.collectionViewLayout = flowLayout;
//    self.webView.delegate=self;
    
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
-(void) initAppearance{
    [self DatePickerAppearance];
    
    

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
    
    NSLog(@"%@",view);
    
    return view;
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
    cell.category.image = [UIImage imageNamed:[NSString stringWithFormat:@"kpiCategory-%@",[[currentDic    objectForKey:@"kpi_category_id"]stringValue ]]];

    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIView *snap = [cell snapshotViewAfterScreenUpdates:YES];
    snap.frame = cell.frame;
    [self.collectionView addSubview:snap];
    [UIView animateWithDuration:0.5 animations:^{
        [snap setBounds:self.upperContainer.bounds];
        snap.layer.opacity = 0;
    } completion:^(BOOL finished) {
        [snap removeFromSuperview];
    }];

    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [self loadDataForKpi:[self.kpis objectAtIndex:indexPath.row]];
    
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


//
//
//
//-(void)BeginLoadWebWithKpi:(NSDictionary*)Kpi
//{
//    
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    
//    NSString *queryString = [NSString stringWithFormat:@"kpi_id=%@&kpi_name=%@&frequency=%@&entity_group_id=%@&entity_group_name=%@&average=YES&start_time=%@&end_time=%@",[Kpi objectForKey:@"id"],[Kpi objectForKey:@"name" ],@"100",[self.entityGroup objectForKey:@"id"],[self.entityGroup objectForKey:@"name"],[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-1296000]],[formatter stringFromDate:[NSDate date]]];
//
//    
//    NSString *urlTxt =[EpmHttpUtil escapeUrl:[NSString stringWithFormat:@"%@%@?%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey:@"graph"],queryString]];
//    
//    NSURL* url = [[ NSURL alloc] initWithString :urlTxt];
//    
//    NSMutableURLRequest *request = [EpmHttpUtil initWithCookiesWithUrl:url];
//    
//    [self.webView loadRequest:request];
//    
//}

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


//
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [self.indicator stopAnimating];
//    
//    int status = [EpmHttpUtil getLastHttpStatusCodeWithRequest:self.webView.request];
//    
//     [self.webView stringByEvaluatingJavaScriptFromString:@"orientationChange()"];
//    
//    if (status>=400){
//        
//        NSString *msg=[EpmHttpUtil notificationWithStatusCode:status];
//        
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
//                                                     message:@""
//                                                    delegate:nil
//                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//
//    }
//}
//
//
//
//
//- (void )webViewDidStartLoad:(UIWebView *)webView {
//    [self.indicator startAnimating];
//    
//}
//
//



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
    
    [UIView transitionWithView:self.chartview duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.chartview.hidden =YES;
        self.tableView.hidden =NO;
    
    } completion:^(BOOL finish){
      
    }];
    
}

- (IBAction)transactionChart:(id)sender {
    
    [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
    
        self.chartview.hidden =NO;
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
        NSLog(@"%@",freq);
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
    if(scrollView!=self.collectionView && scrollView != self.tableView){
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
    
    if(!decelerate && scrollView!=self.collectionView && scrollView != self.tableView){
        
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



@end
