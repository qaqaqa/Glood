//
//  EventCoverFlowView.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "MockView.h"
#import "Define.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "EventViewController.h"
#import "UserInfomationData.h"
#import "MMProgressHUD.h"
#import "ShowMessage.h"
#import "Mic.h"
#import "AppDelegate.h"

@interface MockView ()
@property (retain, nonatomic) EventViewController *eventViewVC;
@property (assign, nonatomic) NSInteger upHeadButtonTag;
@property (strong, nonatomic) AppDelegate *myAppDelegate;

@end

@implementation MockView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.myAppDelegate = [UIApplication sharedApplication].delegate;
        self.upHeadButtonTag = 0;
//        self.eventViewVC = [[EventViewController alloc] init];
        //拉取该房间的消息
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        NSString *roomId;
        if ([userInfomationData.pushEventVCTypeStr isEqualToString:@"QR"]) {
            roomId = userInfomationData.QRRoomId;
        }
        else
        {
            roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
            
        }
        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:@"拉取历史消息" status:NSLocalizedString(@"Please wating", nil)];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [userInfomationData.commonService getMessageInRoom:@"" roomId:roomId];
        });
        
        
        
        self.lastBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.lastBgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.lastBgView];
        
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*260/320))/2, (SCREEN_HEIGHT-(SCREEN_HEIGHT*450/568))/2+SCREEN_HEIGHT*10/568, SCREEN_WIDTH*260/320, SCREEN_HEIGHT*450/568)];
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.bgView.layer.cornerRadius = 5;
        self.bgView.layer.masksToBounds = YES;
        [self.lastBgView addSubview:self.bgView];
        
        UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, self.bgView.frame.size.width-2, SCREEN_HEIGHT*100/568)];
        topBgView.backgroundColor = [UIColor whiteColor];
        topBgView.layer.cornerRadius = 5;
        topBgView.layer.masksToBounds = YES;
        [self.bgView addSubview:topBgView];
        
        self.topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bgView.frame.size.width-2, SCREEN_HEIGHT*90/568)];
        //        [self.topImageView sd_setImageWithURL:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_url"] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
        [topBgView addSubview:self.topImageView];
        
        self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*15/320, self.topImageView.frame.size.height+self.topImageView.frame.origin.y+SCREEN_WIDTH*10/320, SCREEN_WIDTH*40/320, SCREEN_HEIGHT*25/568)];
        self.monthLabel.textAlignment = NSTextAlignmentLeft;
        //        monthLabel.text = [NSString stringWithFormat:@"%@",monthStr];
        self.monthLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.bgView addSubview:self.monthLabel];
        
        self.dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.monthLabel.frame.origin.x, self.monthLabel.frame.size.height+self.monthLabel.frame.origin.y, SCREEN_WIDTH*40/320, SCREEN_HEIGHT*25/568)];
        self.dayLabel.textAlignment = NSTextAlignmentLeft;
        //        dayLabel.text = [NSString stringWithFormat:@"%@",dayStr];
        self.dayLabel.font = [UIFont boldSystemFontOfSize:25];
        [self.bgView addSubview:self.dayLabel];
        
        self.eventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.monthLabel.frame.origin.x+self.monthLabel.frame.size.width-5, self.monthLabel.frame.origin.y, SCREEN_WIDTH*220/320, SCREEN_HEIGHT*25/568)];
        self.eventNameLabel.textAlignment = NSTextAlignmentLeft;
        self.eventNameLabel.text = [NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"name"]];
        self.eventNameLabel.font = [UIFont boldSystemFontOfSize:15];
        [self.bgView addSubview:self.eventNameLabel];
        
        UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.monthLabel.frame.origin.x+2, self.dayLabel.frame.origin.y+self.dayLabel.frame.size.height+5, SCREEN_WIDTH*83/320, SCREEN_WIDTH*24/SCREEN_WIDTH)];
        infoButton.backgroundColor = [UIColor whiteColor];
        [infoButton setTitle:@"info" forState:UIControlStateNormal];
        [infoButton setTitleColor:[UIColor colorWithRed:0/255.0 green:130/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        infoButton.titleLabel.font = [UIFont systemFontOfSize:16];
        infoButton.layer.cornerRadius =(SCREEN_WIDTH*24/SCREEN_WIDTH)/2;
        infoButton.layer.masksToBounds = YES;
        infoButton.layer.borderWidth = 1;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0/255.0, 130/255.0, 255/255.0, 1 });
        [infoButton.layer setBorderColor:colorref];
        infoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [infoButton addTarget:self action:@selector(onInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:infoButton];
        
        UIButton *checkInButton = [[UIButton alloc] initWithFrame:CGRectMake(infoButton.frame.origin.x+infoButton.frame.size.width+15, self.dayLabel.frame.origin.y+self.dayLabel.frame.size.height+5, SCREEN_WIDTH*125/320, SCREEN_WIDTH*24/SCREEN_WIDTH)];
        checkInButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:130/255.0 blue:255/255.0 alpha:1.0];
        [checkInButton setTitle:@"check-in" forState:UIControlStateNormal];
        [checkInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        checkInButton.titleLabel.font = [UIFont systemFontOfSize:16];
        checkInButton.layer.cornerRadius =(SCREEN_WIDTH*24/SCREEN_WIDTH)/2;
        checkInButton.layer.masksToBounds = YES;
        checkInButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [checkInButton addTarget:self action:@selector(onCheckInClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:checkInButton];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*260/320))/2,SCREEN_HEIGHT*275/568,SCREEN_WIDTH*260/320,SCREEN_HEIGHT*220/568)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.alwaysBounceVertical = YES;
        self.tableView.allowsSelection = NO;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        self.tableView.separatorInset = UIEdgeInsetsMake(15, 0, 15, 0);
        [self addSubview:self.tableView];
        
        __weak typeof(self) wself = self;
        
        self.refreshView = [LGRefreshView refreshViewWithScrollView:self.tableView
                                                 refreshHandler:^(LGRefreshView *refreshView)
                        {
                            if (wself)
                            {
                                __strong typeof(wself) self = wself;
                                
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
                                               {
                                                   [self.refreshView endRefreshing];
                                               });
                            }
                        }];
        self.refreshView.tintColor = [UIColor colorWithRed:0.f green:0.5 blue:1.f alpha:1.f];
        self.refreshView.backgroundColor = [UIColor clearColor];
        
        self.shieldBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.shieldBgView.backgroundColor =[UIColor clearColor];
        self.shieldBgView.alpha = 0;
        [self addSubview:self.shieldBgView];
        
        UIView *shieldbgView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*240/320))/2, (SCREEN_HEIGHT-(SCREEN_HEIGHT*183/568))/2, SCREEN_WIDTH*240/320, SCREEN_HEIGHT*183/568)];
        shieldbgView.backgroundColor = [UIColor whiteColor];
        shieldbgView.layer.cornerRadius = 5;
        shieldbgView.layer.masksToBounds = YES;
        [self.shieldBgView addSubview:shieldbgView];
        
        self.shieldHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*70/320))/2, (SCREEN_HEIGHT-(SCREEN_HEIGHT*235/568))/2, SCREEN_WIDTH*70/320, SCREEN_WIDTH*70/320)];
        self.shieldHeadImageView.layer.cornerRadius = self.shieldHeadImageView.frame.size.width/2;
        self.shieldHeadImageView.layer.masksToBounds = YES;
        [self.shieldBgView addSubview:self.shieldHeadImageView];
        
        self.shieldTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*25/320, SCREEN_HEIGHT*50/568, SCREEN_WIDTH*190/320, SCREEN_HEIGHT*60/568)];
        self.shieldTipLabel.font = [UIFont systemFontOfSize:18];
        self.shieldTipLabel.numberOfLines = 2;
        self.shieldTipLabel.textAlignment = NSTextAlignmentCenter;
        [shieldbgView addSubview:self.shieldTipLabel];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, shieldbgView.frame.size.height-(SCREEN_HEIGHT*45/568), SCREEN_WIDTH*119.5/320, SCREEN_HEIGHT*45/568)];
        cancelButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:143/255.0 blue:255/255.0 alpha:1];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton setTitle:@"No" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(onCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [shieldbgView addSubview:cancelButton];
        
        UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(cancelButton.frame.origin.x+cancelButton.frame.size.width+1, cancelButton.frame.origin.y, SCREEN_WIDTH*119.5/320, SCREEN_HEIGHT*45/568)];
        okButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:143/255.0 blue:255/255.0 alpha:1];
        [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okButton setTitle:@"Yes" forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(onYesBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [shieldbgView addSubview:okButton];
        
        
        userInfomationData.refushStr = @"no";
    }
    return self;
}

