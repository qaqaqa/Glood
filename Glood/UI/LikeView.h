//
//  LikeView.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/3/13.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikeTableViewCell.h"

@interface LikeView : UIView
<UITableViewDelegate, UITableViewDataSource>

@property (retain, nonatomic) UIButton *bgButton;
@property (retain, nonatomic) UIView *whiteBgView;
@property (retain, nonatomic) UIImageView *topHeartImageView;
@property (retain, nonatomic) UILabel *heartCountLabel;
@property (retain, nonatomic) UILabel *heartsFromLabel;
@property (retain, nonatomic) UITableView *tableView;

@property (retain, nonatomic) UILabel *noResultLabel;

@property (retain, nonatomic) LikeTableViewCell *likeTableViewCell;

@end
