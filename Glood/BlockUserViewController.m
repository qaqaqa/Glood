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

@interface BlockUserViewController ()

@end

@implementation BlockUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.bgView.backgroundColor = [UIColor clearColor];
    [self.bgView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:self.bgView];
    
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*17/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*34/320, SCREEN_HEIGHT*36/568)];
    [self.leftButton setImage:[UIImage imageNamed:@"backqr.png"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(onLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.leftButton];
    
    UIButton *largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
    [largeLeftButton addTarget:self action:@selector(onLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    largeLeftButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:largeLeftButton];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*60/320, SCREEN_HEIGHT*12/568, SCREEN_WIDTH*200/320, SCREEN_HEIGHT*36/568)];
    self.titleLabel.text = @"Block Users";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
    [self.view addSubview:self.titleLabel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,34+30,SCREEN_WIDTH,SCREEN_HEIGHT-64)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.tableView];
    
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.blockUsersMutableArr = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSInteger i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockUsersList"] count]; i++) {
        [userInfomationData.blockUsersMutableArr addObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"blockUsersList"] objectAtIndex:i]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    return [userInfomationData.blockUsersMutableArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT*50/568;
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
    self.blockUsersTableViewCell.headImageButton.frame = CGRectMake(10, SCREEN_HEIGHT*5/568, SCREEN_HEIGHT*40/568, SCREEN_HEIGHT*40/568);
    self.blockUsersTableViewCell.headImageButton.tag = headImageButtonTag+indexPath.row;
    self.blockUsersTableViewCell.headImageButton.layer.masksToBounds = YES;
    self.blockUsersTableViewCell.headImageButton.layer.cornerRadius = self.blockUsersTableViewCell.headImageButton.frame.size.width/2;
    [self.blockUsersTableViewCell.headImageButton sd_setImageWithURL:[[userInfomationData.blockUsersMutableArr objectAtIndex:indexPath.row] objectForKey:@"avatar"] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"171604419.jpg"]];
    
    self.blockUsersTableViewCell.nameLabel.frame = CGRectMake(self.blockUsersTableViewCell.headImageButton.frame.origin.x+self.blockUsersTableViewCell.headImageButton.frame.size.width+30, 0, SCREEN_HEIGHT*200/568, SCREEN_HEIGHT*50/568);
    self.blockUsersTableViewCell.nameLabel.tag = nameLabelTag+indexPath.row;
    self.blockUsersTableViewCell.nameLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:15];
    self.blockUsersTableViewCell.nameLabel.text = [[userInfomationData.blockUsersMutableArr objectAtIndex:indexPath.row] objectForKey:@"user_name"];
    
    self.blockUsersTableViewCell.cancleBlockButton.frame  =  CGRectMake(SCREEN_WIDTH-10-(SCREEN_HEIGHT*60/568), SCREEN_HEIGHT*10/568, SCREEN_HEIGHT*60/568, SCREEN_HEIGHT*30/568);
    self.blockUsersTableViewCell.cancleBlockButton.tag = cancleBlockUserButttonTag+indexPath.row;
    [self.blockUsersTableViewCell.cancleBlockButton addTarget:self action:@selector(onCancleBlockUser:) forControlEvents:UIControlEventTouchUpInside];
    
    return self.blockUsersTableViewCell;
}

- (void)onCancleBlockUser:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"取消屏蔽:%ld",button.tag-cancleBlockUserButttonTag);
    [self cancelBlock:button.tag-cancleBlockUserButttonTag];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"取消屏蔽:%ld",(long)indexPath.row);
//    [self cancelBlock:indexPath.row];
}

- (void)cancelBlock:(NSInteger )indexRow
{
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
