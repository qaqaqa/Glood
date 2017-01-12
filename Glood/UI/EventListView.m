//
//  EventListView.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/8.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "EventListView.h"
#import "Define.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserInfomationData.h"
#import "CommonClass.h"

@implementation EventListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self.bgView setImage:[UIImage imageNamed:@"bg"]];
        [self addSubview:self.bgView];
        
        self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*17/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*34/320, SCREEN_HEIGHT*36/568)];
        [self.leftButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(onLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftButton];
        
        UIButton *largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
        [largeLeftButton addTarget:self action:@selector(onLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        largeLeftButton.backgroundColor = [UIColor clearColor];
        [self addSubview:largeLeftButton];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*60/320, SCREEN_HEIGHT*12/568, SCREEN_WIDTH*200/320, SCREEN_HEIGHT*36/568)];
        self.titleLabel.text = @"Sparxo Grand Celebration";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:17];
        [self addSubview:self.titleLabel];
        
        self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*54/320), SCREEN_HEIGHT*16/568, SCREEN_WIDTH*28/320, SCREEN_HEIGHT*28/568)];
        [self.rightButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(onRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightButton];
        
        UIView *tableviewBgView = [[UIView alloc] initWithFrame:CGRectMake(0,34+30,SCREEN_WIDTH,SCREEN_HEIGHT-64)];
        tableviewBgView.backgroundColor = [UIColor whiteColor];
        tableviewBgView.alpha = 0.4;
        [self addSubview:tableviewBgView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,34+30,SCREEN_WIDTH,SCREEN_HEIGHT-64)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
        
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#define eventImageViewTag 10001
#define eventNameLabelTag 20001
#define redImageViewTag 30001
#define lineImageViewTag 40001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.eventListTabelViewCell = [tableView dequeueReusableCellWithIdentifier:@"EventListTableViewCell"];
    if (self.eventListTabelViewCell == nil)
    {
        self.eventListTabelViewCell = [[EventListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EventListTableViewCell" index:indexPath.row];
//        [self.eventListTabelViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    
    if (indexPath.row == 0) {
        self.eventListTabelViewCell.eventImageView.frame = CGRectMake((105-22)/2, (49-22)/2, 22, 22);
        [self.eventListTabelViewCell.eventImageView setImage:[UIImage imageNamed:@"add.png"]];
        self.eventListTabelViewCell.eventNameLabel.frame = CGRectMake(105+20, 0, SCREEN_WIDTH*170/320, 49);
        self.eventListTabelViewCell.eventNameLabel.text = @"Add new community";
        self.eventListTabelViewCell.eventNameLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:17];
        self.eventListTabelViewCell.redImageView.frame = CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*10/320)-5, (49-10)/2, 0, 0);
    }
    else{
        self.eventListTabelViewCell.eventImageView.frame = CGRectMake(0, 0, 105, 49);
        [self.eventListTabelViewCell.eventImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:indexPath.row-1] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:indexPath.row-1] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:indexPath.row-1] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:indexPath.row-1] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:indexPath.row-1] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",self.eventListTabelViewCell.eventImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
        self.eventListTabelViewCell.eventNameLabel.frame = CGRectMake(105+20, 0, SCREEN_WIDTH*150/320, self.eventListTabelViewCell.eventImageView.frame.size.height);
        self.eventListTabelViewCell.eventNameLabel.text = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:indexPath.row-1] objectForKey:@"name"];
        self.eventListTabelViewCell.eventNameLabel.font = [UIFont fontWithName:@"ProximaNova-Light" size:17];
        self.eventListTabelViewCell.redImageView.frame = CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*10/320)-15, (49-10)/2, SCREEN_WIDTH*10/320, SCREEN_WIDTH*10/320);
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",@"red",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:indexPath.row-1] objectForKey:@"id"]]] integerValue] == 1) {
            [self.eventListTabelViewCell.redImageView setHidden:NO];
        }
        else{
            [self.eventListTabelViewCell.redImageView setHidden:YES];
        }
    }
    self.eventListTabelViewCell.eventImageView.tag = eventImageViewTag+indexPath.row;
    
    self.eventListTabelViewCell.eventNameLabel.tag = eventNameLabelTag+indexPath.row;
    
    
    self.eventListTabelViewCell.redImageView.layer.cornerRadius = self.eventListTabelViewCell.redImageView.frame.size.width/2;
    self.eventListTabelViewCell.redImageView.layer.masksToBounds = YES;
    self.eventListTabelViewCell.redImageView.tag = redImageViewTag+indexPath.row;
    
    
    self.eventListTabelViewCell.lineImageView.frame = CGRectMake(0, 49, SCREEN_WIDTH, 1);
    self.eventListTabelViewCell.lineImageView.tag = lineImageViewTag+indexPath.row;
    return self.eventListTabelViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    if (indexPath.row == 0) {
        NSLog(@"add");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addQr" object:self];
    }
    else{
        userInfomationData.QRRoomId = @"";
        NSLog(@"mic");
        if (self.delegate && [self.delegate conformsToProtocol:@protocol(eventListViewDelegate)]) {
            [self.delegate eventListJoinRoom:indexPath.row];
        }
    }
}

#pragma mark ========== left more button ========
- (void)onLeftBtnClick:(id)sender
{
    NSLog(@"left");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onLeftBtnClick" object:self];
}

#pragma mark ========== right eventlist button ========
- (void)onRightBtnClick:(id)sender
{
    NSLog(@"rigth");
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.pushEventVCTypeStr = @"QR";
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
