//
//  EpmscanController.m
//  EPM
//
//  Created by tianyi on 14-2-12.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmscanController.h"
#import "Barcode.h"
#import "AFNetworking.h"
#import "EpmContactCell.h"
#import "EpmOrgViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@import AVFoundation;

@interface EpmscanController ()
@property (strong, nonatomic) NSString * foundBarcodes;
@property(strong,nonatomic) NSMutableArray *contacts;
@property(strong,nonatomic) NSDictionary *entityGroup;
@end

@implementation EpmscanController
{
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_videoDevice;
    AVCaptureDeviceInput *_videoInput;
    AVCaptureVideoPreviewLayer *_previewLayer;
    BOOL _running;
    AVCaptureMetadataOutput *_metadataOutput;
}
@synthesize contacts=_contacts;
@synthesize foundBarcodes= _foundBarcodes;
@synthesize previewView = _previewView;
@synthesize entityGroup = _entityGroup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(CGPoint)hideSlideCenter{
    return CGPointMake(self.previewView.center.x, self.previewView.bounds.size.height + self.modalView.bounds.size.height);
}

-(CGPoint)showSlideCenter{
    return CGPointMake(self.modalView.bounds.size.width/2,self.view.bounds.size.height-self.modalView.bounds.size.height/2);
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
   self.modalView.layer.opacity = 0.0f;
    //[self.modalView setBounds:CGRectMake(0, 50.0f, self.previewView.bounds.size.width,305.0f)];

    [self setupCaptureSession];
    
    //init the slide bar
    
    
    
    
    _previewLayer.frame = _previewView.bounds;
    
    [_previewView.layer addSublayer:_previewLayer];
    // listen for going into the background and stop the session
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillEnterForeground:)
     name:UIApplicationWillEnterForegroundNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidEnterBackground:)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
	// Do any additional setup after loading the view.
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [self.previewView addGestureRecognizer:singleFingerOne];
}


- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
  {
         if (sender.numberOfTapsRequired == 1) {
               //单指单击
             [self startRunning];
          }
  
  
  }


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRunning];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRunning];
}

#pragma mark - AV capture methods

- (void)setupCaptureSession {
    // 1
    if (_captureSession) return;
    // 2
    _videoDevice = [AVCaptureDevice
                    defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!_videoDevice) {
        NSLog(@"No video camera on this device!");
        return;
    }
    // 3
    _captureSession = [[AVCaptureSession alloc] init];
    // 4
    _videoInput = [[AVCaptureDeviceInput alloc]
                   initWithDevice:_videoDevice error:nil];
    // 5
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    // 6
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]
                     initWithSession:_captureSession];
    _previewLayer.videoGravity =
    AVLayerVideoGravityResizeAspectFill;
    
    
    // capture and process the metadata
    _metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataQueue =
    dispatch_queue_create("com.1337labz.featurebuild.metadata", 0);
    [_metadataOutput setMetadataObjectsDelegate:self
                                          queue:metadataQueue];
    if ([_captureSession canAddOutput:_metadataOutput]) {
        [_captureSession addOutput:_metadataOutput];
    }
}

- (void)startRunning {
    if (_running) return;
    
    [UIView animateWithDuration:0.6 animations:^{
        self.modalView.layer.opacity = 0.0f;
    }];
    
    [_captureSession startRunning];
    _metadataOutput.metadataObjectTypes =
    _metadataOutput.availableMetadataObjectTypes;
    
 
    _running = YES;
}
- (void)stopRunning {
    if (!_running) return;
    [_captureSession stopRunning];
    _running = NO;
}

//  handle going foreground/background
- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    [self stopRunning];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    [metadataObjects
     enumerateObjectsUsingBlock:^(AVMetadataObject *obj,
                                  NSUInteger idx,
                                  BOOL *stop)
     {
         if ([obj isKindOfClass:
              [AVMetadataMachineReadableCodeObject class]])
         {
             // 3
             AVMetadataMachineReadableCodeObject *code =
             (AVMetadataMachineReadableCodeObject*)
             [_previewLayer transformedMetadataObjectForMetadataObject:obj];
             // 4
             Barcode * barcode = [Barcode processMetadataObject:code];
             [self validBarcodeFound:barcode];
         }
     }];
}




- (void) validBarcodeFound:(Barcode *)barcode{
    [self stopRunning];
    NSString *orgId = [barcode getBarcodeData];
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    NSDictionary *params = nil;
    
    NSString *toReplace = (NSString *)[EpmSettings getEpmUrlSettingsWithKey:@"orgById"];
    
    toReplace = [toReplace stringByReplacingOccurrencesOfString:@":id"
                                                     withString:orgId];
    
    [manager GET:[NSString stringWithFormat:@"%@%@",[EpmSettings getEpmUrlSettingsWithKey: @"baseUrl"],toReplace] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *result = (NSDictionary *)responseObject;
        self.entityGroup = [result objectForKey:@"entityGroup"];
        
        self.name.text = [[result objectForKey:@"entityGroup"] objectForKey:@"name"];
        
        self.desc.text =[[result objectForKey:@"entityGroup"] objectForKey:@"description"];
        
        
        if([result objectForKey:@"contact"]){
            self.contacts = [NSMutableArray arrayWithArray:[result objectForKey:@"contact"]];
            [self.contactCollection reloadData];
        }
        
        [UIView animateWithDuration:0.7 animations:^{
             self.modalView.layer.opacity = 80.0f;
        }];
      
        
    }
     
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             int status = [[operation response]statusCode];
             NSString *msg = [EpmHttpUtil notificationWithStatusCode:status];
             
             UIAlertView *av = [[UIAlertView alloc] initWithTitle:msg
                                                          message:@""
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [av show];
             
             [self startRunning];
         }];
}



- (IBAction)details:(UIButton *)sender {
    [self performSegueWithIdentifier:@"scan" sender:self.entityGroup];

}

- (IBAction)newScan:(id)sender {
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return self.contacts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary *data = [self.contacts objectAtIndex:indexPath.row];
    EpmContactCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"contactCell" forIndexPath:indexPath];
    
  
    cell.img.layer.cornerRadius = 10.0;
    cell.img.layer.masksToBounds = YES;
    
    cell.name.text = [data objectForKey:@"name"];
    cell.email.text=[data objectForKey:@"email"];
    cell.tel.text= [data objectForKey:@"tel"];
    cell.mobil.text = [data objectForKey:@"phone"];
    cell.title.text = [data objectForKey:@"title"];
    [cell.img setImageWithURL:[NSURL URLWithString:[data objectForKey:@"image_url"]]];
    //cell.img.image  = [UIImage imageWithData:[[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[data objectForKey:@"image_url"]]]];
    
    return cell;
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   // [self performSegueWithIdentifier:@"sendMail" sender:self.entityGroup];
   
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"scan"])
   {
        EpmOrgViewController *detailViewController = segue.destinationViewController;
        detailViewController.entityGroup  = (NSDictionary *)sender;
   }
    
}









@end
