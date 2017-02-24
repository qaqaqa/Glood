//
//  EventViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//View controller-based status bar appearance

#import "EventViewController.h"
#import "Define.h"
#import "PagedFlowView.h"
#import "CommonNavView.h"
#import "EventCoverFlowView.h"
#import "MockView.h"
#import "CheckInViewController.h"
#import "InfoViewController.h"
#import "EventListView.h"
#import "QRViewController.h"
#import "CeHuaView.h"
#import "SettingsViewController.h"
#import "FeedbackViewController.h"
#import "UserInfomationData.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MMProgressHUD.h"
#import "NSString+Base64.h"
#import "VoiceConverter.h"
#import "ShowMessage.h"
#import "QRNativeViewController.h"
#import "AppDelegate.h"
#import "Mic.h"
#import "CommonClass.h"
#import "CoverFlowAlpahView.h"

#define eventCoverFlowTag 500001
@import AVFoundation;
@import AudioToolbox;

@interface EventViewController ()<PagedFlowViewDelegate,PagedFlowViewDataSource>
{
    AVAudioSession *recordSession;
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    NSData *wavdata;
    NSString *pathForFile;
    dispatch_source_t _timer;
}

@property (retain, nonatomic) PagedFlowView *hFlowView;
@property (retain, nonatomic) MockView *mockView;
@property (retain, nonatomic) UIButton *soundingRecoringButton;
@property (retain, nonatomic) UIButton *soundingRecoringVoiceButton;
@property (retain, nonatomic) UIImageView *soundingRecoringImageView; //长按手势时，检查麦克风权限是否开启
@property (retain, nonatomic) UIImageView *micTopImageView;

@property (retain, nonatomic) UIImageView *micPlayerStatesImageView;
@property (retain, nonatomic) UIButton *micShieldButton;
@property (strong, nonatomic) NSMutableArray *dataArr;//活动list
@property (strong, nonatomic) NSMutableArray *micArr;//语音list
@property (assign, nonatomic) double cgAffineTransformMakeScale;//动画系数
@property (retain, nonatomic) UIView *cehuaView;
@property (retain, nonatomic) EventListView *eventListView;
@property (retain, nonatomic) UIButton *rightButton;
@property (retain, nonatomic) UIButton *largeRightButton;
@property (retain, nonatomic) UIButton *addButton;

@property (retain, nonatomic) UIView *mockBgView;

@property (retain, nonatomic) NSTimer *yuLoadTimer;

@property (strong, nonatomic) AppDelegate *myAppDelegate;

@property (retain, nonatomic) NSTimer *animationtTimer;

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //mock 数据
    self.myAppDelegate = [UIApplication sharedApplication].delegate;
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
//    userInfomationData.historyMicArr = [[NSMutableArray alloc] initWithCapacity:10];
    self.dataArr = [[NSMutableArray alloc]init];
    self.dataArr = [userInfomationData.eventDic objectForKey:@"result"];
//    self.commonService = [[CommonService alloc] init];
    [userInfomationData.commonService clearData];
    [[NSUserDefaults standardUserDefaults] setObject:[CommonService processDictionaryIsNSNull:self.dataArr] forKey:@"eventList"];
    userInfomationData.isEnterMicList = @"false";
    self.cgAffineTransformMakeScale = 1.0;
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"currentIndex"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isSelectShield"];
    //布局
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:bgImageView];
    
//    UIImageView *bgImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    [bgImageView1 setImage:[UIImage imageNamed:@"alphe"]];
//    [self.view addSubview:bgImageView1];
    
    UIView *commonNavView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*50/568)];
    commonNavView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:commonNavView];
    
    self.micTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, commonNavView.frame.size.height+commonNavView.frame.origin.y+15, SCREEN_WIDTH, SCREEN_HEIGHT*135/568)];
    self.micTopImageView.alpha = 0;
    [self.view addSubview:self.micTopImageView];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.micTopImageView.bounds;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.0].CGColor,(__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(0, 0.3);
    [self.micTopImageView.layer setMask:gradientLayer];
    
    [self.mockView removeFromSuperview];
    self.mockView = [[MockView alloc] init];
    self.mockView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.mockView.alpha = 1;
    [self.view addSubview:self.mockView];
    
    [self.hFlowView removeFromSuperview];
    self.hFlowView = [[PagedFlowView alloc] initWithFrame:CGRectMake(0, commonNavView.frame.size.height+commonNavView.frame.origin.y-20, SCREEN_WIDTH, SCREEN_HEIGHT-commonNavView.frame.size.height)];
    self.hFlowView.delegate = self;
    self.hFlowView.dataSource = self;
//    self.hFlowView.backgroundColor = [UIColor blackColor];
    self.hFlowView.minimumPageAlpha = 0.1 ;
    self.hFlowView.minimumPageScale = 0.9;
    [self.view addSubview:self.hFlowView];
    
    self.soundingRecoringButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*75/320))/2, SCREEN_HEIGHT-(SCREEN_WIDTH*80/320), SCREEN_WIDTH*75/320, SCREEN_WIDTH*75/320)];
    self.soundingRecoringButton.layer.masksToBounds = YES;
    self.soundingRecoringButton.layer.cornerRadius = self.soundingRecoringButton.frame.size.height/2;
    self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
    self.soundingRecoringButton.alpha = 1.0;
    [self.soundingRecoringButton addTarget:self action:@selector(onStartSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.soundingRecoringButton addTarget:self action:@selector(onEndSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.soundingRecoringButton addTarget:self action:@selector(onCancelSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:self.soundingRecoringButton];
    
    self.soundingRecoringVoiceButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*65/320))/2, SCREEN_HEIGHT-(SCREEN_WIDTH*75/320), SCREEN_WIDTH*65/320, SCREEN_WIDTH*65/320)];
    self.soundingRecoringVoiceButton.alpha = 1.0;
    self.soundingRecoringVoiceButton.backgroundColor = [UIColor clearColor];
    [self.soundingRecoringVoiceButton setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
    [self.soundingRecoringVoiceButton addTarget:self action:@selector(onStartSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchDown];
    [self.soundingRecoringVoiceButton addTarget:self action:@selector(onEndSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.soundingRecoringVoiceButton addTarget:self action:@selector(onCancelSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:self.soundingRecoringVoiceButton];
    
    
    self.soundingRecoringImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*75/320))/2, SCREEN_HEIGHT-(SCREEN_WIDTH*80/320), SCREEN_WIDTH*75/320, SCREEN_WIDTH*75/320)];
    self.soundingRecoringImageView.backgroundColor = [UIColor clearColor];
    [self.soundingRecoringImageView setHidden:YES];
    [self.view addSubview:self.soundingRecoringImageView];
    
    UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showAlertView:)];
    self.soundingRecoringImageView.userInteractionEnabled = YES;
    [self.soundingRecoringImageView addGestureRecognizer:tap];
    
    self.micPlayerStatesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT-30-(SCREEN_HEIGHT*20/568), SCREEN_WIDTH*13/320, SCREEN_HEIGHT*20/568)];
    self.micPlayerStatesImageView.backgroundColor = [UIColor clearColor];
