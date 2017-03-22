//
//  MockView.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MicTableViewCell.h"
#import "CommonService.h"
#import "RecordAudio.h"
#import "LGRefreshView.h"

@interface MockView : UIView<UITableViewDataSource, UITableViewDelegate, getMicHistoryListDelegate>

@property (retain, nonatomic) UIView *lastBgView;
@property (retain, nonatomic) UIView *bgView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MicTableViewCell *micTableViewCell;

@property (retain, nonatomic) UIImageView *topImageView;
@property (retain, nonatomic) UILabel *monthLabel;
@property (retain, nonatomic) UILabel *dayLabel;
@property (retain, nonatomic) UILabel *eventNameLabel;


@property (strong, nonatomic) UIButton *shieldBgButton;
@property (strong, nonatomic) UIImageView *shieldHeadImageView;
@property (strong, nonatomic) UILabel *shieldTipLabel;
@property (retain, nonatomic) UIView *shieldbgView;

@property (strong, nonatomic) NSMutableArray *historyMicListArr;
//@property (strong, nonatomic) CommonService *commonService;

@property (strong, nonatomic) LGRefreshView *refreshView;

@property (strong, nonatomic) NSString *currentRoomId;

@property (retain, nonatomic) UIImageView *micBottomImageView; //test test

//@property (strong, nonatomic) NSString *upOrDownStr; //列表向上还是向下滚动
//@property (assign, nonatomic) NSInteger lastIndexPathRow;
//@property (assign, nonatomic) NSInteger bottomCellIndexPathRow; //计算当前屏幕最底部那个cell的row
@property (strong, nonatomic) NSString *listScrollToTottom; //列表是否滚动到最底部


- (void)getMicHistoryListMock;
+ (BOOL) isBlankString:(NSString *)string;

- (void)addNSNotificationCenter;
- (void)deallocNSNotificationCenter;

+ (NSNull *)null;

@end
