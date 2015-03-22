//
//  WCRecordTableViewController.h
//  WhoCall
//
//  Created by Telen on 15/3/21.
//  Copyright (c) 2015年 Wang Xiaolei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WCRecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *smsBtn;

@end

@interface WCRecordTableViewController : UITableViewController

@end