//    [self.micPlayerStatesImageView setImage:[UIImage imageNamed:@"play.png"]];
    self.micPlayerStatesImageView.alpha = 0;
    [self.view addSubview:self.micPlayerStatesImageView];
    
    self.micShieldButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-21-(SCREEN_WIDTH*20/320), self.micPlayerStatesImageView.frame.origin.y+8, SCREEN_WIDTH*30/320, SCREEN_HEIGHT*30/568)];
    [self.micShieldButton setHidden:YES];
    [self.micShieldButton setImage:[UIImage imageNamed:@"people.png"] forState:UIControlStateNormal];
    [self.micShieldButton addTarget:self action:@selector(onShieldBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.micShieldButton.alpha = 0;
    [self.view addSubview: self.micShieldButton];
    
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*48/320, SCREEN_HEIGHT*45/568)];
    [self.leftButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(onLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftButton];
    
    self.largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
    [self.largeLeftButton addTarget:self action:@selector(onLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.largeLeftButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.largeLeftButton];
    
    self.navtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*60/320, SCREEN_HEIGHT*12/568, SCREEN_WIDTH*200/320, SCREEN_HEIGHT*36/568)];
    self.navtitleLabel.text = @"Communities";
    self.navtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.navtitleLabel.textColor = [UIColor colorWithRed:57/255.0 green:66/255.0 blue:57/255.0 alpha:1.0];
    self.navtitleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
    [self.view addSubview:self.navtitleLabel];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.navtitleLabel.userInteractionEnabled = YES;
    [self.navtitleLabel addGestureRecognizer:recognizer];
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*(54+50)/320), SCREEN_HEIGHT*16/568, SCREEN_WIDTH*28/320, SCREEN_HEIGHT*28/568)];
    [self.rightButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(onRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rightButton];
    
    self.largeRightButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*(54+50)/320), 0, 54, 54)];
    [self.largeRightButton addTarget:self action:@selector(onRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.largeRightButton];
    
    self.addButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*30/320)-20, 12, 30, 30)];
    [self.addButton addTarget:self action:@selector(onAddQr) forControlEvents:UIControlEventTouchUpInside];
//    [self.addButton setTitle:@"+" forState:UIControlStateNormal];
    [self.addButton setImage:[UIImage imageNamed:@"plus_icon"] forState:UIControlStateNormal];
//    [self.addButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.addButton.titleLabel.font = [UIFont boldSystemFontOfSize:25];
    [self.view addSubview:self.addButton];
    
    
    if ([userInfomationData.pushEventVCTypeStr isEqualToString:@"QR"]) {
//        userInfomationData.historyMicArr = [[NSMutableArray alloc] initWithCapacity:10];
            // something
        
        [userInfomationData.commonService getMessageInRoom:@"" roomId:userInfomationData.QRRoomId];
        [self pushChatRoom];
        
    }
    
    self.gcdView = [[UIView alloc] init];
    self.gcdView.frame = CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*200/320))/2, (SCREEN_HEIGHT-(SCREEN_WIDTH*200/320))/2, SCREEN_WIDTH*200/320, SCREEN_WIDTH*200/320);
    self.gcdView.backgroundColor = [UIColor whiteColor];
    self.gcdView.layer.cornerRadius = 8;
    self.gcdView.layer.masksToBounds = YES;
    [self.gcdView setHidden:YES];
    [self.view addSubview:self.gcdView];
    
    self.gcdLabel = [[UILabel alloc] init];
    self.gcdLabel.frame = CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*200/320))/2, (SCREEN_HEIGHT-(SCREEN_WIDTH*200/320))/2, self.gcdView.frame.size.width, self.gcdView.frame.size.height);
    self.gcdLabel.textAlignment = NSTextAlignmentCenter;
    self.gcdLabel.font = [UIFont boldSystemFontOfSize:50];
    [self.gcdLabel setHidden:YES];
    self.gcdLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.gcdLabel];
    
    self.mockBgView = [[UIView alloc] init];
    self.mockBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-150);
    self.mockBgView.backgroundColor = [UIColor clearColor];
    [self.mockBgView setHidden:YES];
    [self.view addSubview: self.mockBgView];
    
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    [self onRightBtnClick:nil];
}

