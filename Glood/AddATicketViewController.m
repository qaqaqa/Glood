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
    
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*110/320))/2,SCREEN_HEIGHT*55/568, SCREEN_WIDTH*138/320, SCREEN_HEIGHT*123/568)];
    [topImageView setImage:[UIImage imageNamed:@"feedbackeys.png"]];
    [self.view addSubview:topImageView];
    
    UILabel *oopsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, topImageView.frame.size.height+topImageView.frame.origin.y+(SCREEN_HEIGHT*13/568), SCREEN_WIDTH, 35)];
    oopsLabel.backgroundColor = [UIColor clearColor];
    oopsLabel.textAlignment = NSTextAlignmentCenter;
    oopsLabel.text = @"Oops!";
    oopsLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:24];
    [self.view addSubview:oopsLabel];
    
    NSString *tipsOneStr = @"Looks like we can't find any\n ticket under your email";
    UILabel *tipsOneLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*200/320))/2, oopsLabel.frame.size.height+oopsLabel.frame.origin.y+10, SCREEN_WIDTH*240/320, 46)];
    tipsOneLabel.backgroundColor = [UIColor clearColor];
    tipsOneLabel.textAlignment = NSTextAlignmentCenter;
    tipsOneLabel.numberOfLines = 2;
    tipsOneLabel.text = tipsOneStr;
    tipsOneLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:SCREEN_WIDTH*18/320];
    [self.view addSubview:tipsOneLabel];
    
    //设置行间距
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:tipsOneStr];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:6];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [tipsOneStr length])];
    [tipsOneLabel setAttributedText:attributedString1];
    [tipsOneLabel sizeToFit];
    tipsOneLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsOneLabel];
    
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    UILabel *tipsTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tipsOneLabel.frame.size.height+tipsOneLabel.frame.origin.y+4, SCREEN_WIDTH, 20)];
    tipsTwoLabel.backgroundColor = [UIColor clearColor];
    tipsTwoLabel.textAlignment = NSTextAlignmentCenter;
    tipsTwoLabel.text = [userInfomationData.userDic objectForKey:@"email_address"];
    tipsTwoLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:SCREEN_WIDTH*18/320];
    [self.view addSubview:tipsTwoLabel];
    
    NSString *tipsThreeStr = @"Please add tickets and join\ncommunities by scanning the QR\ncode on the ticket you received\nin your email.";
    UILabel *tipsThreeLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*250/320))/2, tipsTwoLabel.frame.size.height+tipsTwoLabel.frame.origin.y+4, SCREEN_WIDTH*280/320, 92)];
    tipsThreeLabel.backgroundColor = [UIColor clearColor];
    tipsThreeLabel.textAlignment = NSTextAlignmentCenter;
    tipsThreeLabel.numberOfLines = 4;
    tipsThreeLabel.text = tipsThreeStr;
    tipsThreeLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:SCREEN_WIDTH*18/320];
    [self.view addSubview:tipsThreeLabel];
    
    //设置行间距
    NSMutableAttributedString * attributedString2 = [[NSMutableAttributedString alloc] initWithString:tipsThreeStr];
    NSMutableParagraphStyle * paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle2 setLineSpacing:6];
    [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [tipsThreeStr length])];
    [tipsThreeLabel setAttributedText:attributedString2];
    [tipsThreeLabel sizeToFit];
    tipsThreeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsThreeLabel];
    
    UIButton *addTicketButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-49, SCREEN_WIDTH, 49)];
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
