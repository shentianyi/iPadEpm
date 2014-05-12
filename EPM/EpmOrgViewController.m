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
#import "JBBarChartView.h"
#import "JBLineChartFooterView.h"
#import "JBBarChartFooterView.h"
#import "JBChartTooltipTipView.h"
#import "JBChartTooltipView.h"
#import "EpmUtility.h"
#import "OrgChartModel.h"
#import "entityTableViewController.h"

CGFloat const kJBLineChartViewControllerChartFooterHeight = 20.0f;
CGFloat const kJBLineChartViewControllerChartPadding = 10.0f;
CGFloat const kJBBarChartViewControllerChartFooterHeight = 30.0f;
CGFloat const kJBBarChartViewControllerChartFooterPadding = 5.0f;
CGFloat const kJBBarChartViewControllerChartPadding = 10.0f;


@interface EpmOrgViewController ()<JBLineChartViewDataSource,JBLineChartViewDelegate,UITableViewDataSource,UITableViewDelegate,JBBarChartViewDataSource,JBBarChartViewDelegate>
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
@property (strong, nonatomic) JBBarChartView *barChartView;
@property (weak, nonatomic) IBOutlet UILabel *minCurrent;
@property (weak, nonatomic) IBOutlet UILabel *maxCurrent;
@property (strong,nonatomic) NSString *minCurrentClient;
@property (nonatomic, strong) JBChartTooltipView *tooltipView;
@property (nonatomic, strong) JBChartTooltipTipView *tooltipTipView;
@property (nonatomic, assign) BOOL tooltipVisible;

@property (weak, nonatomic) IBOutlet UILabel *showDate;
@property (weak, nonatomic) IBOutlet UILabel *showTarget;
@property (weak, nonatomic) IBOutlet UILabel *showCurrent;
@property (strong, nonatomic) IBOutlet UIView *showView;
@property (strong,nonatomic) NSNumber *showID;
@property (strong , nonatomic) OrgChartModel *chartModel;
@property (weak, nonatomic) IBOutlet UIButton *compareButton;
@property (strong,nonatomic) NSMutableArray *entitiesID;
@property (strong,nonatomic) NSMutableArray *entitiesIDShow;
@property (strong,nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIButton *barButton;
@property (weak, nonatomic) IBOutlet UIButton *tableButton;
@property (weak, nonatomic) IBOutlet UIButton *clearCompareButton;
@property (weak, nonatomic) IBOutlet UILabel *showEntity;
@property (strong , nonatomic) NSString *chosenDate;
@property (strong , nonatomic) UIActivityIndicatorView *activeView;
- (IBAction)clearCompare:(id)sender;
- (IBAction)changeBar:(id)sender;
- (IBAction)addCompareChart:(id)sender;
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
    //init active
    self.activeView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activeView.center=self.view.center;
    [self.activeView startAnimating];
    
    self.chartModel=[OrgChartModel sharedChartDate];
//    NSLog(@"current count %d",self.chartModel.current.count);
    if(self.chartModel.current.count>1){
        int count=self.chartModel.current.count;
        for(int i=1;i<count;i++){
            [self.chartModel.current removeLastObject];
//            [self.chartModel.entity removeLastObject];
        }
    }
    [super viewDidLoad];
    [self initAppearance];
    [self loadData];
    self.clearCompareButton.hidden=YES;
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
//    NSLog(@"self.crrentConditons : %@",self.currentConditions);
    [self.view addSubview:self.activeView];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"%@%@", [EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"], [EpmSettings getEpmUrlSettingsWithKey:@"org" ]]
      parameters:self.currentConditions
         success:^(AFHTTPRequestOperation *operation, id responseObject){
             [self.activeView removeFromSuperview];
             self.entitiesID=[[NSMutableArray alloc] init];
             [self.chartModel.entity removeAllObjects];
             for(int i =0;i<[responseObject count];i++){
                 [self.entitiesID addObject:@{
                                              @"name":[responseObject[i] objectForKey:@"name"],
                                              @"id": [responseObject[i] objectForKey:@"id"],
                                              @"order":[NSNumber numberWithInt:i]
                                              }];
//                 NSLog(@"%@",[NSNumber numberWithInt:i]);
                 
//                 NSLog(@"compare tow interger %@ : %@",[responseObject[i] objectForKey:@"id"],[self.entityGroup objectForKey:@"id"]);
//                 NSLog(@"%d",[[responseObject[i] objectForKey:@"id"] intValue]);
//                 NSLog(@"%@",[responseObject[i] objectForKey:@"id"]);
                 if([[responseObject[i] objectForKey:@"id"] intValue]==[[self.entityGroup objectForKey:@"id"] intValue]){
                     [self.chartModel.entity addObject:@{
                                                           @"name":[responseObject[i] objectForKey:@"name"],
                                                           @"id":[responseObject[i] objectForKey:@"id"],
                                                           @"order":[NSNumber numberWithInt:i]
                                                           }];
                     [self.entitiesID removeLastObject];
                 }
                 self.entitiesIDShow=[self.entitiesID mutableCopy];
             }
//             NSLog(@"entityid is %@",self.chartModel.entity);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self.activeView removeFromSuperview];
         }];
    
    [self moveScrollView:self.ten ToPage:1];
    [self moveScrollView:self.bit ToPage:4];
}
-(void) initAppearance{
    [self DatePickerAppearance];
}
-(void)loadData{
    self.navigationItem.title=[self.entityGroup objectForKey:@"name"];
    self.kpiName.text=[self.preloadKpi objectForKey:@"name"];
    self.kpiName.adjustsFontSizeToFitWidth=YES;
    self.kpiDesc.text=[self.preloadKpi objectForKey:@"description"];
    self.kpiDesc.adjustsFontSizeToFitWidth=YES;
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
    [self.view addSubview:self.activeView];
    [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],toReplace] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *result = (NSArray *)responseObject;
        self.kpis = result;
         [self.activeView removeFromSuperview];
        //        [self.collectionView reloadData];
    }
     
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             int statusCode = [operation.response statusCode];
              [self.activeView removeFromSuperview];
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
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[[UIColor blackColor] colorWithAlphaComponent:1],NSForegroundColorAttributeName, nil];
    [self.seg setTitleTextAttributes:attributes forState:UIControlStateSelected];
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    // [self changeLayoutWithOrientation:(UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation];
  
    
}