#pragma mark ==========侧滑菜单栏=========
- (void)onCeHuaMoreBtnClick:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        self.cehuaView.frame = CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark ========== left more button 活动卡片页面========
- (void)onLeftBtnClick
{
    if (self.mockView.shieldBgButton.alpha != 1.0) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        if (![userInfomationData.isEnterMicList isEqualToString:@"false"]) {
            [self.leftButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
            [self onMing];
        }
        else
        {
            NSLog(@"left");
            //侧滑菜单栏
            [self.cehuaView removeFromSuperview];
            self.cehuaView = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            self.cehuaView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:self.cehuaView];
            
            CeHuaView *ceHuav = [[CeHuaView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [self.cehuaView addSubview:ceHuav];
            
            UIButton *ceHuaMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*34/320)-52, SCREEN_HEIGHT*15/568, SCREEN_WIDTH*48/320, SCREEN_HEIGHT*45/568)];
            [ceHuaMoreButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
            [ceHuaMoreButton addTarget:self action:@selector(onCeHuaMoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.cehuaView addSubview:ceHuaMoreButton];
            
            UIButton *largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*34/320)-40, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
            [largeLeftButton addTarget:self action:@selector(onCeHuaMoreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            largeLeftButton.backgroundColor = [UIColor clearColor];
            [self.cehuaView addSubview:largeLeftButton];
            
            [UIView animateWithDuration:0.5 animations:^{
                self.cehuaView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            } completion:^(BOOL finished) {
            }];
            
            UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
            recognizer.direction = UISwipeGestureRecognizerDirectionLeft; //设置轻扫方向；默认是 UISwipeGestureRecognizerDirectionRight，即向右轻扫
            [self.cehuaView addGestureRecognizer:recognizer];
        }
    }
    
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [self onCeHuaMoreBtnClick:nil];
}

#pragma mark ========== right eventlist button ========
- (void)onRightBtnClick:(id)sender
{
    if (self.mockView.shieldBgButton.alpha != 1.0) {
        NSLog(@"rigth");
        self.rightButton.userInteractionEnabled = NO;
        self.largeRightButton.userInteractionEnabled = NO;
        self.eventListView = [[EventListView alloc] initWithFrame:CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.eventListView.delegate = self;
        [self.view addSubview:self.eventListView];
        [UIView animateWithDuration:0.5 animations:^{
            self.eventListView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
            self.rightButton.userInteractionEnabled = YES;
            self.largeRightButton.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark ========== 活动卡片页面，点击语音头像 =========
- (void)onCoverFlowViewHeadBtnClick
{
    [self pushChatRoom];
}

#pragma mark ========== 屏蔽某人聊天 ========
- (void)onShieldBtnClick:(id)sender
{
    
    NSLog(@"shield----%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"isSelectShield"]);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isSelectShield"] integerValue] == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"isSelectShield"];
        [self.micShieldButton setImage:[UIImage imageNamed:@"like2.png"] forState:UIControlStateNormal];
        self.soundingRecoringButton.userInteractionEnabled = NO;
        self.soundingRecoringVoiceButton.userInteractionEnabled = NO;
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isSelectShield"];
        [self.micShieldButton setImage:[UIImage imageNamed:@"people.png"] forState:UIControlStateNormal];
        self.soundingRecoringButton.userInteractionEnabled = YES;
        self.soundingRecoringVoiceButton.userInteractionEnabled = YES;
    }
    
}

#pragma mark PagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;{
    return CGSizeMake(SCREEN_WIDTH*260/320, SCREEN_HEIGHT*450/568);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index {
    NSLog(@"Scrolled to page # %ld", (long)index);
    
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"currentIndex"];
    
    NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:index] objectForKey:@"id"];
    NSArray *result = [[NSArray alloc] initWithArray:[self.myAppDelegate selectCoreDataroomId:roomId]];
    NSLog(@"++9++9+9+9++++++  %@",roomId);
    //  给数据源数组中添加数据
    
    if ([result count] > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
            [MMProgressHUD showWithTitle:@"get chat history" status:NSLocalizedString(@"Please wating", nil)];
            [userInfomationData.commonService getMessageInRoom:@"" roomId:roomId];
        });
        
    }
    
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index{
    NSLog(@"Tapped on page # %ld", (long)index);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PagedFlowView Datasource
//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView{
    return [self.dataArr count];
}

//返回给某列使用的View

- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"eventIndex"];
    EventCoverFlowView *eventCoverFlowView = (EventCoverFlowView *)[flowView dequeueReusableCell];
        eventCoverFlowView = [[EventCoverFlowView alloc] init];
        eventCoverFlowView.tag = eventCoverFlowTag+index;
        [eventCoverFlowView.infoButton addTarget:self action:@selector(onInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        [eventCoverFlowView.checkInButton addTarget:self action:@selector(onCheckInClick:) forControlEvents:UIControlEventTouchUpInside];
    return eventCoverFlowView;
}

- (void)getMicHistoryList
{
    EventCoverFlowView *find_eventCoverFlowView = (EventCoverFlowView *)[self.view viewWithTag:eventCoverFlowTag+[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    //  查询数据
    NSString *roomIdStr;
    if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
        roomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    }
    else
    {
        roomIdStr = userInfomationData.QRRoomId;
    }
    NSArray *result = [[NSArray alloc] initWithArray:[self.myAppDelegate selectCoreDataroomId:roomIdStr]];
    //  给数据源数组中添加数据
    
    
    
    find_eventCoverFlowView.historyMicListArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [result count]; i++) {
        [find_eventCoverFlowView.historyMicListArr addObject:[result objectAtIndex:i]];
    }
    
    /*
    //在这个房间中被屏蔽的人的ID
    NSMutableArray *shieldMutableArr = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSInteger x = 0; x < [(NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] count]; x++) {
        if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] objectAtIndex:x] objectForKey:@"room_id"] isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]]) {
            [shieldMutableArr addObject:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] objectAtIndex:x] objectForKey:@"user_id"]];
            NSLog(@"-=-=-=xxxx===  %@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"Shield"] objectAtIndex:x] objectForKey:@"user_id"]);
        }
    }
    
    //根被屏蔽人的id，清除数据中包含该用户id的那一条数据
    NSMutableIndexSet *indexSets = [[NSMutableIndexSet alloc] init];
    for (NSInteger i = 0; i < [find_eventCoverFlowView.historyMicListArr count]; i++) {
        for (NSInteger x = 0; x < [shieldMutableArr count]; x ++) {
            Mic *mic = find_eventCoverFlowView.historyMicListArr[i];
            if ([[shieldMutableArr objectAtIndex:x] isEqualToString:mic.userId]) {
                [indexSets addIndex:i];
                [self.myAppDelegate deleteShieldMessage:roomIdStr userId:mic.userId];
            }
        }
    }
    [find_eventCoverFlowView.historyMicListArr removeObjectsAtIndexes:indexSets];
     */
    
    [find_eventCoverFlowView.tableView reloadData];
    
    [MMProgressHUD dismiss];
    
}

#pragma mark ========= info ===========
- (void)onInfoClick:(id)sender
{
    NSLog(@"info");
    InfoViewController *infoVC = [[InfoViewController alloc] initWithNibName:nil bundle:nil];
    CATransition* transition = [CATransition animation];
    transition.type = kCATransitionPush;//可更改为其他方式
    transition.subtype = kCATransitionFromLeft;//可更改为其他方式
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:infoVC animated:NO];
}