- (void)addNSNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(getMicHistoryListMock)name:@"getMicHistoryListMock"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(beginRefreshingxx)name:@"beginRefreshingxx"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(endRefreshingxx)name:@"endRefreshingxx"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(sendMessageScu)name:@"sendMessageScu"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(recordOrExchangeChatRoomStopAnimation)name:@"recordOrExchangeChatRoomStopAnimation"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(startRecordAudio)name:@"startRecordAudio"object:nil];
}

- (void)deallocNSNotificationCenter
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getMicHistoryListMock" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"beginRefreshingxx" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"endRefreshingxx" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendMessageScu" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"recordOrExchangeChatRoomStopAnimation" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startRecordAudio" object:nil];
}

- (void)beginRefreshingxx
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    
    NSLog(@"begin Refreshing");
    [ShowMessage showMessage:@"begin"];
    userInfomationData.refushStr = @"yes";
    NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    Mic *mic = self.historyMicListArr[[self.historyMicListArr count]-1];
    NSLog(@"-*-*-*-*xxxxxdfsd---------- %@------ %hhu",mic.fromUserName,[self.myAppDelegate selectCoreDataroomId:roomId refreshMessageId:mic.messageId]);
    if ([self.myAppDelegate selectCoreDataroomId:roomId refreshMessageId:mic.messageId]) {
        //从本地数据库加载
        userInfomationData.micMockListPageIndex ++;
        [self getMicHistoryListMock];
    }
    else{
        
        //从服务器拉取
        userInfomationData.micMockListPageIndex ++;
        [userInfomationData.commonService getMessageInRoom:mic.messageId roomId:roomId];
    }
    
}

