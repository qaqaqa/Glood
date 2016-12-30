//
//  CheckInViewController.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckInTableViewCell.h"

@interface CheckInViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) CheckInTableViewCell *checkInTableViewCell;

@property (retain, nonatomic) NSMutableArray *mockTicketDataMutableArr;

@end