#pragma mark ========= check-in ===========
- (void)onCheckInClick:(id)sender
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSLog(@"check-in");
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:@"get tickets list" status:NSLocalizedString(@"Please wating", nil)];
    [[userInfomationData.commonService getTicket:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]] then:^id(id value) {
        NSLog(@"获取票列表成功");
        [MMProgressHUD dismiss];
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        userInfomationData.ticketsDic = [[NSDictionary alloc] init];
        userInfomationData.ticketsDic = value;
        CheckInViewController *checkInfoVC = [[CheckInViewController alloc] initWithNibName:nil bundle:nil];
        CATransition* transition = [CATransition animation];
        transition.type = kCATransitionPush;//可更改为其他方式
        transition.subtype = kCATransitionFromRight;//可更改为其他方式
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:checkInfoVC animated:NO];
        return value;
    } error:^id(NSError *error) {
        NSLog(@"获取票列表失败--- %@",error);
        [MMProgressHUD dismissWithError:@"get tickets list error,try again!" afterDelay:2.0f];
        return error;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startScrollViewIsScrolling" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"endScrollViewIsScrolling" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shield" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cancelShield" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addQr" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onLeftBtnClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onMing" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onSetting" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onFeedback" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onCoverFlowViewHeadBtnClick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getMicHistoryList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shield" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"yesShield" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"becomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stopRecording" object:nil];
    
    [self.mockView deallocNSNotificationCenter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onScrollStart)name:@"startScrollViewIsScrolling"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onScrollEnd)name:@"endScrollViewIsScrolling"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onShield)name:@"shield"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onCancelShield)name:@"cancelShield"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onAddQr)name:@"addQr"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onLeftBtnClick)name:@"onLeftBtnClick"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onMing)name:@"onMing"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onSetting)name:@"onSetting"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onFeedbak)name:@"onFeedback"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onCoverFlowViewHeadBtnClick)name:@"onCoverFlowViewHeadBtnClick"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(getMicHistoryList)name:@"getMicHistoryList"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(getYesShield)name:@"yesShield"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(becomeActive)name:@"becomeActive"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onStopRecording)name:@"stopRecording"object:nil];
    
    
    [self.mockView addNSNotificationCenter];
    
    
    
//    [self.myAppDelegate deleteAllPreLoadingMessage];
    
}

- (void)becomeActive
{
    if ((NSNull *)[[NSUserDefaults standardUserDefaults] objectForKey:@"pushUserInfo"] != [NSNull null]) {
        for (NSInteger i = 0; i < [(NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
            if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"pushUserInfo"] objectForKey:@"eventId"] isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                NSLog(@"*--*---*--*--xx-----  %@-+--%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"pushUserInfo"] objectForKey:@"eventId"],[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]);
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"pushUserInfo"];
                [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"currentIndex"];
                self.eventListView.frame = CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
                if ([userInfomationData.isEnterMicList isEqualToString:@"false"])
                {
                    [self pushChatRoom];
                }
                else
                {
                    [self exchangeChatRoom];
                    NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
                    NSArray *result = [[NSArray alloc] initWithArray:[self.myAppDelegate selectCoreDataroomId:roomId]];
                    //  给数据源数组中添加数据
                    
                    if ([result count] > 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                    }
                    else
                    {
                        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
                        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
                        [MMProgressHUD showWithTitle:@"get chat history" status:NSLocalizedString(@"Please wating", nil)];
                        [userInfomationData.commonService getMessageInRoom:@"" roomId:roomId];
                    }
                }
                
            }
        }
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self becomeActive];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //在其他离开改页面的方法同样加上下面代码
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)onShield
{
    self.soundingRecoringButton.userInteractionEnabled = NO;
    self.soundingRecoringVoiceButton.userInteractionEnabled = NO;
    self.micShieldButton.userInteractionEnabled = NO;
}

- (void)onCancelShield
{
    self.soundingRecoringButton.userInteractionEnabled = YES;
    self.soundingRecoringVoiceButton.userInteractionEnabled = YES;
    self.micShieldButton.userInteractionEnabled = YES;
}

- (void)getYesShield
{
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isSelectShield"];
    [self.micShieldButton setImage:[UIImage imageNamed:@"people.png"] forState:UIControlStateNormal];
    self.soundingRecoringButton.userInteractionEnabled = YES;
    self.soundingRecoringVoiceButton.userInteractionEnabled = YES;
    self.micShieldButton.userInteractionEnabled = YES;
}

