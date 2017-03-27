//
//  LikeView.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/3/13.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import "LikeView.h"
#import "Define.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "UserInfomationData.h"
#import "CommonClass.h"
#import "CommonService.h"

@implementation LikeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(belike)name:@"belike"object:nil];
        
        self.bgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.bgButton.backgroundColor = [UIColor clearColor];
        [self.bgButton addTarget:self action:@selector(onHiddenView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bgButton];
        
        self.whiteBgView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*230/320))/2, SCREEN_HEIGHT*170/568, SCREEN_WIDTH*230/320, SCREEN_HEIGHT*355/568)];
        self.whiteBgView.backgroundColor = [UIColor whiteColor];
        self.whiteBgView.layer.masksToBounds = YES;
        self.whiteBgView.layer.cornerRadius = 8;
        [self addSubview:self.whiteBgView];
        
        self.topHeartImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*60/320))/2, SCREEN_HEIGHT*140/568+3, SCREEN_WIDTH*60/320, SCREEN_WIDTH*60/320)];
        [self.topHeartImageView setImage:[UIImage imageNamed:@"popup_heart"]];
        [self addSubview:self.topHeartImageView];
        
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        self.heartCountLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.whiteBgView.frame.size.width-(SCREEN_WIDTH*230/320))/2, 25, SCREEN_WIDTH*230/320, SCREEN_HEIGHT*50/568)];
        self.heartCountLabel.text = [NSString stringWithFormat:@"%@",userInfomationData.getUsersLikesCountInRoom];
        self.heartCountLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:30];
        self.heartCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.whiteBgView addSubview:self.heartCountLabel];
        
        self.heartsFromLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.whiteBgView.frame.size.width-(SCREEN_WIDTH*230/320))/2, self.heartCountLabel.frame.size.height+self.heartCountLabel.frame.origin.y-10, SCREEN_WIDTH*230/320, SCREEN_HEIGHT*30/568)];
        self.heartsFromLabel.textAlignment = NSTextAlignmentCenter;
        self.heartsFromLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];
        self.heartsFromLabel.text = @"hearts from";
        [self.whiteBgView addSubview:self.heartsFromLabel];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,90,self.whiteBgView.frame.size.width,self.whiteBgView.frame.size.height-90)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.whiteBgView addSubview:self.tableView];
        
        self.noResultLabel = [[UILabel alloc] init];
        self.noResultLabel.frame = CGRectMake(0,90,self.whiteBgView.frame.size.width,self.whiteBgView.frame.size.height-90);
//        self.noResultLabel.text = @"No one likes you!";
        self.noResultLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:18];
        self.noResultLabel.textAlignment = NSTextAlignmentCenter;
        [self.whiteBgView addSubview:self.noResultLabel];
        
        [self setupFooter];
        
    }
    return self;
}

- (void)belike
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    if ([CommonService isBlankString:userInfomationData.getUsersLikesCountInRoom]) {
        self.heartCountLabel.text = @"0";
    }
    else
    {
        self.heartCountLabel.text = [NSString stringWithFormat:@"%@",userInfomationData.getUsersLikesCountInRoom];
    }
    
}

- (void)setupFooter
{
    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
    refreshFooter.isEffectedByNavigationController = NO;
    [refreshFooter addToScrollView:self.tableView];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    _refreshFooter = refreshFooter;
}


- (void)footerRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.commonService getUserLikesInRoom:userInfomationData.getUsersLikesInRoomId lastLikeId:[NSString stringWithFormat:@"%@",[[userInfomationData.getUsersLikesInRoomMutableArr objectAtIndex:([userInfomationData.getUsersLikesInRoomMutableArr count]-1)] objectForKey:@"id"]] count:@"10"];
        [self.tableView reloadData];
        [self.refreshFooter endRefreshing];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    if ([userInfomationData.getUsersLikesInRoomMutableArr count] > 0) {
        [self.noResultLabel setHidden:YES];
    }
    else
    {
        [self.noResultLabel setHidden:NO];
    }
    return [userInfomationData.getUsersLikesInRoomMutableArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT*65/568;
}

#define headImageButtonTag 10001
#define nameLabelTag 20001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.likeTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"LikeTableViewCell"];
    if (self.likeTableViewCell == nil)
    {
        self.likeTableViewCell = [[LikeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LikeTableViewCell" index:indexPath.row];
        [self.likeTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    self.likeTableViewCell.headImageButton.frame = CGRectMake(20, SCREEN_HEIGHT*10/568, SCREEN_HEIGHT*50/568, SCREEN_HEIGHT*50/568);
    self.likeTableViewCell.headImageButton.tag = headImageButtonTag+indexPath.row;
    self.likeTableViewCell.headImageButton.layer.masksToBounds = YES;
    self.likeTableViewCell.headImageButton.layer.cornerRadius = self.likeTableViewCell.headImageButton.frame.size.width/2;
    [self.likeTableViewCell.headImageButton sd_setImageWithURL:[[userInfomationData.getUsersLikesInRoomMutableArr objectAtIndex:indexPath.row] objectForKey:@"avatar"] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"171604419.jpg"]];
    
    self.likeTableViewCell.nameLabel.frame = CGRectMake(self.likeTableViewCell.headImageButton.frame.origin.x+self.likeTableViewCell.headImageButton.frame.size.width+20, 3, SCREEN_HEIGHT*200/568, SCREEN_HEIGHT*50/568);
    self.likeTableViewCell.nameLabel.tag = nameLabelTag+indexPath.row;
    self.likeTableViewCell.nameLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
    self.likeTableViewCell.nameLabel.text =  [NSString stringWithFormat:@"%@ %@.",[[userInfomationData.getUsersLikesInRoomMutableArr objectAtIndex:indexPath.row] objectForKey:@"name"],[[[userInfomationData.getUsersLikesInRoomMutableArr objectAtIndex:indexPath.row] objectForKey:@"surname"] substringToIndex:1].uppercaseString];
    
    return self.likeTableViewCell;
}

- (void)onHiddenView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"belike" object:nil];
    [self removeFromSuperview];
}

@end
