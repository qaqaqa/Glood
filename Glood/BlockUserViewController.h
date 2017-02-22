//
//  BlockUserViewController.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/2/20.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlockUsersTableViewCell.h"

@interface BlockUserViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UIImageView *bgView;
@property (retain, nonatomic) UIButton *leftButton;
@property (retain, nonatomic) UILabel *titleLabel;

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) BlockUsersTableViewCell *blockUsersTableViewCell;

@end