#pragma mark ========= eventListViewDelegate ======
#pragma mark ========= 从列表中进入聊天室 =========
- (void)eventListJoinRoom:(NSInteger)index
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.refushStr = @"no";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"recordOrExchangeChatRoomStopAnimation" object:self];
    
    [[NSUserDefaults standardUserDefaults] setInteger:index-1 forKey:@"currentIndex"];
    if ([userInfomationData.isEnterMicList isEqualToString:@"false"])
    {
        [self pushChatRoom];
        //  查询数据
        NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
        NSArray *result = [[NSArray alloc] initWithArray:[self.myAppDelegate selectCoreDataroomId:roomId]];
        //  给数据源数组中添加数据
        
        if ([result count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
        }
        else
        {
            UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
            [MMProgressHUD showWithTitle:@"get chat history" status:NSLocalizedString(@"Please wating", nil)];
            [userInfomationData.commonService getMessageInRoom:@"" roomId:roomId];
        }
//        在列表中选择了那个roomid
    }
    else
    {
        [self exchangeChatRoom];
        //  查询数据
        NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
        NSArray *result = [[NSArray alloc] initWithArray:[self.myAppDelegate selectCoreDataroomId:roomId]];
        //  给数据源数组中添加数据
        
        if ([result count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
        }
        else
        {
            UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
            [MMProgressHUD showWithTitle:@"get chat history" status:NSLocalizedString(@"Please wating", nil)];
            [userInfomationData.commonService getMessageInRoom:@"" roomId:roomId];
        }
        
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.eventListView.frame = CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark ========= Ming ===========
- (void)onMing
{
    [self navigatorButton];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"recordOrExchangeChatRoomStopAnimation" object:self];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.refreshCount = 0;
    userInfomationData.mockViewNameLabelIsHiddenStr = @"no";
    userInfomationData.currtentRoomIdStr = @"";
    if ([userInfomationData.isEnterMicList isEqualToString:@"true"]) {
//        userInfomationData.historyMicArr = [[NSMutableArray alloc] initWithCapacity:10];
        [userInfomationData.recordAudio stopPlay];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"currentIndex"];
        NSString *roomId;
        if ([userInfomationData.pushEventVCTypeStr isEqualToString:@"QR"]) {
            roomId = userInfomationData.QRRoomId;
        }
        else
        {
            roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
            
            
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [userInfomationData.commonService getMessageInRoom:@"" roomId:roomId];
        });
        
        //在聊天室里
        [self.soundingRecoringButton removeFromSuperview];
        [self.soundingRecoringVoiceButton removeFromSuperview];
        userInfomationData.isEnterMicList = @"false";
        self.mockView.alpha = 0;
        self.navtitleLabel.text = @"Communities";
        self.micTopImageView.alpha = 0;
        self.micShieldButton.alpha = 0;
        self.micPlayerStatesImageView.alpha = 0;
        self.mockView.lastBgView.alpha = 1;
        [self.mockView.lastBgView setHidden:NO];
        [UIView animateWithDuration:0.5 animations:^{
            self.mockView.lastBgView.transform = CGAffineTransformMakeScale(1, 1);
//            self.mockView.tableView.transform = CGAffineTransformMakeScale(1, 1);
            self.mockView.micBottomImageView.transform = CGAffineTransformMakeScale(1, 1);
//            self.mockView.refreshView.frame = CGRectMake(0,0,SCREEN_WIDTH*260/320,46);
//            self.mockView.refreshView.backgroundColor = [UIColor clearColor];
//            self.mockView.refreshView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            self.hFlowView.alpha = 1;
            
            self.mockView.micBottomImageView.frame = CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*260/320))/2,SCREEN_HEIGHT*275/568,SCREEN_WIDTH*260/320,SCREEN_HEIGHT*220/568);
//            self.mockView.tableView.frame = CGRectMake(0,0,SCREEN_WIDTH*260/320,SCREEN_HEIGHT*220/568);
            [self.hFlowView removeFromSuperview];
            self.hFlowView = [[PagedFlowView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT*50/568)-15, SCREEN_WIDTH, SCREEN_HEIGHT-(SCREEN_HEIGHT*50/568))];
            self.hFlowView.delegate = self;
            self.hFlowView.dataSource = self;
            self.hFlowView.minimumPageAlpha = 0.1 ;
            self.hFlowView.minimumPageScale = 0.9;
            [self.view addSubview:self.hFlowView];
            
            self.soundingRecoringButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*75/320))/2, SCREEN_HEIGHT-(SCREEN_WIDTH*80/320), SCREEN_WIDTH*75/320, SCREEN_WIDTH*75/320)];
            self.soundingRecoringButton.layer.masksToBounds = YES;
            self.soundingRecoringButton.layer.cornerRadius = self.soundingRecoringButton.frame.size.height/2;
            self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
            self.soundingRecoringButton.alpha = 1.0;
            [self.soundingRecoringButton addTarget:self action:@selector(onStartSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchDown];
            [self.soundingRecoringButton addTarget:self action:@selector(onEndSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.soundingRecoringButton addTarget:self action:@selector(onCancelSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchUpOutside];
            [self.view addSubview:self.soundingRecoringButton];
            
            self.soundingRecoringVoiceButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*65/320))/2, SCREEN_HEIGHT-(SCREEN_WIDTH*75/320), SCREEN_WIDTH*65/320, SCREEN_WIDTH*65/320)];
            self.soundingRecoringVoiceButton.backgroundColor = [UIColor clearColor];
            [self.soundingRecoringVoiceButton setImage:[UIImage imageNamed:@"voice"] forState:UIControlStateNormal];
            self.soundingRecoringVoiceButton.alpha = 1.0;
            [self.soundingRecoringVoiceButton addTarget:self action:@selector(onStartSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchDown];
            [self.soundingRecoringVoiceButton addTarget:self action:@selector(onEndSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.soundingRecoringVoiceButton addTarget:self action:@selector(onCancelSoundRecoringBtnClick:) forControlEvents:UIControlEventTouchUpOutside];
            [self.view addSubview:self.soundingRecoringVoiceButton];
            
            self.soundingRecoringImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*75/320))/2, SCREEN_HEIGHT-(SCREEN_WIDTH*80/320), SCREEN_WIDTH*75/320, SCREEN_WIDTH*75/320)];
            self.soundingRecoringImageView.backgroundColor = [UIColor clearColor];
            [self.soundingRecoringImageView setHidden:YES];
            [self.view addSubview:self.soundingRecoringImageView];
            
            UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(showAlertView:)];
            self.soundingRecoringImageView.userInteractionEnabled = YES;
            [self.soundingRecoringImageView addGestureRecognizer:tap];
            
            
            [self initUserDefaultsSourceAndRmoveEventListView];
        }];
        
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.cehuaView.frame = CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.eventListView.frame = CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark ========= onSetting ===========
- (void)onSetting
{
    [self navigatorButton];
    [self initUserDefaultsSourceAndRmoveEventListView];
    SettingsViewController *settingVC = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:settingVC animated:YES];
}

#pragma mark ========= onFeedbak ===========
- (void)onFeedbak
{
    [self navigatorButton];
    [self initUserDefaultsSourceAndRmoveEventListView];
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:feedbackVC animated:YES];
}

- (void)navigatorButton
{
    self.rightButton.frame = CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*(54+50)/320), SCREEN_HEIGHT*16/568, SCREEN_WIDTH*28/320, SCREEN_HEIGHT*28/568);
    self.largeRightButton.frame = CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*(54+50)/320), 0, 54, 54);
    [self.addButton setHidden:NO];
    
}

- (void)initUserDefaultsSourceAndRmoveEventListView
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.currtentRoomIdStr = @"";
//    userInfomationData.historyMicArr = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSInteger i = 0; i < [(NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]];
    }
    
    for (id obj in self.view.subviews)  {
        if ([obj isKindOfClass:[EventListView class]]) {
            EventListView* eventListView = (EventListView*)obj;
            [eventListView setHidden:YES];
        }
    }
}

