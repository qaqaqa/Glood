//
//  EventCoverFlowView.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonService.h"

@interface EventCoverFlowView : UIView<UITableViewDataSource, UITableViewDelegate, getMicHistoryListDelegate>

@property (retain, nonatomic) UIButton *infoButton;
@property (retain, nonatomic) UIButton *checkInButton;
@property (strong, nonatomic) UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *historyMicListArr;
//@property (retain, nonatomic) NSMutableArray *historyUserAvatarArr;
//@property (retain, nonatomic) NSMutableArray *historyContentArr;

@property (retain, nonatomic) UIView *bgViewAlpah;


@end
