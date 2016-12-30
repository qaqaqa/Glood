//
//  CeHuaView.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/10.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CeHuaTableViewCell.h"

@interface CeHuaView : UIView<UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) UIImageView *bgView;

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) CeHuaTableViewCell *ceHuaTabelViewCell;

@end