- (void)endRefreshingxx
{
    NSLog(@"end refreshing");
    [ShowMessage showMessage:@"end"];
}

- (BOOL)shouldAutorotate
{
    return !self.refreshView.isRefreshing;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"xixixixixxixix======  %ld",(unsigned long)[self.historyMicListArr count]);
    return [self.historyMicListArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT*55/568;
}

#define headImageButtonTag 10001
#define nameLabelTag 20001
#define circleOneImageViewTag 30001
#define circleTwoImageViewTag 40001
#define bgImageViewTag 50001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.micTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MicTableViewCell"];
//    if (self.micTableViewCell == nil)
//    {
        self.micTableViewCell = [[MicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MicTableViewCell" index:indexPath.row];
        [self.micTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    }
    //语音时间计算
    Mic *mic = self.historyMicListArr[[self.historyMicListArr count] - indexPath.row-1];
    __block float timeF = [mic.time floatValue];

    if (timeF <= 4 && timeF > 0) {
        timeF = 2.0;
    }
    if (timeF>4 && timeF < 20) {
        timeF = 2+timeF/5;
    }
    if (timeF>=20) {
        timeF = 6.5;
    }
    self.micTableViewCell.bgImageView.layer.cornerRadius = (SCREEN_WIDTH*35/320)/2;
    self.micTableViewCell.bgImageView.layer.masksToBounds = YES;
    self.micTableViewCell.bgImageView.tag = bgImageViewTag+indexPath.row;
    [self.micTableViewCell.bgImageView setImage:[UIImage imageNamed:@"background.png"]];
    
    self.micTableViewCell.headImageButton.frame = CGRectMake((SCREEN_WIDTH*260/320-(SCREEN_WIDTH*35/320))/2, 0, SCREEN_WIDTH*35/320, SCREEN_WIDTH*35/320);
    self.micTableViewCell.headImageButton.tag = headImageButtonTag+indexPath.row;
    self.micTableViewCell.headImageButton.layer.cornerRadius = (SCREEN_WIDTH*35/320)/2;
    self.micTableViewCell.headImageButton.layer.masksToBounds = YES;
    //    [self.micTableViewCell.headImageButton setImage:[UIImage imageNamed:@"171604419.jpg"] forState:UIControlStateNormal];
    [self.micTableViewCell.headImageButton addTarget:self action:@selector(onHeadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.micTableViewCell.nameLabel.frame = CGRectMake(0, SCREEN_WIDTH*35/320-5, SCREEN_WIDTH*260/320, 35);
    self.micTableViewCell.nameLabel.tag = nameLabelTag+indexPath.row;
    self.micTableViewCell.nameLabel.alpha = 1;
    //    self.micTableViewCell.nameLabel.text = @"Li Lei";
    
    self.micTableViewCell.circleOneImageView.frame = self.micTableViewCell.headImageButton.frame;
    self.micTableViewCell.circleOneImageView.tag = circleOneImageViewTag+indexPath.row;
    self.micTableViewCell.circleOneImageView.layer.cornerRadius = (SCREEN_WIDTH*35/320)/2;
    self.micTableViewCell.circleOneImageView.layer.masksToBounds = YES;
    
    self.micTableViewCell.circleTwoImageView.frame = self.micTableViewCell.headImageButton.frame;
    self.micTableViewCell.circleTwoImageView.tag = circleTwoImageViewTag+indexPath.row;
    self.micTableViewCell.circleTwoImageView.layer.cornerRadius = (SCREEN_WIDTH*35/320)/2;
    self.micTableViewCell.circleTwoImageView.layer.masksToBounds = YES;
    
    
    self.micTableViewCell.bgImageView.frame = CGRectMake((SCREEN_WIDTH*260/320-(SCREEN_WIDTH*30/320*timeF))/2, 0, SCREEN_WIDTH*30/320*timeF, SCREEN_WIDTH*35/320);
    [self.micTableViewCell.headImageButton sd_setImageWithURL:mic.avatarImage forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"171604419.jpg"]];
    self.micTableViewCell.nameLabel.text = mic.fromUserName;
    
    return self.micTableViewCell;
}

- (void)onCancelBtnClick:(id)sender
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.shieldUserId = @"";
    userInfomationData.shieldRoomId = @"";
    NSLog(@"No");
    [self hiddenShieldView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelShield" object:self];
}

- (void)onYesBtnClick:(id)sender
{
    //保存屏蔽人的信息userid，roomid
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSMutableArray *mutableArr = [[NSMutableArray alloc] initWithCapacity:10];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] != nil) {
        for (NSInteger i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] count]; i ++) {
            [mutableArr addObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] objectAtIndex:i]];
        }
        
    }
    [mutableArr insertObject:@{
                               @"user_id":userInfomationData.shieldUserId,
                               @"room_id":userInfomationData.shieldRoomId,
                               } atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:mutableArr forKey:@"Shield"];
    [self getMicHistoryListMock];
    NSLog(@"Yes");
    [self hiddenShieldView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"yesShield" object:self];
}

