//
//  SettingsViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/10.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "SettingsViewController.h"
#import "CommonNavView.h"
#import "Define.h"
#import "CeHuaView.h"
#import "FeedbackViewController.h"
#import "EventViewController.h"
#import "JTMaterialSwitch.h"
#import "UserInfomationData.h"
#import "ViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface SettingsViewController ()

@property (retain, nonatomic) UIView *cehuaView;
@property (retain, nonatomic) JTMaterialSwitch *jtSwitch;;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:bgImageView];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*10/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*34/320, SCREEN_HEIGHT*36/568)];
    [leftButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(onLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    
    UIButton *largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
    [largeLeftButton addTarget:self action:@selector(onLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    largeLeftButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:largeLeftButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*80/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*160/320, SCREEN_HEIGHT*36/568)];
    titleLabel.text = @"Settings";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = [UIColor blackColor];
    [self.view addSubview:titleLabel];
    
    UILabel *notificationTitleLabel = [[UILabel alloc] init];
    notificationTitleLabel.frame = CGRectMake(leftButton.frame.size.height+leftButton.frame.origin.x-20, 64, SCREEN_WIDTH*220/320, 35);
    notificationTitleLabel.text = @"Conversation Notification";
    notificationTitleLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:notificationTitleLabel];
    
    self.jtSwitch = [[JTMaterialSwitch alloc] initWithSize:JTMaterialSwitchSizeNormal
                                                style:JTMaterialSwitchStyleLight
                                                state:JTMaterialSwitchStateOn];
    self.jtSwitch.center = CGPointMake(SCREEN_WIDTH-50-10, notificationTitleLabel.frame.origin.y+20);
    [self.jtSwitch addTarget:self action:@selector(stateChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.jtSwitch];
    
    UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
    [logoutButton setTitle:@"logout" forState:UIControlStateNormal];
    logoutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    logoutButton.backgroundColor = [UIColor colorWithRed:72/255.0 green:164/255.0 blue:233/255.0 alpha:1];
    [logoutButton addTarget:self action:@selector(onlogoutBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButton];

}

- (void)onlogoutBtnClick:(id)sender
{
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    UserInfomationData * userInfomationData = [UserInfomationData shareInstance];
    [userInfomationData.timer invalidate];
    [userInfomationData.hubConnection stop];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Exchange_OAUTH2_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:FACEBOOK_OAUTH2_USERID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:FACEBOOK_OAUTH2_TOKEN];
    userInfomationData.pushEventVCTypeStr = @"";
    userInfomationData.QRRoomId = @"";
//    [userInfomationData.viewVC cleanCacheAndCookie];
    ViewController *viewVC = [[ViewController alloc] init];
    [viewVC cleanCacheAndCookie];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)stateChanged
{
    if(self.jtSwitch.isOn == YES) {
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        if (notification!=nil) {//判断系统是否支持本地通知
            notification.fireDate = [NSDate dateWithTimeIntervalSince1970:18*60*60*24];//本次开启立即执行的周期
            notification.repeatInterval=kCFCalendarUnitWeekday;//循环通知的周期
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.alertBody=@"you have a new message!";//弹出的提示信息
            notification.applicationIconBadgeNumber=0; //应用程序的右上角小数字
            notification.soundName= UILocalNotificationDefaultSoundName;//本地化通知的声音
            notification.hasAction = NO;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"打开消息通知" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"关闭消消息通知将不在收到任何推送" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark ==========侧滑菜单栏=========
- (void)onCeHuaMoreBtnClick
{
    [UIView animateWithDuration:0.5 animations:^{
        self.cehuaView.frame = CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark ========== left more button ========
- (void)onLeftBtnClick
{
    NSLog(@"left");
    //侧滑菜单栏
    [self.cehuaView removeFromSuperview];
    self.cehuaView = [[UIView alloc] initWithFrame:CGRectMake(-SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.cehuaView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.cehuaView];
    
    CeHuaView *ceHuav = [[CeHuaView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.cehuaView addSubview:ceHuav];
    
    UIButton *ceHuaMoreButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*34/320)-50, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*34/320, SCREEN_HEIGHT*36/568)];
    [ceHuaMoreButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [ceHuaMoreButton addTarget:self action:@selector(onCeHuaMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.cehuaView addSubview:ceHuaMoreButton];
    
    UIButton *largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*34/320)-40, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
    [largeLeftButton addTarget:self action:@selector(onCeHuaMoreBtnClick) forControlEvents:UIControlEventTouchUpInside];
    largeLeftButton.backgroundColor = [UIColor clearColor];
    [self.cehuaView addSubview:largeLeftButton];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.cehuaView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onMing" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onFeedback" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onSetting" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onMing)name:@"onMing"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onFeedbak)name:@"onFeedback"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onSetting)name:@"onSetting"object:nil];
}

- (void)onMing
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.refreshCount = -1;
    userInfomationData.pushEventVCTypeStr = @"NOQR";
    EventViewController *eventVC = [[EventViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:eventVC animated:YES];
}

- (void)onFeedbak
{
    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:feedbackVC animated:YES];
}

- (void)onSetting
{
    [self onCeHuaMoreBtnClick];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