-(void)getDataForTable{
    
    
    
    
    
    [self.view addSubview:self.activeView];
    

    
     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(self.chartModel.current.count==1 || !self.chartModel.current)
    {
        [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"data"]] parameters:self.currentConditions success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"address: %@",[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"data"]] );
            NSLog(@"parameters: %@",self.currentConditions);
            [self.activeView removeFromSuperview];
//            NSLog(@"result : %@",responseObject);
            
         
            NSMutableDictionary *result = [(NSDictionary *)responseObject mutableCopy];
            
//               NSLog(@"result :%@",result);
            self.chartModel.current=nil;
            [result setObject:[self.currentConditions objectForKey:@"frequency"] forKey:@"frequency"];
            [self.chartModel updateData:result];
            //        NSLog(@"result is : %@",result);
            BOOL hide=YES;
            if(self.tableView){
                hide=self.tableView.hidden;
            }
            
            self.tableData = result;
//            NSLog(@"%@",result);
            [self.tableView reloadData];
            
            [self loadKpiSummery];
            self.tableView.hidden=hide;
            
            [self loadChart];
            if(self.barChartView){
                [self loadBarChart];
            }
        }
         
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self.activeView removeFromSuperview];
                 int statusCode = [operation.response statusCode];
                 
                 NSString *msg=[EpmHttpUtil notificationWithStatusCode:statusCode];
                 
                 UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                              message:@""
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [av show];
                 
             }];
    }
    else if(self.chartModel.current.count>1){
        for(int i =0 ;i<self.chartModel.entity.count;i++){
            NSMutableDictionary *currentConditions=[self.currentConditions mutableCopy];
            //        NSLog(@"charModel last object %@",[self.chartModel.entity lastObject]);
            NSDictionary *newEntity=self.chartModel.entity[i];
            BOOL isFirst=i==0?YES:NO;
            [currentConditions setObject:[newEntity objectForKey:@"id"] forKey:@"entity_group_id"];
            [currentConditions setObject:[newEntity objectForKey:@"name"] forKey:@"entity_group_name"];
            
            
            [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"data"]] parameters:self.currentConditions success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSMutableDictionary *result = [(NSDictionary *)responseObject mutableCopy];
                [result setObject:[self.currentConditions objectForKey:@"frequency"] forKey:@"frequency"];
                [self.chartModel updateData:result];
                //        NSLog(@"result is : %@",result);
                
                if(isFirst){
                    self.tableData = result;
                    [self.tableView reloadData];
                    
                    [self loadKpiSummery];
                    self.tableView.hidden=YES;
                }
            
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
    }
   
}

