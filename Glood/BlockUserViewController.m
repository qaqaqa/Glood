//
//  BlockUserViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/2/20.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import "BlockUserViewController.h"
#import "Define.h"
#import "UserInfomationData.h"
#import "CommonService.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface BlockUserViewController ()

@end

@implementation BlockUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.bgView.backgroundColor = [UIColor clearColor];
    [self.bgView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:self.bgView];
    
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*5/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*48/320, SCREEN_HEIGHT*45/568)];
    [self.leftButton setImage:[UIImage imageNamed:@"backqr.png"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(onLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftButton];
    
    UIButton *largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
    [largeLeftButton addTarget:self action:@selector(onLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    largeLeftButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:largeLeftButton];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*60/320, SCREEN_HEIGHT*12/568, SCREEN_WIDTH*200/320, SCREEN_HEIGHT*36/568)];
    self.titleLabel.text = @"Manage Blocked Users";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
    [self.view addSubview:self.titleLabel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,34+37,SCREEN_WIDTH,SCREEN_HEIGHT-64)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.blockUsersMutableArr = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSInteger i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockUsersList"] count]; i++) {
        [userInfomationData.blockUsersMutableArr addObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"blockUsersList"] objectAtIndex:i]];
    }
    
    self.shieldBgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.shieldBgButton.backgroundColor =[UIColor clearColor];
    [self.shieldBgButton addTarget:self action:@selector(onCancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.shieldBgButton.alpha = 0;
    [self.view addSubview:self.shieldBgButton];
    
    self.shieldbgView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*240/320))/2, (SCREEN_HEIGHT-(SCREEN_HEIGHT*214/568))/2, SCREEN_WIDTH*240/320, SCREEN_HEIGHT*183/568)];
    self.shieldbgView.backgroundColor = [UIColor whiteColor];
    self.shieldbgView.layer.cornerRadius = 8;
    self.shieldbgView.layer.masksToBounds = YES;
    [self.shieldBgButton addSubview:self.shieldbgView];
    
    self.shieldHeadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*56/320))/2, (SCREEN_HEIGHT-(SCREEN_HEIGHT*250/568))/2, SCREEN_WIDTH*56/320, SCREEN_WIDTH*56/320)];
    self.shieldHeadImageView.layer.cornerRadius = self.shieldHeadImageView.frame.size.width/2;
    self.shieldHeadImageView.layer.masksToBounds = YES;
    [self.shieldBgButton addSubview:self.shieldHeadImageView];
    
    UILabel *shieldBeforeLabel = [[UILabel alloc] init];
    shieldBeforeLabel.frame = CGRectMake(SCREEN_WIDTH*25/320, SCREEN_HEIGHT*52/568, SCREEN_WIDTH*190/320, SCREEN_HEIGHT*30/568);
    shieldBeforeLabel.text = @"Sure you want to unblock";
    shieldBeforeLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:SCREEN_WIDTH*17/320];
    [self.shieldbgView addSubview:shieldBeforeLabel];
    
    self.shieldTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*25/320, SCREEN_HEIGHT*82/568, SCREEN_WIDTH*190/320, SCREEN_HEIGHT*30/568)];
    self.shieldTipLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:SCREEN_WIDTH*17/320];
    [self.shieldbgView addSubview:self.shieldTipLabel];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.shieldbgView.frame.size.height-(SCREEN_HEIGHT*45/568), SCREEN_WIDTH*119.5/320, SCREEN_HEIGHT*45/568)];
    cancelButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:143/255.0 blue:255/255.0 alpha:1];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"Nope" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:24];
    [cancelButton addTarget:self action:@selector(onCancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.shieldbgView addSubview:cancelButton];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(cancelButton.frame.origin.x+cancelButton.frame.size.width+1, cancelButton.frame.origin.y, SCREEN_WIDTH*119.5/320, SCREEN_HEIGHT*45/568)];
    okButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:143/255.0 blue:255/255.0 alpha:1];
    [okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okButton setTitle:@"Yup" forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:24];
    [okButton addTarget:self action:@selector(onYesBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.shieldbgView addSubview:okButton];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    return [userInfomationData.blockUsersMutableArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT*68/568;
}

#define headImageButtonTag 10001
#define nameLabelTag 20001
#define cancleBlockUserButttonTag 30001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.blockUsersTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"BlockUsersTableViewCell"];
    if (self.blockUsersTableViewCell == nil)
    {
        self.blockUsersTableViewCell = [[BlockUsersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BlockUsersTableViewCell" index:indexPath.row];
        [self.blockUsersTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    self.blockUsersTableViewCell.headImageButton.frame = CGRectMake(20, SCREEN_HEIGHT*10/568, SCREEN_HEIGHT*42/568, SCREEN_HEIGHT*42/568);
    self.blockUsersTableViewCell.headImageButton.tag = headImageButtonTag+indexPath.row;
    self.blockUsersTableViewCell.headImageButton.layer.masksToBounds = YES;
    self.blockUsersTableViewCell.headImageButton.layer.cornerRadius = self.blockUsersTableViewCell.headImageButton.frame.size.width/2;
    [self.blockUsersTableViewCell.headImageButton sd_setImageWithURL:[[userInfomationData.blockUsersMutableArr objectAtIndex:indexPath.row] objectForKey:@"avatar"] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"171604419.jpg"]];
    [self.blockUsersTableViewCell.headImageButton addTarget:self action:@selector(onCancleBlockUser:) forControlEvents:UIControlEventTouchUpInside];
    
    self.blockUsersTableViewCell.nameLabel.frame = CGRectMake(self.blockUsersTableViewCell.headImageButton.frame.origin.x+self.blockUsersTableViewCell.headImageButton.frame.size.width+20, 0, SCREEN_HEIGHT*200/568, SCREEN_HEIGHT*50/568);
    self.blockUsersTableViewCell.nameLabel.tag = nameLabelTag+indexPath.row;
    self.blockUsersTableViewCell.nameLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:15];
//    self.blockUsersTableViewCell.nameLabel.text = [[userInfomationData.blockUsersMutableArr objectAtIndex:indexPath.row] objectForKey:@"user_name"];
    self.blockUsersTableViewCell.nameLabel.text =  [NSString stringWithFormat:@"%@%@.",[[userInfomationData.blockUsersMutableArr objectAtIndex:indexPath.row] objectForKey:@"name"],[[[userInfomationData.blockUsersMutableArr objectAtIndex:indexPath.row] objectForKey:@"surname"] substringToIndex:1]];
    
//    self.blockUsersTableViewCell.cancleBlockButton.frame  =  CGRectMake(SCREEN_WIDTH-10-(SCREEN_HEIGHT*60/568), SCREEN_HEIGHT*10/568, SCREEN_HEIGHT*60/568, SCREEN_HEIGHT*30/568);
//    self.blockUsersTableViewCell.cancleBlockButton.tag = cancleBlockUserButttonTag+indexPath.row;
//    [self.blockUsersTableViewCell.cancleBlockButton addTarget:self action:@selector(onCancleBlockUser:) forControlEvents:UIControlEventTouchUpInside];
    
    return self.blockUsersTableViewCell;
}

- (void)onCancleBlockUser:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"取消屏蔽:%ld",button.tag-headImageButtonTag);
    [self showViewCanelBlock:button.tag-headImageButtonTag];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"取消屏蔽:%ld",(long)indexPath.row);
    [self showViewCanelBlock:indexPath.row];
}

