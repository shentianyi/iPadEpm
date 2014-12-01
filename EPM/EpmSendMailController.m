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
#import "EpmPhotoEditViewController.h"
#import "AttachedPhoto.h"
#import "AFNetworking.h"

@interface EpmSendMailController ()
@property (strong,nonatomic) NSMutableArray *contactList;
@property(strong,nonatomic)NSMutableArray *pictures;
@property(strong,nonatomic)NSMutableDictionary *pictureIds;
@property(strong,nonatomic)NSOperationQueue *queue;

@end

@implementation EpmSendMailController

#pragma properties
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
@synthesize queue= _queue;
@synthesize mailBody = _mailBody;


#pragma init function
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.collViewList registerClass:[EpmMailReceiverCell class] forCellWithReuseIdentifier:@"simpleContact"];

    if (self.completeData) {
        
        NSArray *contacts =[self.completeData 	objectForKey:@"contacts"];
        
        if(contacts){
            //has contact
            self.contactList = [NSMutableArray arrayWithArray:contacts];
             [self.collViewList reloadData];
        }
        
        NSDictionary *orgCondition =[self.completeData objectForKey:@"orgCondition"];
        
        if(orgCondition){
            self.lbEntityGroupName.text = [orgCondition objectForKey:@"entity_group_name"];
            self.lbEntityGroupName.textColor = [UIColor blackColor];
            self.lbRemark.text = [NSString stringWithFormat:@"Kpi %@ of %@ from %@ to %@",[orgCondition objectForKey:@"kpi_name"],[orgCondition objectForKey:@"entity_group_name"],[orgCondition objectForKey:@"start_time"],[orgCondition objectForKey:@"end_time"]];
            
            NSString *orgId = [[orgCondition objectForKey:@"entity_group_id"] stringValue];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            
            NSDictionary *params = nil;
            
            NSString *toReplace = (NSString *)[EpmSettings getEpmUrlSettingsWithKey:@"orgById"];
            
            toReplace = [toReplace stringByReplacingOccurrencesOfString:@":id"
                                                             withString:orgId];
            
            [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey: @"baseUrl"],toReplace] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *result = (NSDictionary *)responseObject;
                
                if(!self.contactList){
                    self.contactList = [[NSMutableArray alloc]init];
                
                }
                
                NSLog(@"result here: %@",result);
                
                self.contactList = [NSMutableArray arrayWithArray:[result objectForKey:@"contact"]];
                 [self.collViewList reloadData];
            }
                 failure:nil];
        }
        else{
            //[self showSummery:NO WithAnimation:NO];
        }
        
        NSString *title = [self.completeData objectForKey:@"title"];
        if(title){
            self.tfTitle.text=title;
        }
        
        
      NSArray *photos = [self.completeData objectForKey:@"photos"];
        
        if (photos){
            for(AttachedPhoto *obj in photos)
                
            {
              [self insertPhoto:obj Uploaded:YES];
            }
            [self.attachCollection  reloadData];
        
        }
        
        
        
     NSDictionary *orgData = [self.completeData objectForKey:@"orgKpiData"];
        if(orgData) {
            [self drawChartViewWithData:orgData];
        }
    }
 
    //gesture to delete contact via double click
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1;
    singleFingerOne.numberOfTapsRequired = 2;
    singleFingerOne.delegate = self;
    [self.collViewList addGestureRecognizer:singleFingerOne];
    
    
    self.mailBody.layer.borderWidth = 1.0f;
    self.mailBody.layer.cornerRadius = 1.0f;
}




#pragma utilities
-(void)showSummery:(BOOL)show WithAnimation:(BOOL)animation{
    if(show){
        [self.viewAttached setFrame:CGRectMake(self.viewAttached.bounds.origin.x,self.viewAttached.bounds.origin.y, 502, 73)];

        
    }
    else{
        [self.viewAttached setFrame:CGRectMake(self.viewAttached.bounds.origin.x,self.viewAttached.bounds.origin.y, 502, 0)];
    }

}




//TODO: draw chart view
-(void)drawChartViewWithData:(NSDictionary*)data{
    PNBarChart * barChart = [[PNBarChart alloc] initWithFrame:self.chartView.bounds];
    barChart.backgroundColor = [UIColor clearColor];
    //Y values
    if(data){
        [barChart setYValues:[data objectForKey:@"current"]];
        //Set Color
        
        NSLog(@"%@",data);
        [barChart setStrokeColors:[self decideColorWithCurrent:[data objectForKey:@"current"] Max:[data objectForKey:@"target_max"] Min:[data  objectForKey:@"target_min"]]];
        [barChart strokeChart];
        [self.chartView addSubview:barChart];
    }

   }