/////////////////////////////////////////////////////////////////////////  load chart
-(void)loadChart{
    if(self.tableData){
        BOOL hide=NO;

        for (UIView *view in self.chartBody.subviews){
            [view removeFromSuperview];
        }
        if(self.lineChartView){
            hide=self.lineChartView.hidden;
            [self.lineChartView removeFromSuperview];
            self.lineChartView=nil;
        }

        self.lineChartView=[[JBLineChartView alloc] init];
        self.lineChartView.frame=[self.view convertRect:self.chartBody.frame fromView:self.chartview];
        [self.view addSubview:self.lineChartView];
        self.lineChartView.delegate=self;
        self.lineChartView.dataSource=self;
        [self.lineChartView reloadData];
        if(self.tooltipView){
            [self.tooltipView removeFromSuperview];
            self.tooltipView=nil;
        }
        if(self.tooltipTipView){
            [self.tooltipTipView removeFromSuperview];
            self.tooltipTipView=nil;
        }
        self.lineChartView.hidden=hide;
        
        self.minCurrent.text=[self.chartModel getCurrentMin];
        if(self.barChartView && !self.barChartView.hidden){
            self.minCurrent.text=@"0";
        }
        self.maxCurrent.text=[self.chartModel getCurrentMax];
        
        JBLineChartFooterView *footerView = [[JBLineChartFooterView alloc] initWithFrame:CGRectMake(kJBLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBLineChartViewControllerChartPadding * 2), kJBLineChartViewControllerChartFooterHeight)];
        footerView.backgroundColor = [UIColor clearColor];
        footerView.leftLabel.text = [self.chartModel.date firstObject];
        footerView.leftLabel.textColor = [UIColor whiteColor];
        footerView.rightLabel.text = [self.chartModel.date lastObject];
        footerView.rightLabel.textColor = [UIColor whiteColor];
        footerView.sectionCount = [self.chartModel.current[0] count];
        self.lineChartView.footerView = footerView;
        
    }

}

