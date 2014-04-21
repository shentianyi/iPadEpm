//
//  EpmGroupConditionViewController.m
//  ClearInsight
//
//  Created by tianyi on 14-4-3.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "EpmGroupConditionViewController.h"
#import "EpmSingleTextTableViewCell.h"

@interface EpmGroupConditionViewController ()
@property (strong,nonatomic) NSArray *conditions;
@end


//self.entities=[{name:string,id:integer}]
@implementation EpmGroupConditionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",self.entities)
    ;    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"groupConditionCell"];
//    [self loadData];
}

//tianyi experiment
-(void)loadData {
    self.kpiId = @"127";
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"tmpGroupDetails" ofType:@"plist"];
    
    NSDictionary *settings   = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    self.conditions = [[settings objectForKey:@"groupItem"] objectForKey:self.kpiId];
    
    NSLog(@"conditions:   %@",self.conditions);
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.conditions.count;
    return [self.entities count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    EpmSingleTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupConditionCell" forIndexPath:indexPath];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"groupConditionCell" forIndexPath:indexPath];
    // Configure the cell...
//    cell.textContent.text = [self.conditions objectAtIndex:indexPath.row];
    cell.textLabel.text=[self.entities[indexPath.row] objectForKey:@"name"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    self.selected = [self.conditions objectAtIndex:indexPath.row];
    self.selected=[self.entities objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"conditionSelected" sender:self];
    
//    self.dismiss();
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