#pragma mark ========== 跳转到QR界面 ======
- (void)onAddQr
{
    QRNativeViewController *qrVC = [[QRNativeViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:qrVC animated:YES];
}

#pragma mark ========== 录音按钮的隐藏显示 ======
- (void)onScrollStart
{
    self.mockView.alpha = 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.soundingRecoringButton.alpha = 0.0;
        self.soundingRecoringVoiceButton.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
}
- (void)onScrollEnd
{
    
    [UIView animateWithDuration:0.4 animations:^{
        self.soundingRecoringButton.alpha = 1.0;
        self.soundingRecoringVoiceButton.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)timerAnimation
{
    self.timerCount += 1;
    switch (self.timerCount) {
        case 1:
                {
                    [UIView animateWithDuration:1.5 animations:^{
                        self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.1,1.1);
                        self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
                    } completion:^(BOOL finished) {
                    }];
                }
            break;
        case 2:
                {
                    [UIView animateWithDuration:1.5 animations:^{
                        self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.0,1.0);
                        self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:253/255.0 green:65/255.0 blue:75/255.0 alpha:1.0];
                    } completion:^(BOOL finished) {
                    }];
                }
            break;
        case 3:
                {
                    [UIView animateWithDuration:1.5 animations:^{
                        self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.1,1.1);
                        self.soundingRecoringButton.backgroundColor = [UIColor greenColor];
                    } completion:^(BOOL finished) {
                    }];
                }
            break;
        case 4:
                {
                    [UIView animateWithDuration:1.5 animations:^{
                        self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.0,1.0);
                        self.soundingRecoringButton.backgroundColor = [UIColor yellowColor];
                    } completion:^(BOOL finished) {
                    }];
                    self.timerCount = 0;
                }
            break;
            
        default:
            break;
    }
    NSLog(@"sdfasdf*a-sd*f-asd*f-asd*f-*---------- %ld",self.timerCount);
    
    //    [UIView animateWithDuration:1.5 animations:^{
    //        self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.1,1.1);
    //        self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
    //    } completion:^(BOOL finished) {
    //        [UIView animateWithDuration:1.5 animations:^{
    //            self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.0,1.0);
    //            self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:253/255.0 green:65/255.0 blue:75/255.0 alpha:1.0];
    //        } completion:^(BOOL finished) {
    //            [UIView animateWithDuration:1.5 animations:^{
    //                self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.1,1.1);
    //                self.soundingRecoringButton.backgroundColor = [UIColor greenColor];
    //            } completion:^(BOOL finished) {
    //                [UIView animateWithDuration:1.5 animations:^{
    //                    self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.0,1.0);
    //                    self.soundingRecoringButton.backgroundColor = [UIColor yellowColor];
    //                } completion:^(BOOL finished) {
    //                }];
    //            }];
    //        }];
    //    }];
}

#pragma mark ========== 开始录音 ============
- (void)onStartSoundRecoringBtnClick:(id)sender
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        if ([userInfomationData.isEnterMicList isEqualToString:@"true"]) {
            //判断是否开启麦克风权限
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            NSLog(@"*-*-*--*hahhah--- %ld",(long)authStatus);
            
            if (authStatus ==AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                NSLog(@"hiehieheihiehieheieieieheiehieheiehi-------");
                [self.soundingRecoringImageView setHidden:NO];
            }
            else
            {
                self.animationtTimer = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                                        target:self
                                                                      selector:@selector(timerAnimation)
                                                                      userInfo:nil
                                                                       repeats:YES];
                self.timerCount = 0;
                
                [self.mockBgView setHidden:NO];
                NSLog(@"开始录音！");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"recordOrExchangeChatRoomStopAnimation" object:self];
                self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
                
                [self.yuLoadTimer invalidate];
                self.yuLoadTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                    target:self
                                                                  selector:@selector(yuLoad)
                                                                  userInfo:nil
                                                                   repeats:NO];
                //            [self.soundingRecoringButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
                self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
                [userInfomationData.recordAudio startRecoring:@"IOS"];
                self.recordAudioTimeOutStr = @"no";
                [self gcdTimeRecordAudio];
            }
            
            //判断应用程序是不是第一次启用麦克风，用以在第一次询问麦克风权限时，预加载出错问题
            NSUserDefaults *TimeOfBootCount = [NSUserDefaults standardUserDefaults];
            if (![TimeOfBootCount valueForKey:@"time"]) {
                [TimeOfBootCount setValue:@"sd" forKey:@"time"];
                NSLog(@"第一次启动");
                [self.mockBgView setHidden:YES];
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    NSString *roomIdStr;
                    if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
                        roomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
                    }
                    else
                    {
                        for (NSInteger i = 0; i < [(NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
                            if ([userInfomationData.QRRoomId isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                                roomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"];
                            }
                        }
                        
                    }
                    [self.myAppDelegate deletePreLoadingMessage:roomIdStr message:[NSString stringWithFormat:@"%lld",userInfomationData.yuMessageId]];
                    [userInfomationData.recordAudio stopRecoring];
                    
                    if (granted) {
                        
                        // 用户同意获取麦克风
                        
                        
                    } else {
                        
                        // 用户不同意获取麦克风
                        
                    }
                    
                }];
            }else{
                NSLog(@"不是第一次启动");
            }
            
        }
    }
    else
    {
        [ShowMessage showMessage:@"network error"];
    }
    
}

- (void)yuLoad
{
    [self.yuLoadTimer invalidate];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startRecordAudio" object:self];//预加载将要发送的语音
}

- (void)showAlertView:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if ([userInfomationData.isEnterMicList isEqualToString:@"true"] && (authStatus ==AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Please allow Glood to access your device's microphone in \"Settings\" -> \"Privacy\" -> \"Microphone\"."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:@"Set", nil];
            alert.tag = 10212;
            [alert show];
            return;
        }
        
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10212) {
        if (buttonIndex == 1) {
            NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
            if ([phoneVersion doubleValue] < 10) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=MICROPHONE"]];
            }
            else{
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                    [[UIApplication sharedApplication]openURL:url options:@{}completionHandler:^(BOOL        success) {
                    }];
                }
            }
        }
    }
}

