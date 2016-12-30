//
//  AddATicketViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/9.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "AddATicketViewController.h"
#import "Define.h"
#import "QRViewController.h"
#import "UserInfomationData.h"
#import "QRNativeViewController.h"

@interface AddATicketViewController ()

@end

@implementation AddATicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:bgImageView];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*93/320))/2,SCREEN_HEIGHT*60/568, SCREEN_WIDTH*93/320, SCREEN_HEIGHT*113/568)];
    [topImageView setImage:[UIImage imageNamed:@"feedbackeys.png"]];
    [self.view addSubview:topImageView];
    
    UILabel *oopsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topImageView.frame.size.height+topImageView.frame.origin.y+(SCREEN_HEIGHT*30/568), SCREEN_WIDTH, 35)];
    oopsLabel.backgroundColor = [UIColor clearColor];
    oopsLabel.textAlignment = NSTextAlignmentCenter;
    oopsLabel.text = @"Oops!";
    oopsLabel.font = [UIFont boldSystemFontOfSize:22];
    [self.view addSubview:oopsLabel];
    
    UILabel *tipsOneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, oopsLabel.frame.size.height+oopsLabel.frame.origin.y+10, SCREEN_WIDTH, 46)];
    tipsOneLabel.backgroundColor = [UIColor clearColor];
    tipsOneLabel.textAlignment = NSTextAlignmentCenter;
    tipsOneLabel.numberOfLines = 2;
    tipsOneLabel.text = @"Looks like we can't find any\n ticket under your email";
    tipsOneLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:tipsOneLabel];
    
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    UILabel *tipsTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tipsOneLabel.frame.size.height+tipsOneLabel.frame.origin.y, SCREEN_WIDTH, 20)];
    tipsTwoLabel.backgroundColor = [UIColor clearColor];
    tipsTwoLabel.textAlignment = NSTextAlignmentCenter;
    tipsTwoLabel.text = [userInfomationData.userDic objectForKey:@"email_address"];
    tipsTwoLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:tipsTwoLabel];
    
    UILabel *tipsThreeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tipsTwoLabel.frame.size.height+tipsTwoLabel.frame.origin.y, SCREEN_WIDTH, 92)];
    tipsThreeLabel.backgroundColor = [UIColor clearColor];
    tipsThreeLabel.textAlignment = NSTextAlignmentCenter;
    tipsThreeLabel.numberOfLines = 4;
    tipsThreeLabel.text = @"Please add tickets and join\ncommunities by scanning the QR\ncode on the ticket you received\nin your email.";
    tipsThreeLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:tipsThreeLabel];
    
    UIButton *addTicketButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-58, SCREEN_WIDTH, 58)];
    [addTicketButton setImage:[UIImage imageNamed:@"addTicketBtn.jpeg"] forState:UIControlStateNormal];
    [addTicketButton addTarget:self action:@selector(onAddTicket:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addTicketButton];
}

- (void)onAddTicket:(id)sender
{
    QRNativeViewController *qrVC = [[QRNativeViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:qrVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