-(void)loadBarChart
{
    BOOL hide=NO;
    for (UIView *view in self.chartBody.subviews){
        [view removeFromSuperview];
    }
    if(self.barChartView){
        hide=self.barChartView.hidden;
        [self.barChartView removeFromSuperview];
        self.barChartView=nil;
    }
        
    self.barChartView=[[JBBarChartView alloc] init];
    self.barChartView.frame=[self.view convertRect:self.chartBody.frame fromView:self.chartview];
    [self.view addSubview:self.barChartView];
    self.barChartView.delegate=self;
    self.barChartView.dataSource=self;
    self.barChartView.mininumValue=0.0f;
    [self.barChartView reloadData];
    if(self.tooltipView){
        [self.tooltipView removeFromSuperview];
        self.tooltipView=nil;
    }
    if(self.tooltipTipView){
        [self.tooltipTipView removeFromSuperview];
        self.tooltipTipView=nil;
    }
    self.barChartView.hidden=hide;
    
    JBBarChartFooterView *footerView = [[JBBarChartFooterView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2), kJBBarChartViewControllerChartFooterHeight)];
    footerView.padding = kJBBarChartViewControllerChartFooterPadding;
    footerView.leftLabel.text = [self.chartModel.date firstObject];
    footerView.leftLabel.textColor = [UIColor whiteColor];
    footerView.rightLabel.text = [self.chartModel.date lastObject];
    footerView.rightLabel.textColor = [UIColor whiteColor];
    self.barChartView.footerView = footerView;

}
-(void)loadKpiSummery{
    self.average.text = [NSString stringWithFormat:@"%0.2f",[[self.tableData objectForKey:@"average" ]floatValue]];
    self.sum.text =  [NSString stringWithFormat:@"%0.2f",[[self.tableData objectForKey:@"total" ]floatValue]];

    self.selectedE1.text = [self.currentConditions objectForKey:@"kpi_name"];

    NSArray *current =[self.tableData objectForKey:@"current"];
    NSArray *min=[self.tableData objectForKey:@"target_min"];
    NSArray *max=[self.tableData objectForKey:@"target_max"];
//    int abnormal = 0;
    NSLog(@"current:%d ; max:%d ; min:%d",current.count,max.count,min.count);
//    for(int i= 0; i<current.count;i++){
//        if([[current objectAtIndex:i] floatValue] > [[max objectAtIndex:i]floatValue] || [[current objectAtIndex:i ]floatValue]<[[min objectAtIndex:i ]floatValue ]){
//            abnormal ++;
//        }
//    }
//    self.outOfRange.text = [NSString stringWithFormat:@"%d",abnormal];
}





