//
//  EpmColorPickViewController.m
//  EPM
//
//  Created by tianyi on 14-2-21.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmColorPickViewController.h"

@interface EpmColorPickViewController ()

@end

@implementation EpmColorPickViewController

@synthesize red;
@synthesize blue;
@synthesize green;



- (IBAction)colorSelected:(UIButton *)sender {
    if([sender.titleLabel.text isEqualToString:@"red"]) {
        red = 220.0/255.0;
        green =20.0/255.0;
        blue=60.0/255.0;
    }
    
    if([sender.titleLabel.text isEqualToString:@"white"]) {
        red = 255.0/255.0;
        green =255.0/255.0;
        blue=255.0/255.0;
    }
    
    if([sender.titleLabel.text isEqualToString:@"black"]) {
        red = 0.0/255.0;
        green =0.0/255.0;
        blue=0.0/255.0;
    }
    
    if([sender.titleLabel.text isEqualToString:@"yellow"]) {
        red = 255.0/255.0;
        green =255.0/255.0;
        blue=0.0/255.0;
    }
    [self performSegueWithIdentifier:@"colorBack" sender:self];
    
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