-(NSArray *) decideColorWithCurrent:(NSArray *)current Max:(NSArray*)max Min:(NSArray*)min {
    NSMutableArray *colors = [[NSMutableArray alloc]init];
    if(current && max && min && (current.count == max.count) && (max.count==min.count)){
        for (int i = 0;i<current.count;i++){
            
            
            if([[current objectAtIndex:i] floatValue] == [[max objectAtIndex:i] floatValue]  || [[current objectAtIndex:i] floatValue] == [[min objectAtIndex:i] floatValue]){
                [colors addObject:PNTwitterColor];
            }
            else if([[current objectAtIndex:i] floatValue]>[[max objectAtIndex:i] floatValue]|| [[current objectAtIndex:i] floatValue]< [[min objectAtIndex:i] floatValue]){
                [colors addObject:PNRed];
            }
            
            else {
                [colors addObject:PNGreen];
            }
        }
    }
    
    NSLog(@"%@",colors);
    return colors;
}



-(NSMutableArray *)getContacts{
    NSMutableArray *returned = [[NSMutableArray alloc]init];
    
    
    for(NSDictionary *contact in self.contactList){
        
        [returned insertObject:[contact objectForKey:@"email"] atIndex:0];
        
        
        
    }
    return returned;
}

-(NSDictionary *)composeMailBody{
    return @{@"receivers":[[self getContacts] componentsJoinedByString:@";"],@"title":self.tfTitle.text,@"content":self.mailBody.text};
}

-(NSMutableArray *)uploadedAttachmentPath{
    NSMutableArray *uploads = [[NSMutableArray alloc]init];
    if(self.pictures){
        uploads = [[NSMutableArray alloc]init];
        for (AttachedPhoto *uploaded in self.pictures){
            if(uploaded.serverPath !=nil){
                [uploads insertObject:@{@"pathName":uploaded.serverPath,@"oriName":[NSString stringWithFormat:@"%@%@",uploaded.photo_id,@".jpeg"]} atIndex:0];
            }
        }
    }
    
    return uploads;
}




-(BOOL)attachmentAllUploaded{
    BOOL result = YES;
    
    if(self.pictures){
        for(AttachedPhoto *photo in self.pictures){
            if(photo.serverPath == nil){
                return NO;
            }
            
        }
    }
    
    return result;
    
    
}



-(void) addUploadFileJobAtIndex:(int)index {
    if([self.pictures objectAtIndex:index]){
        if(!_queue){
            self.queue = [NSOperationQueue new];
        }
        NSInvocationOperation *upload = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(uploadFileAtIndex:) object:[NSNumber numberWithInt:index]];
        [self.queue addOperation:upload];
    }
}

-(void)uploadFileAtIndex:(NSNumber*)index{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AttachedPhoto *current =[self.pictures objectAtIndex:[index integerValue]];
    
    NSDictionary *params = @{@"data":[UIImageJPEGRepresentation(current.image,0.3) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength],@"name":@"photo.jpeg"};
    
    [manager POST:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey:@"uploadPhoto"]]
       parameters:params constructingBodyWithBlock:NULL
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        
        
        if([result objectForKey:@"path_name"]){
            AttachedPhoto *current = [self.pictures objectAtIndex:[index integerValue]];
            current.serverPath =[result objectForKey:@"path_name"];
        }
        
        
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              int status = [[operation response]statusCode];
              NSString *msg = [EpmHttpUtil notificationWithStatusCode:status];
              
              UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [av show];
              
          } ];
    
}


-(void)deletePhotoAtIndex:(int) index{
    if(self.pictures && self.pictureIds) {
        AttachedPhoto *toDel = [self.pictures objectAtIndex:index];
        if (toDel){
            
            
        }
        
    }
    
    
}

-(void)insertPhoto:(AttachedPhoto*)photo Uploaded:(BOOL)upload{
    if(!self.pictures){
        self.pictures = [[NSMutableArray alloc]init];
    }
    if(!self.pictureIds){
        self.pictureIds = [[NSMutableDictionary alloc]init];
    }
    
    
    [self.pictures insertObject:photo atIndex:self.pictures.count];
    [self.pictureIds setObject:[NSNumber numberWithInteger:self.pictures.count-1] forKey:photo.photo_id];
    
    if(upload){
        [self addUploadFileJobAtIndex:(self.pictures.count-1)];
    }
}