//切换平均/合计
- (IBAction)changeAverage:(id)sender {
     NSInteger index = self.seg.selectedSegmentIndex;
//    NSLog(@"index : %d",index);
    if(index==0){
         [self.currentConditions setObject:@YES forKey:@"average"];
    }
    else{
     [self.currentConditions setObject:@NO forKey:@"average"];
    }
    if(self.tooltipView){
        [self.tooltipView removeFromSuperview];
        self.tooltipView=nil;
    }
    if(self.tooltipTipView){
        [self.tooltipTipView removeFromSuperview];
        self.tooltipTipView=nil;
    }
    [self getDataForTable];
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
        [self.hundred addSubview:[self scrollerMaker:text inRect:CGRectMake(0, last.y, self.hundred.bounds.size.width, self.hundred.bounds.size.height) fontSize:55]];
        [self.ten addSubview:[self scrollerMaker:text inRect:CGRectMake(0, last.y, self.ten.bounds.size.width, self.ten.bounds.size.height) fontSize:55]];
        last.y=last.y + self.hundred.bounds.size.height;
    }
    last.y=0;
    
    for(NSString *text in [self numberSequence:NO]){
        [self.bit addSubview:[self scrollerMaker:text inRect:CGRectMake(0, last.y, self.bit.bounds.size.width, self.bit.bounds.size.height) fontSize:55]];
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
        //////////////////////////////////////////////////////////// begin
        NSString *start_time=[formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-1*14*24*60*60]];
        NSDateFormatter *formatterBegin=[[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        [formatterBegin setLocale:enUSPOSIXLocale];
        [formatterBegin setDateFormat:@"yyyy-MM-dd"];
        NSDate *date=[formatter dateFromString:start_time];
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
        NSString *dateBegin=[dateString substringToIndex:11];
        dateBegin=[dateBegin stringByAppendingString:@"16:00:00Z"];
        ////////////////////////////////////////////////////////////  end
        NSString *end_time=[formatter stringFromDate:[NSDate date]];
        NSDateFormatter *formatterEnd=[[NSDateFormatter alloc] init];
        NSLocale *endUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        [formatterEnd setLocale:endUSPOSIXLocale];
        [formatterEnd setDateFormat:@"yyyy-MM-dd"];
        NSDate *endDate=[formatter dateFromString:end_time];
        NSMutableString *dateStringEnd=[NSMutableString stringWithFormat:@"%@",endDate.description];
        NSRange rangeEnd=NSMakeRange(10, 1);
        [dateStringEnd replaceOccurrencesOfString:@" "
                                    withString:@"T"
                                       options:NSCaseInsensitiveSearch
                                         range:rangeEnd];
        NSRange ZrangeEnd=NSMakeRange(19, 1);
        [dateStringEnd replaceOccurrencesOfString:@" "
                                    withString:@"Z"
                                       options:NSCaseInsensitiveSearch
                                         range:ZrangeEnd];
        NSString *dateStringEndSub=[dateStringEnd substringToIndex:20];
        
        self.currentConditions = [NSMutableDictionary dictionaryWithObjectsAndKeys:[kpi objectForKey:@"id"],@"kpi_id",@"100",@"frequency",[self.entityGroup objectForKey:@"id"],@"entity_group_id",dateBegin,@"start_time",dateStringEndSub, @"end_time",[self.entityGroup objectForKey:@"name"],@"entity_group_name",[kpi objectForKey:@"name"],@"kpi_name",nil];
        [self.currentConditions setObject:@YES forKey:@"average"];
    
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 加入对比
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)addCompareChart:(id)sender
{
    CGRect rect=[self.view convertRect:self.compareButton.frame fromView:self.upperContainer];
    entityTableViewController *entityTable=[[entityTableViewController alloc] init];
    entityTable.entityArray=self.entitiesIDShow;
    entityTable.dismiss=^(){
        [self.popover dismissPopoverAnimated:YES];
        
        [self.view addSubview:self.activeView];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSMutableDictionary *currentConditions=[self.currentConditions mutableCopy];
//        NSLog(@"charModel last object %@",[self.chartModel.entity lastObject]);
        NSDictionary *newEntity=[self.chartModel.entity lastObject];
        [self.activeView removeFromSuperview];
        [currentConditions setObject:[newEntity objectForKey:@"id"] forKey:@"entity_group_id"];
        [currentConditions setObject:[newEntity objectForKey:@"name"] forKey:@"entity_group_name"];
        [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey: @"data"]]
          parameters:currentConditions
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [self.activeView removeFromSuperview];
//            NSLog(@"%@",responseObject);
            [self.chartModel addCurrent:[responseObject objectForKey:@"current"]];
            [self.chartModel addUnit:[responseObject objectForKey:@"unit"]];
            [self loadChart];
                 self.barButton.enabled=NO;
                 self.tableButton.enabled=NO;
                 self.clearCompareButton.hidden=NO;
                 self.ten.scrollEnabled=NO;
                 self.bit.scrollEnabled=NO;
                 self.hundred.scrollEnabled=NO;
                 self.frequency.scrollEnabled=NO;
                 self.seg.hidden=YES;
        }
         
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [self.activeView removeFromSuperview];
                 int statusCode = [operation.response statusCode];
                 
                 NSString *msg=[EpmHttpUtil notificationWithStatusCode:statusCode];
                 
                 UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                              message:@""
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [av show];
                 
             }];
    };
    self.popover=[[UIPopoverController alloc] initWithContentViewController:entityTable];
    self.popover.delegate=self;
    self.popover.popoverContentSize=CGSizeMake(200, 250);
    [self.popover presentPopoverFromRect:rect
                                  inView:self.view
                permittedArrowDirections:UIPopoverArrowDirectionLeft
                                animated:YES];
};
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover=nil;
}
- (IBAction)clearCompare:(id)sender {
    self.entitiesIDShow=[self.entitiesID mutableCopy];
    self.barButton.enabled=YES;
    self.tableButton.enabled=YES;
    self.clearCompareButton.hidden=YES;
    [self.chartModel clearEntityAndCurrent];
     [self loadChart];
    self.showView.hidden=YES;
    self.ten.scrollEnabled=YES;
    self.bit.scrollEnabled=YES;
    self.hundred.scrollEnabled=YES;
    self.frequency.scrollEnabled=YES;
     self.seg.hidden=NO;
    
    
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// change chart type
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)transactionTable:(id)sender {
    //click table
    self.compareButton.enabled=NO;
    self.minCurrent.hidden=YES;
    self.maxCurrent.hidden=YES;
    if(!self.lineChartView.hidden){
        [UIView transitionWithView:self.lineChartView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.lineChartView.hidden =YES;
            self.barChartView.hidden =YES;
            self.tableView.hidden =NO;
        } completion:^(BOOL finish){
            
        }];
    }
    else if(self.barChartView && !self.barChartView.hidden){
        [UIView transitionWithView:self.barChartView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.lineChartView.hidden =YES;
            self.barChartView.hidden =YES;
            self.tableView.hidden =NO;
        } completion:^(BOOL finish){
            
        }];
    }
    self.showView.hidden=YES;
}

