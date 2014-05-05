//
//  EpmPhotoEditViewController.m
//  EPM
//
//  Created by tianyi on 14-2-19.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmPhotoEditViewController.h"
#import "EpmColorPickViewController.h"


@interface EpmPhotoEditViewController ()
{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;

}
@property (strong , nonatomic) UIPopoverController *popover;



@end

@implementation EpmPhotoEditViewController
@synthesize editedPhoto = _editedPhoto;
@synthesize operation = _operation;
@synthesize mainImage = _mainImage;
@synthesize drawingImage = _drawingImage;
@synthesize backGroundImage= _backGroundImage;
@synthesize backGround = _backGround;

- (IBAction)showPickColor:(UIButton *)sender {
//    CGRect rect=[self.view convertRect:sender.frame fromView:[sender superview]];
//    EpmColorPickViewController *colorPicker=[[EpmColorPickViewController alloc] init];
//    self.popover=[[UIPopoverController alloc] initWithContentViewController:colorPicker];
//    self.popover.popoverContentSize=CGSizeMake(60, 200);
//    [self.popover presentPopoverFromRect:rect
//                                  inView:self.view
//                permittedArrowDirections:UIPopoverArrowDirectionDown
//                                animated:YES];
    
}
//-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
//{
//    self.popover=nil;
//}

- (IBAction)done:(id)sender {
    
   
    self.editedPhoto.image = [self IntegrateImage];
    //UIImageWriteToSavedPhotosAlbum(SaveImage, self,nil, nil);
    [self performSegueWithIdentifier:@"backToSendMail" sender:self];
}

- (IBAction)remobe:(id)sender {
    self.operation=OperationDelete;
    [self performSegueWithIdentifier:@"backToSendMail" sender:self];
}

- (IBAction)reset:(id)sender {
    self.operation = OperationUnchanged;
     self.mainImage.image = nil;
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
    
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    brush = 5.0;
    opacity = 0.8;
    self.operation = OperationUnchanged;
    [super viewDidLoad];
    self.editedPhoto = self.backGround;
    [self.backGroundImage setImage:self.backGround.image];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.operation = OperationChanged;
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.drawingImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.drawingImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.drawingImage setAlpha:opacity];
    UIGraphicsEndImageContext();

    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.drawingImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.drawingImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    self.mainImage.frame=CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);
    NSLog(@"width:%f ;height:%f",self.mainImage.frame.size.width,self.mainImage.frame.size.height);
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.drawingImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.drawingImage.image = nil;
    UIGraphicsEndImageContext();
}

- (IBAction)save:(id)sender {
    self.backGroundImage.layer.opacity = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.backGroundImage.layer.opacity = 1;
        
    }];
    UIImageWriteToSavedPhotosAlbum([self IntegrateImage], nil, nil, nil);

}

-(UIImage *)IntegrateImage{
    UIGraphicsBeginImageContextWithOptions(self.mainImage.bounds.size, NO,0.0);
    [self.backGroundImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
    
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.mainImage.frame.size.width, self.mainImage.frame.size.height)];
    
    UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return SaveImage;
}


- (IBAction)unwindToPhotoEdit:(UIStoryboardSegue *)unwindSegue {
    EpmColorPickViewController* source = unwindSegue.sourceViewController;
    red = source.red;
    blue = source.blue;
    green = source.green;
}






@end
