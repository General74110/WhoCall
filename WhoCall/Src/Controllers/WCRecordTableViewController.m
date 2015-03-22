//
//  WCRecordTableViewController.m
//  WhoCall
//
//  Created by Telen on 15/3/21.
//  Copyright (c) 2015年 Wang Xiaolei. All rights reserved.
//

#import "WCRecordTableViewController.h"
#import "WCCallInspector.h"
#import "WCLiarPhoneList.h"
#import "WCPhoneLocator.h"
#import "UIColor+Hex.h"

@interface WCRecordTableViewController ()

@end

@implementation WCRecordTableViewCell
@end

@implementation WCRecordTableViewController
{
    NSMutableArray* arr_records;
    NSMutableArray* arr_records_reverse;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [[WCCallInspector sharedInspector] addRecord:@"01053202011" sign:@"" color:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
//    [[WCCallInspector sharedInspector] addRecord:@"15121238686" sign:@"" color:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    
    NSArray* arr = [[WCCallInspector sharedInspector] records];
    arr_records = [NSMutableArray arrayWithArray:arr];
    arr = [[arr reverseObjectEnumerator] allObjects];
    arr_records_reverse = [NSMutableArray arrayWithArray:arr];
    //
    [self.tableView reloadData];
    [self performSelector:@selector(checkNet) withObject:nil];
}

- (void)checkNet
{
    NSString* number = nil;
    int num = 0;
    for (int i =0; i<arr_records_reverse.count; i++) {
        NSDictionary* dict = [arr_records_reverse objectAtIndex:i];
        NSString* sign =[dict objectForKey:@"sign"];
        if (!sign || sign.length <1) {
            number = [dict objectForKey:@"number"];
            num = i;
            break;
        }
    }
    // 欺诈电话联网查，等待查询结束才能知道要不要提示地点
    if(number)[[WCLiarPhoneList sharedList]
     checkLiarNumber:number
     withCompletion:^(WCLiarPhoneType liarType, NSString *liarDetail) {
         //
         NSString *location = [[WCPhoneLocator sharedLocator] locationForPhoneNumber:number];
         if (!location) {
             location = @"";
         }else{
             location = [NSString stringWithFormat:@"%@  ",location];
         }
         if (kWCLiarPhoneNone == liarType) {
             [self updateArr_records_reverse:num sign:[NSString stringWithFormat:@"%@%@",location,@"O(∩_∩)O~"] color:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
         }else{
             [self updateArr_records_reverse:num sign:[NSString stringWithFormat:@"%@%@",location,liarDetail] color:[UIColor redColor]];
         }
         [self.tableView reloadData];
         [self performSelector:@selector(checkNet) withObject:nil];
     }];
}

- (void)updateArr_records_reverse:(int)index sign:(NSString*)sign color:(UIColor*)clr
{
    if (!sign || sign.length < 1) {
        return;
    }
    NSDictionary* dict = [arr_records_reverse objectAtIndex:index];
    if (dict) {
        NSMutableDictionary* mdict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [mdict setObject:sign forKey:@"sign"];
        [mdict setObject:[UIColor changeUIColorToRGB:clr] forKey:@"color"];
        [arr_records_reverse replaceObjectAtIndex:index withObject:mdict];
        [arr_records replaceObjectAtIndex:arr_records.count-1-index withObject:mdict];
        [arr_records writeToFile:[[WCCallInspector sharedInspector] recordsPath] atomically:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return arr_records.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WCRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WCRecord"];
    
    NSDictionary* dict = [arr_records_reverse objectAtIndex:indexPath.row];
    NSDate* date = [dict objectForKey:@"date"];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.phoneLabel.text = [dict objectForKey:@"number"];
    cell.phoneInfoLabel.text = [dict objectForKey:@"sign"];
    cell.dateLabel.text = [format stringFromDate:date];
    cell.smsBtn.tag = indexPath.row;
    
    NSString* clr = [dict objectForKey:@"color"];
    UIColor* color = [UIColor colorWithHexString:clr];
    if (color) {
        cell.phoneLabel.textColor = color;
    }else{
        cell.phoneLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    
    return cell;
}
- (IBAction)onBtnMsg:(id)sender {
    NSInteger tag = ((UIButton*)sender).tag;
    NSDictionary* dict = [arr_records_reverse objectAtIndex:tag];
    NSString* url = [NSString stringWithFormat:@"sms://%@",[dict objectForKey:@"number"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dict = [arr_records_reverse objectAtIndex:indexPath.row];
    NSString* url = [NSString stringWithFormat:@"tel://%@",[dict objectForKey:@"number"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
