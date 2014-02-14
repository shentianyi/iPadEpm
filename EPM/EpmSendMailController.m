//
//  EpmSendMailController.m
//  EPM
//
//  Created by tianyi on 14-2-13.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmSendMailController.h"
#import "EpmMailReceiverCell.h"
#import "EpmMailAttachmentViewCell.h"
#import "PNChart.h"

@interface EpmSendMailController ()
@property (strong,nonatomic) NSMutableArray *contactList;
@property(strong,nonatomic)NSMutableArray *pictures;

@end

@implementation EpmSendMailController
@synthesize completeData = _completeData;
@synthesize tfTitle = _tfTitle;
@synthesize tfNewMail = _tfNewMail;
@synthesize collViewList = _collViewList;
@synthesize tfContent = _tfContent;
@synthesize viewAttached = _viewAttached;
@synthesize lbEntityGroupName = _lbEntityGroupName;
@synthesize lbRemark = _lbRemark;
@synthesize wvChart = _wvChart;
@synthesize contactList = _contactList;
@synthesize pictures = _pictures;
@synthesize chartView = _chartView;
@synthesize attachCollection = _attachCollection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.collViewList registerClass:[EpmMailReceiverCell class] forCellWithReuseIdentifier:@"simpleContact"];

    if (self.completeData) {
        NSLog(@"%@",self.completeData);
        NSArray *contacts =[self.completeData 	objectForKey:@"contacts"];
        
        
        if(contacts){
            //has contact
            self.contactList = [NSMutableArray arrayWithArray:contacts];
             [self.collViewList reloadData];
        }
        NSDictionary *orgCondition =[self.completeData objectForKey:@"orgCondition"];
        
        if(!orgCondition){
            //has org kpi conditions
            //self.lbEntityGroupName.text = [orgCondition objectForKey:@"entity_group_name"];
            //self.lbRemark.text = [orgCondition objectForKey:@"remark"];
            
//            NSString *queryString = [NSString stringWithFormat:@"kpi_id=%@&kpi_name=%@&frequency=%@&entity_group_id=%@&entity_group_name=%@&average=YES&start_time=%@&end_time=%@",[orgCondition objectForKey:@"kpi_id"],[orgCondition objectForKey:@"kpi_name" ],@"100",[orgCondition objectForKey:@"entity_group_id"],[orgCondition objectForKey:@"entity_group_name"],[orgCondition objectForKey:@"start_date"],[orgCondition objectForKey:@"end_date"]];
//            
//            
//            NSString *urlTxt =[EpmHttpUtil escapeUrl:[NSString stringWithFormat:@"%@%@?%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey:@"graph"],queryString]];
//            NSURL* url = [[ NSURL alloc] initWithString :urlTxt];
//       

            [self drawChartView];
        }
    
    }
  //  [self.collViewList registerClass:[EpmMailReceiverCell class] forCellWithReuseIdentifier:@"simpleContact"];


}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
  //  [self.indicator stopAnimating];
    
    int status = [EpmHttpUtil getLastHttpStatusCodeWithRequest:self.wvChart.request];
    
    [self.wvChart stringByEvaluatingJavaScriptFromString:@"orientationChange()"];
    
    if (status>=400){
        
//        NSString *msg=[EpmHttpUtil notificationWithStatusCode:status];
//        
//        UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
//                                                     message:@""
//                                                    delegate:nil
//                                           cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
        
    }
}




- (void )webViewDidStartLoad:(UIWebView *)webView {
  //  [self.indicator startAnimating];
    
}




- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    if(view==self.collViewList){
        return self.contactList.count;
    }
    else if(view == self.attachCollection) {
        return self.pictures.count;
    }
    else {
        return 0;
    
    }
    
    }

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{

    //contact
    if(cv==self.collViewList){
        NSDictionary *data = [self.contactList objectAtIndex:indexPath.row];
        EpmMailReceiverCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"simpleContactCell" forIndexPath:indexPath];
        cell.lbName.text = [data objectForKey:@"name"];
        cell.lbEmail.text = [data objectForKey:@"email"];
        return cell;
    }
    else  {
        NSLog(@"%@",self.pictures);
        EpmMailAttachmentViewCell  *cell = [cv dequeueReusableCellWithReuseIdentifier:@"mailAttachCell" forIndexPath:indexPath];
        cell.attechedImage.image = [self.pictures objectAtIndex:indexPath.row];
        return cell;
    }
    
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // [self performSegueWithIdentifier:@"sendMail" sender:self.entityGroup];
    //contact
    NSLog(@"%@",@"touched");
    
    
    
}


-(void)drawChartView{
    PNBarChart * barChart = [[PNBarChart alloc] initWithFrame:self.chartView.bounds];
    barChart.backgroundColor = [UIColor clearColor];
    //Y values
    [barChart setYValues:@[@10,@24,@12,@18,@30,@10,@100]];
    //Set Color
    [barChart setStrokeColors:@[PNGreen,PNGreen,PNRed,PNGreen,PNGreen,PNYellow,PNGreen]];
    [barChart strokeChart];
    [self.chartView addSubview:barChart];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btSend:(UIBarButtonItem *)sender {
    
}



- (IBAction)btAdd:(UIButton *)sender {
    NSString *msg = @"";
    
    if([self.tfNewMail.text length]==0){
        msg = @"Please enter an email address";
    }
    
    else{
        if (![EpmUtility validateEmail:self.tfNewMail.text]){
           msg= @"Please enter a valid email address";
        }
        
    }
    
    if([msg length]==0){
        [self.contactList insertObject:@{@"name":[[self.tfNewMail.text componentsSeparatedByString:@"@"] objectAtIndex:0],@"email":self.tfNewMail.text} atIndex:0];
        self.tfNewMail.text = @"";
        [self.collViewList reloadData];
    }
    
    else{
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                                message:msg
                                                                delegate:nil
                                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                   [av show];
        self.tfNewMail.text = @"";
    }
    
}



- (IBAction)titleTouch:(id)sender {
    self.tfTitle.textColor = [UIColor blackColor];
    
}

- (IBAction)takePicture:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;
    NSLog(@"%@",chosenImage);
    
    if(!self.pictures){
        self.pictures = [[NSMutableArray alloc]init];
    }
    [self.pictures insertObject:chosenImage atIndex:0];

    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.attachCollection reloadData];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}











@end