#pragma gesture delegate
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    if (sender.numberOfTapsRequired == 2) {
        //单指单击
        CGPoint p = [sender locationInView:self.collViewList];
        
        NSIndexPath *indexPath = [self.collViewList indexPathForItemAtPoint:p];
        if (indexPath != nil){
            [self.contactList removeObjectAtIndex:indexPath.row];
            [self.collViewList reloadData];
        }
    }
}








#pragma collection view delegate

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
        AttachedPhoto *cellData= [self.pictures objectAtIndex:indexPath.row];
        NSLog(@"now pichtures%@",self.pictures);
        cell.attechedImage.image = cellData.image;
        return cell;
    }
    
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // [self performSegueWithIdentifier:@"sendMail" sender:self.entityGroup];
    //contact
    
    
    if (collectionView == self.attachCollection){
        
        [self performSegueWithIdentifier:@"editPhoto" sender:[self.pictures objectAtIndex:indexPath.row]];
        //[self.pictures removeObjectAtIndex:indexPath.row];
    }
}








#pragma action



- (IBAction)btCancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (IBAction)btSend:(UIBarButtonItem *)sender {
    NSString *msg = nil;
    
    if(self.tfNewMail.text.length>0){
        [self addContact];
    }
    
    if(!self.contactList || self.contactList.count==0){
        msg = NSLocalizedString(@"NEED_ONE_MAIL", nil);
    
    }
    if(![self attachmentAllUploaded]){
        msg = NSLocalizedString(@"ATTACHMENT_NOT_FINISHED", nil);
    }
    
    if(msg == nil){
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary: @{@"email":[self composeMailBody],@"attachments":[self uploadedAttachmentPath]}];
        
        if([self.completeData objectForKey:@"orgCondition"]){
            [params setObject:[self.completeData objectForKey:@"orgCondition"] forKey:@"analysis"];
        }
        
        [manager POST:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey:@"baseUrl"],[EpmSettings getEpmUrlSettingsWithKey:@"sendMail"]] parameters:params constructingBodyWithBlock:NULL success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            [self dismissViewControllerAnimated:YES completion:nil];
        }
         
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  int status = [[operation response]statusCode];
                  NSString *msg = [EpmHttpUtil notificationWithStatusCode:status];
                  
                  UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                               message:@""
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK" otherButtonTitles:nil];
                  [av show];
                  
              } ];
        
    }
    
    else {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"NEED_MORE_INFO", nil) message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
    }
    
    
}



- (IBAction)btAdd:(UIButton *)sender {
    [self addContact];
}

-(void)addContact{
    NSString *msg = @"";
    
    if([self.tfNewMail.text length]==0){
        msg = NSLocalizedString(@"ENTER_AN_EMAIL_ADDRESS", nil);
    }
    
    else{
        if (![EpmUtility validateEmail:self.tfNewMail.text]){
            msg= NSLocalizedString(@"ENTER_VALID_MAIL", nil);
        }
        
    }
    
    if([msg length]==0){
        if(!self.contactList){
            self.contactList = [[NSMutableArray alloc]init];
        }
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
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}







#pragma segue function
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"editPhoto"])
    {
        EpmPhotoEditViewController *detailViewController = segue.destinationViewController;
        detailViewController.backGround= (AttachedPhoto *)sender;

    }
}



- (IBAction)unwindToMail:(UIStoryboardSegue *)unwindSegue
{
    EpmPhotoEditViewController* source = unwindSegue.sourceViewController;
    if([source.operation isEqualToString:OperationChanged]){
 
        [self.pictures replaceObjectAtIndex:[[self.pictureIds objectForKey:source.editedPhoto.photo_id] integerValue] withObject:source.editedPhoto];
        [self.attachCollection reloadData];
        [self addUploadFileJobAtIndex:[[self.pictureIds objectForKey:source.editedPhoto.photo_id] integerValue]];
    }
    
    else if([source.operation isEqualToString:OperationDelete]){
        [self.pictures removeObjectAtIndex:[[self.pictureIds objectForKey:source.editedPhoto.photo_id] integerValue]];
        [self.attachCollection reloadData];
        
    }
}





#pragma UIImage delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //self.imageView.image = chosenImage;
    NSLog(@"%@",chosenImage);
    
    if(!self.pictures){
        self.pictures = [[NSMutableArray alloc]init];
    }
    
    if(!self.pictureIds) {
        self.pictureIds = [[NSMutableDictionary alloc] init];
    }
    
    
    AttachedPhoto *attached =[[AttachedPhoto alloc]initWithIdFilledAndImage:chosenImage];
    [self insertPhoto:attached Uploaded:YES];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.attachCollection reloadData];
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}



#pragma UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[textField resignFirstResponder];
    [self addContact];
    return YES;
}
@end



