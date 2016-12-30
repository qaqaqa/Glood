//
//  FeedbackViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/10.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "FeedbackViewController.h"
#import "Define.h"
#import "CeHuaView.h"
#import "SettingsViewController.h"
#import "EventViewController.h"
#import "ShowMessage.h"
#import "UserInfomationData.h"

@interface FeedbackViewController ()

@property (retain, nonatomic) UIView *cehuaView;
@property (retain, nonatomic) UIView *bgView;
@property (retain, nonatomic) UITextView *feedbackTextView;

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:bgImageView];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bgView];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*10/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*34/320, SCREEN_HEIGHT*36/568)];
    [leftButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(onLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:leftButton];
    
    UIButton *largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
    [largeLeftButton addTarget:self action:@selector(onLeftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    largeLeftButton.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:largeLeftButton];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*93/320))/2,SCREEN_HEIGHT*60/568, SCREEN_WIDTH*133/320, SCREEN_HEIGHT*113/568)];
    [topImageView setImage:[UIImage imageNamed:@"feedbackeys.png"]];
    [self.bgView addSubview:topImageView];
    
    NSString *tipsStr = @"If you have some good idea that you think will improve our community experience,please share them!";
    CGSize tipsSize = [tipsStr sizeWithFont:[UIFont systemFontOfSize:SCREEN_WIDTH*18/320] constrainedToSize:CGSizeMake(SCREEN_WIDTH*220/320, 100) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*280/320))/2, topImageView.frame.size.height+topImageView.frame.origin.y+(SCREEN_HEIGHT*30/568), SCREEN_WIDTH*280/320, tipsSize.height)];
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.numberOfLines = 0;
    tipsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipsLabel.text = tipsStr;
    tipsLabel.font = [UIFont systemFontOfSize:SCREEN_WIDTH*18/320];
    [self.bgView addSubview:tipsLabel];
    
    self.feedbackTextView = [[UITextView alloc] initWithFrame:CGRectMake(tipsLabel.frame.origin.x, tipsLabel.frame.origin.y+tipsLabel.frame.size.height+10, SCREEN_WIDTH*280/320, SCREEN_HEIGHT*175/568)];
    self.feedbackTextView.delegate = self;
    self.feedbackTextView.backgroundColor = [UIColor whiteColor];
    self.feedbackTextView.layer.cornerRadius = 8;
    self.feedbackTextView.layer.masksToBounds = YES;
    self.feedbackTextView.keyboardType = UIKeyboardTypeDefault;
    self.feedbackTextView.returnKeyType = UIReturnKeySend;
    [self.bgView addSubview:self.feedbackTextView];
        
    UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutButton.titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
    [logoutButton setTitle:@"send" forState:UIControlStateNormal];
    logoutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    logoutButton.backgroundColor = [UIColor colorWithRed:72/255.0 green:164/255.0 blue:233/255.0 alpha:1];
    [logoutButton addTarget:self action:@selector(onSendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:logoutButton];
}

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    [UIView animateWithDuration:0.5 animations:^{
        self.bgView.frame = CGRectMake(0, -(SCREEN_HEIGHT*(216+36)/568), SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
    }];
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [UIView animateWithDuration:0.5 animations:^{
            self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        } completion:^(BOOL finished) {
            
            if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0)
            {
                //发送feedback
            }
            else
            {
                [ShowMessage showMessage:@"发送内容为空"];
            }
            
        }];
        return NO;
    }
    return YES;
}

-(void)onSendBtnClick:(id)sender
{
    NSLog(@"send feeedback");
    [self.feedbackTextView resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        
        if ([self.feedbackTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0)
        {
            //发送feedback
            UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
            [userInfomationData.commonService sendFeedback:self.feedbackTextView.text];
        }
        else
        {
            [ShowMessage showMessage:@"发送内容为空"];
        }
        
    }];
}

- (void)sendFeedbackScu
{
    self.feedbackTextView.text = @"";
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onSetting" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onFeedback" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendFeedbackScu" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onMing)name:@"onMing"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onSetting)name:@"onSetting"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(onFeedback)name:@"onFeedback"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(sendFeedbackScu)name:@"sendFeedbackScu"object:nil];
}

- (void)onMing
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.pushEventVCTypeStr = @"NOQR";
    EventViewController *eventVC = [[EventViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:eventVC animated:YES];
}

- (void)onSetting
{
    SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)onFeedback
{
    [self onCeHuaMoreBtnClick];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