- (void)hiddenShieldView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.shieldBgView.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)recordOrExchangeChatRoomStopAnimation
{
    if (self.upHeadButtonTag != 0) {
//        UIImageView *find_bgImageView1 = (UIImageView *)[self viewWithTag:self.upHeadButtonTag-headImageButtonTag+bgImageViewTag];
//        UIImageView *find_circleOneImageView1 = (UIImageView *)[self viewWithTag:self.upHeadButtonTag-headImageButtonTag+circleOneImageViewTag];
//        UIImageView *find_circleTwoImageView1 = (UIImageView *)[self viewWithTag:self.upHeadButtonTag-headImageButtonTag+circleTwoImageViewTag];
//        UIButton *find_headImageButtonView1 = (UIButton *)[self viewWithTag:self.upHeadButtonTag-headImageButtonTag+headImageButtonTag];
//        dispatch_time_t popTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC));
//        dispatch_after(popTime1, dispatch_get_main_queue(), ^(void){
//            [UIView animateWithDuration:0.0 animations:^{
//                find_headImageButtonView1.transform = CGAffineTransformIdentity;
//            } completion:^(BOOL finished) {
//            }];
//            [UIView animateWithDuration:0.0 animations:^{
//                [find_bgImageView1 setImage:[UIImage imageNamed:@"background.png"]];
//                find_circleTwoImageView1.alpha=0.5;
//                find_circleTwoImageView1.transform = CGAffineTransformIdentity;
//                find_circleOneImageView1.alpha=0.5;
//                find_circleOneImageView1.transform = CGAffineTransformIdentity;
//            } completion:^(BOOL finished) {
//                self.upHeadButtonTag = 0;
//                
//            }];
//        });
        
        NSLog(@"sdfsd*--*-*-*------  %ld",(long)self.upHeadButtonTag);
        UIImageView *find_bgImageView1 = (UIImageView *)[self viewWithTag:self.upHeadButtonTag-headImageButtonTag+bgImageViewTag];
        UIImageView *find_circleOneImageView1 = (UIImageView *)[self viewWithTag:self.upHeadButtonTag-headImageButtonTag+circleOneImageViewTag];
        UIImageView *find_circleTwoImageView1 = (UIImageView *)[self viewWithTag:self.upHeadButtonTag-headImageButtonTag+circleTwoImageViewTag];
        UIButton *find_headImageButtonView1 = (UIButton *)[self viewWithTag:self.upHeadButtonTag-headImageButtonTag+headImageButtonTag];
        [find_bgImageView1 setImage:[UIImage imageNamed:@"background.png"]];
        find_circleTwoImageView1.transform = CGAffineTransformIdentity;
        find_circleOneImageView1.transform = CGAffineTransformIdentity;
        find_headImageButtonView1.transform = CGAffineTransformIdentity;
        self.upHeadButtonTag = 0;
    }

    
}