#pragma mark ========== 结束录音 ============
- (void)onEndSoundRecoringBtnClick:(id)sender
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSLog(@"sound recoring");
    if ([userInfomationData.isEnterMicList isEqualToString:@"false"]) {
        [self pushChatRoom];
    }
    else{
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
            //录制发送语音
            //        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
            //        if ((authStatus ==AVAuthorizationStatusNotDetermined || authStatus ==AVAuthorizationStatusAuthorized)) {
            NSLog(@"结束录音！");
            [self.yuLoadTimer invalidate];
            [self performSelector:@selector(cancelTimer) withObject:nil afterDelay:0.5f];
            if ([self.recordAudioTimeOutStr isEqualToString:@"no"]) {
                //                [self.soundingRecoringButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
                self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
                if (![CommonService isBlankString:[userInfomationData.recordAudio stopRecoring]]) {
                    if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
                        //                        [userInfomationData.commonService sendMessageInRoom:[userInfomationData.recordAudio stopRecoring] roomId:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"] messageType:3];
                        [self waitingSendMessageQunenMutableDic:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"] messageId:nil message:[userInfomationData.recordAudio stopRecoring]];
                    }
                    else
                    {
                        for (NSInteger i = 0; i < [(NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
                            if ([userInfomationData.QRRoomId isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                                
                                //                                [userInfomationData.commonService sendMessageInRoom:[userInfomationData.recordAudio stopRecoring] roomId:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"] messageType:3];
                                [self waitingSendMessageQunenMutableDic:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"] messageId:nil message:[userInfomationData.recordAudio stopRecoring]];
                            }
                        }
                        
                    }
                    
                    self.soundingRecoringButton.userInteractionEnabled = NO;
                    self.soundingRecoringVoiceButton.userInteractionEnabled = NO;
                    [self performSelector:@selector(recoverRecordButton) withObject:nil afterDelay:0.8f];
                }
                
            }
        }
        else
        {
            [ShowMessage showMessage:@"network error"];
        }
        
            
            
        }
//        }
        
}

- (void)cancelTimer
{
//    [self.soundingRecoringButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
    self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
//        [self.myAppDelegate deletePreLoadingMessage];
    }
    [self.gcdView setHidden:YES];
    [self.gcdLabel setHidden:YES];
    [self.mockBgView setHidden:YES];
}

#pragma mark ========== 手指移开，取消录音 ============
- (void)onCancelSoundRecoringBtnClick:(id)sender
{
    [self.animationtTimer invalidate];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if ([userInfomationData.isEnterMicList isEqualToString:@"true"] && (authStatus ==AVAuthorizationStatusNotDetermined || authStatus ==AVAuthorizationStatusAuthorized)) {
        NSString *roomIdStr;
        if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
            roomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
        }
        else
        {
            for (NSInteger i = 0; i < [(NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
                if ([userInfomationData.QRRoomId isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                    roomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"];
                }
            }
            
        }
        [self.myAppDelegate deletePreLoadingMessage:roomIdStr message:[NSString stringWithFormat:@"%lld",userInfomationData.yuMessageId]];
        NSLog(@"取消录音！");
        [ShowMessage showMessage:@"cancel recording"];
        [self.mockBgView setHidden:YES];
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
//        [self.soundingRecoringButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
        self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
        dispatch_source_cancel(_timer);
        [userInfomationData.recordAudio stopRecoringCancel];
    }
    
    
}

- (void)onStopRecording
{
    [self recoverRecordButton];
}

- (void)recoverRecordButton
{
    [self.animationtTimer invalidate];
    [self.mockBgView setHidden:YES];
    self.soundingRecoringButton.userInteractionEnabled = YES;
    self.soundingRecoringVoiceButton.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.1 animations:^{
        self.soundingRecoringButton.transform = CGAffineTransformMakeScale(1.0,1.0);
        self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
    } completion:^(BOOL finished) {
    }];
}

//录音倒计时
- (void)gcdTimeRecordAudio
{
    //录音倒计时
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
//                [self.soundingRecoringButton setImage:[UIImage imageNamed:@"voice.png"] forState:UIControlStateNormal];
                self.soundingRecoringButton.backgroundColor = [UIColor colorWithRed:27/255.0 green:127/255.0 blue:254/255.0 alpha:1.0];
                [self.gcdView setHidden:YES];
                [self.gcdLabel setHidden:YES];
                [self performSelector:@selector(recoverRecordButton) withObject:nil afterDelay:0.8f];

            });
        }else{
            //找到语音列表里tag值最大的，也就是预加载的那条语音
            
            NSString *strTime = [NSString stringWithFormat:@"%d秒",timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                if (timeout < 10) {
                    [self.gcdView setHidden:NO];
                    [self.gcdLabel setHidden:NO];
                    self.gcdLabel.text = strTime;
                    if (timeout == 1) {
//                        [userInfomationData.recordAudio stopRecoring];
//                        if ([userInfomationData.recordAudio stopRecoring] != nil) {
                            if ([self.recordAudioTimeOutStr isEqualToString:@"no"]) {
                                self.recordAudioTimeOutStr = @"yes";
                                [self waitingSendMessageQunenMutableDic:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"] messageId:nil message:[userInfomationData.recordAudio stopRecoring]];
//                            }
                            
                            
                        }
                    }
                }
                
            });
            timeout--;
        }  
    });  
    dispatch_resume(_timer);
}

- (void)waitingSendMessageQunenMutableDic:(NSString *)roomIdx messageId:(NSString *)messageIdx message:(NSString *)messagex
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    messageIdx = [NSString stringWithFormat:@"%lld",userInfomationData.yuMessageId];
    userInfomationData.waitingSendMessageQunenMutableDic = @{
                                                             @"message":messagex,
                                                             @"room_id":roomIdx,
                                                             @"message_id":messageIdx
                                                             };
    [userInfomationData.waitingSendMessageQunenMutableArr addObject:userInfomationData.waitingSendMessageQunenMutableDic];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        for (NSInteger i = 0; i < [userInfomationData.waitingSendMessageQunenMutableArr count]; i ++) {
            [userInfomationData.commonService sendMessageInRoom:[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:i] objectForKey:@"message"] roomId:[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:i] objectForKey:@"room_id"] messageType:3 messageId:[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:i] objectForKey:@"message_id"]];
            [userInfomationData.waitingSendMessageQunenMutableArr removeObjectAtIndex:i];
        }
    });
}