- (void)onCancelBtnClick
{
    [self hiddenShieldView];
}

- (void)hiddenShieldView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.shieldBgButton.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)onYesBtnClick:(id)sender
{
    [self cancelBlock:self.indexRow];
}

- (void)showViewCanelBlock:(NSInteger )indexRow
{
    self.indexRow = indexRow;
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    [UIView animateWithDuration:0.5 animations:^{
        self.shieldBgButton.alpha = 1.0;
        [self.shieldHeadImageView sd_setImageWithURL:[[userInfomationData.blockUsersMutableArr objectAtIndex:indexRow] objectForKey:@"avatar"] placeholderImage:[UIImage imageNamed:@"171604419.jpg"]];
        self.shieldTipLabel.text = [NSString stringWithFormat:@"%@%@.?",[[userInfomationData.blockUsersMutableArr objectAtIndex:indexRow] objectForKey:@"name"],[[[userInfomationData.blockUsersMutableArr objectAtIndex:indexRow] objectForKey:@"surname"] substringToIndex:1]];
        
    } completion:^(BOOL finished) {
    }];
}

- (void)cancelBlock:(NSInteger )indexRow
{
    [self hiddenShieldView];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    [userInfomationData.commonService cancelBlockUser:[NSString stringWithFormat:@"%@",[[userInfomationData.blockUsersMutableArr objectAtIndex:indexRow] objectForKey:@"id"]]];
    [userInfomationData.blockUsersMutableArr removeObjectAtIndex:indexRow];
    [[NSUserDefaults standardUserDefaults] setObject:userInfomationData.blockUsersMutableArr forKey:@"blockUsersList"];
    [self.tableView reloadData];
}

- (void)onLeftBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