- (IBAction)transactionChart:(id)sender {
    //click line
    self.compareButton.enabled=YES;
    self.minCurrent.hidden=NO;
    self.minCurrent.text=[self.chartModel.currentMin copy];
    self.maxCurrent.hidden=NO;
    if(self.barChartView && !self.barChartView.hidden){
        [UIView transitionWithView:self.barChartView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            
            self.barChartView.hidden =YES;
            self.tableView.hidden =YES;
            self.lineChartView.hidden =NO;
        } completion:^(BOOL finish){
            
        }];
    }
    else if(!self.tableView.hidden){
        [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            
            self.barChartView.hidden =YES;
            self.tableView.hidden =YES;
            self.lineChartView.hidden =NO;
        } completion:^(BOOL finish){
            
        }];
    }
    
}


-(IBAction)changeBar:(id)sender
{
    //click bar
    self.compareButton.enabled=NO;
    self.minCurrent.hidden=NO;
    self.minCurrent.text=@"0";
    self.maxCurrent.hidden=NO;
    if(!self.lineChartView.hidden){
        [UIView transitionWithView:self.lineChartView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.lineChartView.hidden =YES;
            
            self.tableView.hidden =YES;
            self.barChartView.hidden =NO;
        } completion:^(BOOL finish){
            if(!self.barChartView){
                [self loadBarChart];
                if(self.tooltipView){
                    [self.tooltipView removeFromSuperview];
                    self.tooltipView=nil;
                }
                if(self.tooltipTipView){
                    [self.tooltipTipView removeFromSuperview];
                    self.tooltipTipView=nil;
                }
            }
        }];
    }
    else if(!self.tableView.hidden){
        [UIView transitionWithView:self.tableView duration:0.7 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            self.lineChartView.hidden =YES;
            
            self.tableView.hidden =YES;
            self.barChartView.hidden =NO;
        } completion:^(BOOL finish){
            if(!self.barChartView){
                [self loadBarChart];
                if(self.tooltipView){
                    [self.tooltipView removeFromSuperview];
                    self.tooltipView=nil;
                }
                if(self.tooltipTipView){
                    [self.tooltipTipView removeFromSuperview];
                    self.tooltipTipView=nil;
                }
            }
        }];
    }
}