#define nameLabelTag 20001
//进入聊天室场景
- (void)pushChatRoom
{
    [self.leftButton setImage:[UIImage imageNamed:@"backqr"] forState:UIControlStateNormal];
    self.rightButton.frame = CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*54/320), SCREEN_HEIGHT*16/568, SCREEN_WIDTH*28/320, SCREEN_HEIGHT*28/568);
    self.largeRightButton.frame = CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*54/320), 0, 54, 54);
    [self.addButton setHidden:YES];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.mockView.micBottomImageView.bounds;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor,(__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 0.1);
    [self.mockView.micBottomImageView.layer setMask:gradientLayer];
    //切换聊天室时，取消屏蔽
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isSelectShield"];
    [self.micShieldButton setImage:[UIImage imageNamed:@"people.png"] forState:UIControlStateNormal];
    self.soundingRecoringButton.userInteractionEnabled = YES;
    self.soundingRecoringVoiceButton.userInteractionEnabled = YES;
    //每次进入聊天室页面检查麦克风权限是否开启
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    NSLog(@"*-*-*--*hahhah--- %ld",(long)authStatus);
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.refushStr = @"no";
    if ((authStatus ==AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)) {
        [self.soundingRecoringImageView setHidden:NO];
    }
    else
    {
        [self.soundingRecoringImageView setHidden:YES];
    }
    
    self.view.userInteractionEnabled = NO;
    
    self.cgAffineTransformMakeScale = 1.41;
    //进入聊天室列表
    NSMutableArray *monthMutableArr = [[NSMutableArray alloc] initWithObjects:@"JAN",@"FEB",@"MAR",@"APR",@"MAY",@"JUN",@"JUL",@"AUG",@"SEP",@"OCT",@"NOV",@"DEC", nil];
    
    
    NSString *currentDateStr;
    userInfomationData.micMockListPageIndex = 1; //每次重新进入聊天室，当前分页置为0
    if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
        [self.mockView.topImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",self.mockView.topImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
        self.mockView.eventNameLabel.text = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"name"];
        currentDateStr = [self getLocalDateFormateUTCDate:[[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"schedules"] objectAtIndex:0] objectForKey:@"begin_time_utc"]];
        [self.micTopImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",self.micTopImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
        
        //消除活动列表后面未读消息的小红掉标记
        userInfomationData.currtentRoomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@%@",@"red",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]]];
        
    }
    else
    {
        for (NSInteger i = 0; i < [(NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
            if ([userInfomationData.QRRoomId isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                
                [self.mockView.topImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",self.mockView.topImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
                
                self.mockView.eventNameLabel.text = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"name"];
                currentDateStr = [self getLocalDateFormateUTCDate:[[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"schedules"] objectAtIndex:0] objectForKey:@"begin_time_utc"]];
                [self.micTopImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",self.micTopImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
                
                //消除活动列表后面未读消息的小红掉标记
                userInfomationData.currtentRoomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@%@",@"red",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]]];
            }
        }
    }
    NSString *monthStr = [monthMutableArr objectAtIndex:[[currentDateStr substringWithRange:NSMakeRange(5,2)] integerValue]-1];
    NSString *dayStr = [currentDateStr substringWithRange:NSMakeRange(8,2)];
    self.mockView.monthLabel.text = monthStr;
    self.mockView.dayLabel.text = dayStr;
    
    userInfomationData.isEnterMicList = @"true";
    self.mockView.alpha = 1;
    self.hFlowView.alpha = 0;
    [self.hFlowView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
    [UIView animateWithDuration:1.0 animations:^{
        self.mockView.lastBgView.alpha = 0;
        self.mockView.micBottomImageView.frame = CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*260/320))/2,SCREEN_HEIGHT*220/568,SCREEN_WIDTH*260/320,SCREEN_HEIGHT*220/568);
//        self.mockView.tableView.frame = CGRectMake(0,0,SCREEN_WIDTH*260/320,SCREEN_HEIGHT*220/568);
        self.mockView.lastBgView.transform = CGAffineTransformMakeScale(1.32, 1.32);
//        self.mockView.tableView.transform = CGAffineTransformMakeScale(self.cgAffineTransformMakeScale, self.cgAffineTransformMakeScale);
        self.mockView.micBottomImageView.transform = CGAffineTransformMakeScale(self.cgAffineTransformMakeScale, self.cgAffineTransformMakeScale);
//        self.mockView.refreshView.frame = CGRectMake(0,-40,SCREEN_WIDTH*260/320,46);
//        self.mockView.refreshView.backgroundColor = [UIColor clearColor];
//        self.mockView.refreshView.transform = CGAffineTransformMakeScale(self.cgAffineTransformMakeScale, self.cgAffineTransformMakeScale);
        
        
        
        //进入房间动画以后开始显示顶部活动图片和消息名字
        
        if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
            self.navtitleLabel.text = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"name"];
        }
        else
        {
            for (NSInteger i = 0; i < [(NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
                if ([userInfomationData.QRRoomId isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                    
                    self.navtitleLabel.text = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"name"];
                }
            }
            
        }
        
        self.micTopImageView.alpha = 1;
        self.micShieldButton.alpha = 1;
        self.micPlayerStatesImageView.alpha = 1;
        for (NSInteger i = 0; i < 20; i++) {
            UILabel *find_nameLabel = (UILabel *)[self.mockView.micBottomImageView viewWithTag:nameLabelTag+i];
            find_nameLabel.alpha = 1;
        }
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.mockView.micBottomImageView.bounds;
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.0].CGColor,(__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 0.1);
        [self.mockView.micBottomImageView.layer setMask:gradientLayer];
        self.view.userInteractionEnabled = YES;
        userInfomationData.mockViewNameLabelIsHiddenStr = @"yes";
        [self.mockView.tableView reloadData];
    } completion:^(BOOL finished) {
        [self.mockView.lastBgView setHidden:YES];
    }];
}

//在聊天室切换

- (void)exchangeChatRoom
{
    //切换聊天室时，取消屏蔽
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isSelectShield"];
    [self.micShieldButton setImage:[UIImage imageNamed:@"people.png"] forState:UIControlStateNormal];
    self.soundingRecoringButton.userInteractionEnabled = YES;
    self.soundingRecoringVoiceButton.userInteractionEnabled = YES;
    //每次进入聊天室页面检查麦克风权限是否开启
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    NSLog(@"*-*-*--*hahhah--- %ld",(long)authStatus);
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.mockViewNameLabelIsHiddenStr = @"yes";
    if ((authStatus ==AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)) {
        [self.soundingRecoringImageView setHidden:NO];
    }
    else
    {
        [self.soundingRecoringImageView setHidden:YES];
    }
    userInfomationData.micMockListPageIndex = 1; //每次重新进入聊天室，当前分页置为0
    [userInfomationData.recordAudio stopPlay];
    [self.hFlowView setHidden:YES];
    NSMutableArray *monthMutableArr = [[NSMutableArray alloc] initWithObjects:@"JAN",@"FEB",@"MAR",@"APR",@"MAY",@"JUN",@"JUL",@"AUG",@"SEP",@"OCT",@"NOV",@"DEC", nil];
    NSString *currentDateStr = [self getLocalDateFormateUTCDate:[[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"schedules"] objectAtIndex:0] objectForKey:@"begin_time_utc"]];
    NSString *monthStr = [monthMutableArr objectAtIndex:[[currentDateStr substringWithRange:NSMakeRange(5,2)] integerValue]-1];
    NSString *dayStr = [currentDateStr substringWithRange:NSMakeRange(8,2)];
    
    [self.mockView.topImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",self.mockView.topImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
    self.mockView.monthLabel.text = monthStr;
    self.mockView.dayLabel.text = dayStr;
    self.mockView.eventNameLabel.text = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"name"];
    
    [self.micTopImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",self.micTopImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
    self.navtitleLabel.text = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"name"];
    userInfomationData.isEnterMicList = @"true";
    self.mockView.alpha = 1;
    self.hFlowView.alpha = 0;
    
    //消除活动列表后面未读消息的小红掉标记
    userInfomationData.currtentRoomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@%@",@"red",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]]];
}

////UTC时间转换 成对应系统时间
-(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSLog(@"UTC=========%@",utcDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    NSLog(@"UTC=========%@",dateString);
    return dateString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
