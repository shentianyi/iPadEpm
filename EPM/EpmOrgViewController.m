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
@interface EpmOrgViewController ()
@property (weak, nonatomic) IBOutlet UILabel *selectedE1;
@property (weak, nonatomic) IBOutlet UILabel *outOfRange;
@property (weak, nonatomic) IBOutlet UILabel *average;
@property (weak, nonatomic) IBOutlet UILabel *sum;
@property (strong,nonatomic) NSMutableDictionary *currentConditions;
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

-(void)loadKpiSummery{
    self.average.text = [NSString stringWithFormat:@"%0.2f",[[self.tableData objectForKey:@"average" ]floatValue]];
    self.sum.text = [[self.tableData objectForKey:@"total"] stringValue];
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
    return @[@"Day",@"Week",@"Month",@"Quarter",@"Year"];
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
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [self loadDataForKpi:[self.kpis objectAtIndex:indexPath.row]];
  //  self.currentConditions = [NSDictionary dictionaryWithObjectsAndKeys:[[self.kpis objectAtIndex:indexPath.row] objectForKey:@"id"],@"kpi_id",@"100",@"frequency",[self.entityGroup objectForKey:@"id"],@"entity_group_id",[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-1296000]],@"start_time",[formatter stringFromDate:[NSDate date]], @"end_time",[self.entityGroup objectForKey:@"name"],@"entity_group_name",[[self.kpis objectAtIndex:indexPath.row] objectForKey:@"name" ],@"kpi_name",nil];
//
//    
//    [self BeginLoadWebWithKpi:[self.kpis objectAtIndex:indexPath.row]];
   // [self getDataForTable];
    
   // self.navigationItem.title = [self.entityGroup objectForKey:@"name"];
    
}

-(void)loadDataForKpi:(NSDictionary *)kpi{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    if(self.currentConditions){
        [self.currentConditions setObject:[kpi objectForKey:@"id"] forKey:@"kpi_id"];
    
    }
    else {
        self.currentConditions = [NSMutableDictionary dictionaryWithObjectsAndKeys:[kpi objectForKey:@"id"],@"kpi_id",@"100",@"frequency",[self.entityGroup objectForKey:@"id"],@"entity_group_id",[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-1*14*24*60*60]],@"start_time",[formatter stringFromDate:[NSDate date]], @"end_time",[self.entityGroup objectForKey:@"name"],@"entity_group_name",[kpi objectForKey:@"name" ],@"kpi_name",nil];
    
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
    
    [self performSegueWithIdentifier:@"composeMail" sender:completeData];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"composeMail"]){
        EpmSendMailController *mail = segue.destinationViewController;
        mail.completeData = (NSMutableDictionary*)sender;
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

    NSLog(@"%@",[[self.tableData objectForKey:@"date"] objectAtIndex:indexPath.row]);
    
    
    cell.time.text = [[self.tableData objectForKey:@"date"] objectAtIndex:indexPath.row];
    
    cell.value.text = [[NSString stringWithFormat:@"%0.2f",[current doubleValue]] stringByAppendingString:unit];
    
  

    if(indexPath.row > 0 ) {
          NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        float last =[[[self.tableData objectForKey:@"current"] objectAtIndex:newPath.row] floatValue];
        float trend = [current floatValue] - last ;
        if(last==0.0){
            last = 1.0;
        }
        if(trend > 0){
            cell.trend.image = [UIImage imageNamed:@"trend-up"];
            cell.range.text = [NSString stringWithFormat:@"%0.1f%%",((trend/last )*100)];
        }
        
        else if (trend == 0){
            cell.trend.image = [UIImage imageNamed:@"trend-level"];
        
        
        }
        
        else{
            cell.trend.image = [UIImage imageNamed:@"trend-down"];
            
            cell.range.text = [NSString stringWithFormat:@"%0.1f%%",((trend/last )*100)];
        }
        
    
    }
    
    
    float completion=0.0;
    if([current doubleValue] < [min doubleValue]){
        completion = [current floatValue] / ([min floatValue]+0.0000000001);
        cell.inrange.text = [NSString stringWithFormat:@"%d%% lower",(int)completion*100];
        cell.inrange.textColor = PNRed;
    }
    
    if([current doubleValue] > [max doubleValue]){
        completion = [current floatValue] / ([max floatValue]+0.0000000001);

        cell.inrange.text = [NSString stringWithFormat:@"%d%% upper",(int)completion*100];
        cell.inrange.textColor = PNRed;
    }
    
    
    else{
        cell.inrange.text = @"normal";
        cell.inrange.textColor = [UIColor whiteColor];
      
    }

    //trend
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}



#pragma scrollview delegate
-(void)didScrollViewEndToUpdateCondition:(UIScrollView*)scrollView{
    BOOL needRefresh = NO;
    
    if(scrollView == self.frequency){
        NSString *freq = [[self freqSequence] objectAtIndex: [self scrollViewCurrentPage:scrollView]];
        if([freq isEqualToString:@"Day"]){
            [self.currentConditions setObject:@"100" forKey:@"frequency"];
            needRefresh = YES;
        
        }
        if([freq isEqualToString:@"Week"]){
            [self.currentConditions setObject:@"200" forKey:@"frequency"];
            needRefresh = YES;
            
        }
        if([freq isEqualToString:@"Month"]){
            [self.currentConditions setObject:@"300" forKey:@"frequency"];
            needRefresh = YES;
            
        }
        if([freq isEqualToString:@"Quarter"]){
            [self.currentConditions setObject:@"400" forKey:@"frequency"];
            needRefresh = YES;
            
        }
        if([freq isEqualToString:@"Year"]){
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
        [timeOffset setMonth:offset ];

    }
    if(frequency==400) {
        [timeOffset setQuarter:offset ];

    }
    if(frequency==500) {
        [timeOffset setYear:offset ];
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




@end