-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"composeFromDetail"]){
        EpmSendMailController *mail = segue.destinationViewController;
        mail.completeData = (NSMutableDictionary*)sender;
    }
    //选择一个点以后查看详情
    else if([segue.identifier isEqualToString:@"viewGroupDetail"]){
        EpmGroupViewController *group = segue.destinationViewController;
        group.currentConditions=sender;
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



//绘制Cell

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *CellIdentifier = @"infoCell";
    
    
    EpmTableCell *cell = (EpmTableCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    NSString *date =[[self.tableData objectForKey:@"date"] objectAtIndex:indexPath.row];
    NSNumber *current =[[self.tableData objectForKey:@"current"] objectAtIndex:indexPath.row];
    NSString *unit = [[self.tableData objectForKey:@"unit"] objectAtIndex:indexPath.row];
    NSNumber *min=[[self.tableData objectForKey:@"target_min"] objectAtIndex:indexPath.row];
    NSNumber *max=[[self.tableData objectForKey:@"target_max"] objectAtIndex:indexPath.row];
    
    
    
    NSString *convert = [EpmUtility convertDatetimeWithString:[date substringToIndex:19] OfPattern:@"yyyy-MM-dd'T'HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] intValue]] ];
//    NSLog(@"%@",convert);
    cell.time.text = convert;

    cell.value.text = [[NSString stringWithFormat:@"%0.2f",[current doubleValue]] stringByAppendingString:unit];
    
    cell.range.text = [NSString stringWithFormat:@"%0.0f-%0.0f %@",[min floatValue],[max floatValue],unit];
    cell.range.adjustsFontSizeToFitWidth=YES;
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
//        cell.inrange.textColor = PNRed;
    }
    
    if([current doubleValue] > [max doubleValue]){
        completion = [current floatValue] / ([max floatValue]+0.0000000001);

        cell.inrange.text = [NSString stringWithFormat:@"%d%% %@",(int)completion*100,NSLocalizedString(@"UPPER", nil)];
//        cell.inrange.textColor = PNRed;
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
    if(self.tooltipView){
        [self.tooltipView removeFromSuperview];
        self.tooltipView=nil;
    }
    if(self.tooltipTipView){
        [self.tooltipTipView removeFromSuperview];
        self.tooltipTipView=nil;
    }   
    if(scrollView == self.frequency){
        NSString *freq = [[self freqSequence] objectAtIndex: [self scrollViewCurrentPage:scrollView]];
        //NSLog(@"%@",freq);
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
        
        
        NSString *start_time=[formatter stringFromDate:[self dateSinceNow:[number integerValue]* -1 OfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]]];
        NSDateFormatter *formatterBegin=[[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
        [formatterBegin setLocale:enUSPOSIXLocale];
        [formatterBegin setDateFormat:@"yyyy-MM-dd"];
        NSDate *date=[formatter dateFromString:start_time];
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
        NSString *subDateString=[dateString substringToIndex:11];
        subDateString=[subDateString stringByAppendingString:@"16:00:00Z"];
//        NSLog(@"utc time %@",dateString);
//        NSLog(@"start_time %@",start_time);
        
        
        
        [self.currentConditions setObject:subDateString
                                   forKey:@"start_time"];
        needRefresh = YES;
//        NSLog(@"%@",self.currentConditions);
    }
    if(needRefresh){
        [self getDataForTable];
        self.showView.hidden=YES;
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
    NSMutableDictionary *currentConditions=[self.currentConditions mutableCopy];
    [currentConditions setObject:self.showEntity.text forKey:@"entity_group_name"];
    [currentConditions setObject:self.showID forKey:@"entity_group_id"];
    [currentConditions setObject:self.chosenDate forKey:@"chosen_time"];
    [currentConditions setObject:self.showDate.text forKey:@"chosen_time_show"];
    
    [self performSegueWithIdentifier:@"viewGroupDetail" sender:currentConditions];
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
        
        NSString *convert = [EpmUtility convertDatetimeWithString:[date substringToIndex:19] OfPattern:@"yyyy-MM-dd'T'HH:mm:ss" WithFormat:[EpmUtility timeStringOfFrequency:[[self.currentConditions objectForKey:@"frequency"] integerValue]] ];
        
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
    return [self.chartModel.current count];
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [self.chartModel.date count];
}
- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    
    return [[[self.chartModel.current objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] floatValue];
}


#pragma jbbar delegate
- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return [[self.chartModel.current objectAtIndex:0] count]; // number of bars in chart
}
- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    return [[[self.chartModel.current objectAtIndex:0] objectAtIndex:index] floatValue]; // height of bar at index
}
- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    if(self.chartModel.date && self.chartModel.date.count>0){
        [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
        [self.tooltipView setText:[self.chartModel.date objectAtIndex:index]];
        [self.tooltipView setValue:[NSString stringWithFormat:@"%d%@",[[[self.chartModel.current objectAtIndex:0] objectAtIndex:index] intValue],[[self.chartModel.units objectAtIndex:0] objectAtIndex:index]]];
        self.showView.hidden=NO;
        self.showDate.text=[self.chartModel.date objectAtIndex:index];
        self.showTarget.text=[NSString stringWithFormat:@"%d%@ - %d%@",[[self.preloadKpi objectForKey:@"target_min"] intValue],[[self.chartModel.units objectAtIndex:0] objectAtIndex:index],[[self.preloadKpi objectForKey:@"target_max"] intValue],[[self.chartModel.units objectAtIndex:0] objectAtIndex:index]];
        self.showCurrent.adjustsFontSizeToFitWidth = YES;
        self.showCurrent.text=[NSString stringWithFormat:@"%d%@",[[[self.chartModel.current objectAtIndex:0] objectAtIndex:index] intValue],[[self.chartModel.units objectAtIndex:0] objectAtIndex:index]];
        self.showEntity.text=[self.entityGroup objectForKey:@"name"];
        self.showID=[self.entityGroup objectForKey:@"id"];
        
        self.chosenDate=[self.chartModel.dateStandard objectAtIndex:index];
    }
    
    
}

- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
{
    [self setTooltipVisible:NO animated:YES];
}

//event

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    if(self.chartModel.date && self.chartModel.date.count>0){
        [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
        [self.tooltipView setText:[self.chartModel.date objectAtIndex:horizontalIndex]];
        [self.tooltipView setValue:[NSString stringWithFormat:@"%d%@",[[[self.chartModel.current objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] intValue],[[self.chartModel.units objectAtIndex:lineIndex] objectAtIndex:horizontalIndex]]];
        self.showView.hidden=NO;
        self.showDate.text=[self.chartModel.date objectAtIndex:horizontalIndex];
        self.showTarget.text=[NSString stringWithFormat:@"%d%@ - %d%@",[[self.preloadKpi objectForKey:@"target_min"] intValue],[[self.chartModel.units objectAtIndex:lineIndex] objectAtIndex:horizontalIndex],[[self.preloadKpi objectForKey:@"target_max"] intValue],[[self.chartModel.units objectAtIndex:lineIndex] objectAtIndex:horizontalIndex]];
        self.showCurrent.adjustsFontSizeToFitWidth = YES;
        self.showCurrent.text=[NSString stringWithFormat:@"%d%@",[[[self.chartModel.current objectAtIndex:lineIndex] objectAtIndex:horizontalIndex] intValue],[[self.chartModel.units objectAtIndex:lineIndex] objectAtIndex:horizontalIndex]];
        
        self.showEntity.text=[self.chartModel.entity[lineIndex] objectForKey:@"name"];
        self.showID=[self.chartModel.entity[lineIndex] objectForKey:@"id"];
        
        self.chosenDate=[self.chartModel.dateStandard objectAtIndex:horizontalIndex];
    }
    
}
- (void)didUnselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    [self setTooltipVisible:NO animated:YES];
}
//custom
- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    NSArray *colorArray=[NSArray arrayWithObjects:[UIColor whiteColor],[UIColor redColor],[UIColor greenColor],[UIColor blueColor],[UIColor orangeColor],[UIColor blackColor], nil];
    UIColor *color=lineIndex+1>colorArray.count?[UIColor lightGrayColor]:colorArray[lineIndex] ;
    return [color colorWithAlphaComponent:0.7];
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView widthForLineAtLineIndex:(NSUInteger)lineIndex
{
    return 2.0f; // width of line in chart
}
- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex{
    return YES;
}
- (UIView *)barChartView:(JBBarChartView *)barChartView barViewAtIndex:(NSUInteger)index
{
    UIView *barView = [[UIView alloc] init];
    barView.backgroundColor=[UIColor whiteColor];
    return barView; // color of line in chart
}
- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [[UIColor redColor] colorWithAlphaComponent:0.5]; // color of selection view
}
- (UIColor *)verticalSelectionColorForLineChartView:(JBLineChartView *)lineChartView
{
    return [[UIColor redColor] colorWithAlphaComponent:0.3]; // color of selection view
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView selectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [[UIColor whiteColor] colorWithAlphaComponent:1]; // color of selected line
}


- (JBLineChartViewLineStyle)lineChartView:(JBLineChartView *)lineChartView lineStyleForLineAtLineIndex:(NSUInteger)lineIndex
{
    if(lineIndex % 2 == 0){
       return JBLineChartViewLineStyleSolid;
    }
    else{
       return JBLineChartViewLineStyleDashed;
    }
     // style of line in chart
}

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