//录音开始，预加载一条语音
- (void)startRecordAudio
{
    NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    [self.myAppDelegate insertCoreData:[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID] avatarImage:[[NSUserDefaults standardUserDefaults] objectForKey:USER_AVATAR_URL] roomId:roomId time:@0 message:@"100" messageId:@"99999999999999999" fromUserName:[[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME]];
    NSLog(@"xxxxcx---mockview-%@===%@",roomId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];

//    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
//    NSLog(@"sdfsdf*/*/***------ %lu",[self.historyMicListArr count]-1);
//    if ((20*userInfomationData.micMockListPageIndex) <= [self.historyMicListArr count] && [self.historyMicListArr count] > 4) {
//    NSArray *result = [[NSArray alloc] initWithArray:[self.myAppDelegate selectCoreDataroomIdxx:roomId]];
//    for (NSInteger i = 0; i < [result count]; i++) {
//        [self.historyMicListArr addObject:[result objectAtIndex:i]];
//        Mic *mic = result[i];
//        NSLog(@"-*-*-*-*-------- %ld----%@",i,mic.messageId);
//    }
//        NSInteger i = [self.historyMicListArr count];
//        NSIndexPath *lastPath = [NSIndexPath indexPathForRow: i-1 inSection: 0 ];
//        [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//    }
}

- (void)onHeadBtnClick:(id)sender
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    UIButton *button = (UIButton *)sender;
    float time;
    Mic *mic = self.historyMicListArr[[self.historyMicListArr count] -1- (button.tag-headImageButtonTag)];
    time = [mic.time floatValue];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isSelectShield"] integerValue] == 0) {
        
        //在播放之前，暂停所有的播放
        [self recordOrExchangeChatRoomStopAnimation];
        [userInfomationData.recordAudio saveRecord:mic.message messageId:mic.messageId];
        [userInfomationData.recordAudio palyRecord:mic.messageId];
        NSLog(@"点击头像播放------%ld----- %@--- %@",(long)button.tag,mic.messageId,mic.fromUserName);
        self.upHeadButtonTag = button.tag;
        UIImageView *find_bgImageView = (UIImageView *)[self viewWithTag:button.tag-headImageButtonTag+bgImageViewTag];
        UIImageView *find_circleOneImageView = (UIImageView *)[self viewWithTag:button.tag-headImageButtonTag+circleOneImageViewTag];
        UIImageView *find_circleTwoImageView = (UIImageView *)[self viewWithTag:button.tag-headImageButtonTag+circleTwoImageViewTag];
        UIButton *find_headImageButtonView = (UIButton *)[self viewWithTag:button.tag-headImageButtonTag+headImageButtonTag];
        [find_bgImageView setImage:[UIImage imageNamed:@"background2.png"]];
        [UIView animateWithDuration:0.5 animations:^{
            find_headImageButtonView.transform = CGAffineTransformMakeScale(1.1,1.1);
        } completion:^(BOOL finished) {
        }];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.0f];
        UIView.animationRepeatCount =HUGE_VALF;
        find_circleOneImageView.alpha=0.1;
        find_circleOneImageView.transform = CGAffineTransformMakeScale(1.8,1.8);
        [UIView commitAnimations];
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.0f];
            UIView.animationRepeatCount =HUGE_VALF;
            find_circleTwoImageView.alpha=0.1;
            find_circleTwoImageView.transform = CGAffineTransformMakeScale(1.8,1.8);
            [UIView commitAnimations];
        });
        
        //播放完毕
        
        dispatch_time_t popTime1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
        dispatch_after(popTime1, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.5 animations:^{
                find_headImageButtonView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
            }];
            [UIView animateWithDuration:0.0 animations:^{
                [find_bgImageView setImage:[UIImage imageNamed:@"background.png"]];
                find_circleTwoImageView.alpha=0.5;
                find_circleTwoImageView.transform = CGAffineTransformIdentity;
                find_circleOneImageView.alpha=0.5;
                find_circleOneImageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        });
        
    }
    else{
        NSLog(@"点击头像屏蔽------%ld",(long)button.tag);
        
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID] isEqualToString:mic.userId]) {
            //判断屏蔽的是不是当前用户
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shield" object:self];
            UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
            userInfomationData.shieldUserId = mic.userId;
            userInfomationData.shieldRoomId = mic.roomId;
            [UIView animateWithDuration:0.5 animations:^{
                self.shieldBgView.alpha = 1.0;
                [self.shieldHeadImageView sd_setImageWithURL:mic.avatarImage placeholderImage:[UIImage imageNamed:@"171604419.jpg"]];
                self.shieldTipLabel.text = [NSString stringWithFormat:@"Are you sure you want to block %@.?",mic.fromUserName];
            } completion:^(BOOL finished) {
            }];
        }
        
    }
    
}

