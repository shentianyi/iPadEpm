//
//  ChooseProperty.m
//  ClearInsight
//
//  Created by wayne on 14-5-4.
//  Copyright (c) 2014年 Cao Zhuo Information&Technology Co.,Ltd. All rights reserved.
//

#import "ChooseProperty.h"

@interface ChooseProperty ()
@property (strong , nonatomic) NSArray *propertyList;
@end

@implementation ChooseProperty

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
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"cell"];
    self.propertyList=[self.property objectForKey:@"property"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.propertyList count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    NSLog(@"checked : %@",[self.property objectForKey:@"checked"]);
//    NSLog(@"property : %@",[self.property objectForKey:@"property"]);
    if(indexPath.row==0){
       cell.textLabel.text=@"All";
        NSLog(@"checked account %d",[[self.property objectForKey:@"checked"] count]);
        NSLog(@"property account %d",[[self.property objectForKey:@"property"] count]);
        if([[self.property objectForKey:@"checked"] count] == [[self.property objectForKey:@"property"] count]){
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
        }
    }
    else{
      NSMutableDictionary *item=self.propertyList[indexPath.row-1];
      cell.textLabel.text=[item objectForKey:@"value"];
      if([[item objectForKey:@"checked"] isEqualToString:@"checked"]){
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
      }
    }
    
    
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType==UITableViewCellAccessoryCheckmark){
        //取消
        cell.accessoryType=UITableViewCellAccessoryNone;
        if(indexPath.row==0){
            for(int i=0;i<self.propertyList.count;i++){
                NSIndexPath *copyIndex=[NSIndexPath indexPathForRow:i+1 inSection:indexPath.section];
                UITableViewCell *copyCell=[tableView cellForRowAtIndexPath:copyIndex];
                copyCell.accessoryType=UITableViewCellAccessoryNone;
                [self.propertyList[i] setObject:@"unchecked" forKey:@"checked"];
                [[self.property objectForKey:@"checked"] removeObjectForKey:[NSNumber numberWithInt:i]];
            }
        }
        else{
            NSMutableDictionary *item=self.propertyList[indexPath.row-1];
            [item setObject:@"unchecked" forKey:@"checked"];
            [[self.property objectForKey:@"checked"] removeObjectForKey:[NSNumber numberWithInt:indexPath.row-1]];
            //全选的勾取消
            NSIndexPath *copyIndex=[NSIndexPath indexPathForRow:0 inSection:indexPath.section];
            UITableViewCell *copyCell=[tableView cellForRowAtIndexPath:copyIndex];
            copyCell.accessoryType=UITableViewCellAccessoryNone;
        }
        
        
    }
    else{
        //选中
         cell.accessoryType=UITableViewCellAccessoryCheckmark;
        if(indexPath.row==0){
            for(int i=0;i<self.propertyList.count;i++){
                NSIndexPath *copyIndex=[NSIndexPath indexPathForRow:i+1 inSection:indexPath.section];
                UITableViewCell *copyCell=[tableView cellForRowAtIndexPath:copyIndex];
                copyCell.accessoryType=UITableViewCellAccessoryCheckmark;
                [self.propertyList[i] setObject:@"checked" forKey:@"checked"];
                [[self.property objectForKey:@"checked"] setObject:[NSNumber numberWithInt:i]
                                                            forKey:[NSNumber numberWithInt:i]];
            }
        }
        else{
            NSMutableDictionary *item=self.propertyList[indexPath.row-1];
            [item setObject:@"checked" forKey:@"checked"];
            [[self.property objectForKey:@"checked"] setObject:[NSNumber numberWithInt:indexPath.row-1]
                                                        forKey:[NSNumber numberWithInt:indexPath.row-1]];
            //全选的勾看要不要
            if([[self.property objectForKey:@"checked"] count] == [[self.property objectForKey:@"property"] count]){
                NSIndexPath *copyIndex=[NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                UITableViewCell *copyCell=[tableView cellForRowAtIndexPath:copyIndex];
                copyCell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
        }
    }
    self.chosedAmount([[self.property objectForKey:@"checked"] count]);
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
