//
//  EventListView.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/8.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventListTableViewCell.h"

@class EventListView;
@protocol eventListViewDelegate <NSObject>

- (void)eventListJoinRoom:(NSInteger)roomId;

@end

@interface EventListView : UIView<UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) UIImageView *bgView;
@property (retain, nonatomic) UIButton *leftButton;
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIButton *rightButton;
@property (retain, nonatomic) UIButton *largeRightButton;

@property (retain, nonatomic) UITableView *tableView;
@property (retain, nonatomic) EventListTableViewCell *eventListTabelViewCell;

@property (retain, nonatomic) id<eventListViewDelegate> delegate;

@end