- (void)onInfoClick:(id)sender
{
    NSLog(@"info");
}

- (void)onCheckInClick:(id)sender
{
    NSLog(@"check-in");
}

- (void)getMicHistoryListMock
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    self.historyMicListArr = [[NSMutableArray alloc] init];
    //  查询数据
    if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
        self.currentRoomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    }
    else
    {
        self.currentRoomId = userInfomationData.QRRoomId;
    }
    NSArray *result = [[NSArray alloc] initWithArray:[self.myAppDelegate selectCoreDataroomId:self.currentRoomId]];
    for (NSInteger i = 0; i < [result count]; i++) {
        [self.historyMicListArr addObject:[result objectAtIndex:i]];
    }
    
    
    //在这个房间中被屏蔽的人的ID
    NSMutableArray *shieldMutableArr = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSInteger x = 0; x < [(NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] count]; x++) {
        if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] objectAtIndex:x] objectForKey:@"room_id"] isEqualToString:self.currentRoomId]) {
            [shieldMutableArr addObject:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] objectAtIndex:x] objectForKey:@"user_id"]];
        }
    }
    
    //根被屏蔽人的id，清除数据中包含该用户id的那一条数据
    NSMutableIndexSet *indexSets = [[NSMutableIndexSet alloc] init];
    for (NSInteger i = 0; i < [self.historyMicListArr count]; i++) {
        for (NSInteger x = 0; x < [shieldMutableArr count]; x ++) {
            Mic *mic = self.historyMicListArr[i];
            if ([[shieldMutableArr objectAtIndex:x] isEqualToString:mic.userId]) {
                [indexSets addIndex:i];
            }
        }
    }
    [self.historyMicListArr removeObjectsAtIndexes:indexSets];
    if ([self.historyMicListArr count] == 0 ) {
        [MMProgressHUD dismiss];
    }
    [self.tableView reloadData];
    if ([userInfomationData.refushStr isEqualToString:@"no"]) {
        NSInteger i = [self.historyMicListArr count];
        if (i>4) {
            NSIndexPath *lastPath = [NSIndexPath indexPathForRow: i-1 inSection: 0 ];
            [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            [MMProgressHUD dismiss];
        }
        else
        {
            [MMProgressHUD dismiss];
        }
        
    }
    else if ([userInfomationData.refushStr isEqualToString:@"yes"])
    {
        NSLog(@"-------x-x-x-x----  %lu-------%lu",20*userInfomationData.micMockListPageIndex,[self.historyMicListArr count]);
        NSInteger i = [self.historyMicListArr count];
        if ((20*userInfomationData.micMockListPageIndex) <= [self.historyMicListArr count] && [self.historyMicListArr count] > 4) {
            NSLog(@"sdfsdfsd----------  %lu----%lu",i,i%20);
            NSIndexPath *lastPath;
            if (i%20 == 0) {
                lastPath = [NSIndexPath indexPathForRow: i-(20*(userInfomationData.micMockListPageIndex-1))-1+3 inSection: 0 ];
            }
            else
            {
                lastPath = [NSIndexPath indexPathForRow: i-(20*(userInfomationData.micMockListPageIndex-1))-1+(20-(i%20)) inSection: 0 ];
            }
            [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        else if((20*userInfomationData.micMockListPageIndex) > [self.historyMicListArr count] && [self.historyMicListArr count] > 4)
        {
            if ((20*userInfomationData.micMockListPageIndex) - [self.historyMicListArr count] <= 20) {
                NSLog(@"xxc*vx-c*v--*-----  %lu",(i%20)-1);
                NSIndexPath *lastPath = [NSIndexPath indexPathForRow: (i%20)-1+3 inSection: 0 ];
                [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
            
        }
        
    }
    
    //消除活动列表后面未读消息的小红掉标记
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@%@",@"red",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]]];
    
}

- (void)sendMessageScu
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSInteger i = [self.historyMicListArr count]-1;
    NSLog(@"-**-*-*--------  %ld",(long)i);
    if (i>4 ) {
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow: [self.historyMicListArr count]-1 inSection: 0 ];
        [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        userInfomationData.refushStr = @"no";
    }
}



@end
