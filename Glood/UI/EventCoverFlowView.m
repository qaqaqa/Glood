//
//  EventCoverFlowView.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "EventCoverFlowView.h"
#import "Define.h"
#import "CoverFlowTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "AppDelegate.h"
#import "UserInfomationData.h"
#import "Mic.h"
#import "AppDelegate.h"
#import "MMProgressHUD.h"
#import "CommonClass.h"
#import "CoverFlowAlpahView.h"

@interface EventCoverFlowView()

@property (strong, nonatomic) CoverFlowTableViewCell *micTableViewCell;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) AppDelegate *myAppDelegate;

@end

@implementation EventCoverFlowView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.historyMicListArr = [[NSMutableArray alloc] initWithCapacity:10];
        self.myAppDelegate = [UIApplication sharedApplication].delegate;
        //拉取所有房间的消息
//        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        self.spinner.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height/2, 100, 100);
//        [self addSubview: self.spinner];
//        [self.spinner startAnimating];
        
//        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
//        self.historyMicListArr = [[NSMutableArray alloc] initWithCapacity:10];
//        self.commonService = [[CommonService alloc] init];
//        self.commonService.delegate = self;
//        NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"id"];
//        [self.commonService getMessageInRoom:@"" roomId:roomId];
//        NSLog(@"xxxxxxx------  %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"]);
        
        NSMutableArray *monthMutableArr = [[NSMutableArray alloc] initWithObjects:@"JAN",@"FEB",@"MAR",@"APR",@"MAY",@"JUN",@"JUL",@"AUG",@"SEP",@"OCT",@"NOV",@"DEC", nil];
        NSString *currentDateStr = [self getLocalDateFormateUTCDate:[[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"schedules"] objectAtIndex:0] objectForKey:@"begin_time_utc"]];
        NSString *monthStr = [monthMutableArr objectAtIndex:[[currentDateStr substringWithRange:NSMakeRange(5,2)] integerValue]-1];
        NSString *dayStr = [currentDateStr substringWithRange:NSMakeRange(8,2)];
        
        UIView *bgView = [[UIView alloc] init];
        if (SCREEN_HEIGHT > 568) {
            bgView.frame = CGRectMake(0, -10, SCREEN_WIDTH*260/320, SCREEN_HEIGHT*450/568);
        }
        else{
            bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH*260/320, SCREEN_HEIGHT*450/568);
        }
        
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 5;
        bgView.layer.masksToBounds = YES;
        [self addSubview:bgView];
        
        UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(1.5, 1.5, bgView.frame.size.width-3, SCREEN_HEIGHT*100/568)];
        topBgView.backgroundColor = [UIColor whiteColor];
        topBgView.layer.cornerRadius = 5;
        topBgView.layer.masksToBounds = YES;
        [bgView addSubview:topBgView];
        
        UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width-2, SCREEN_HEIGHT*81/568)];
//        [topImageView sd_setImageWithURL:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"image_url"] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
        [topImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",topImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
        [topBgView addSubview:topImageView];
        
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*15/320, topImageView.frame.size.height+topImageView.frame.origin.y+SCREEN_WIDTH*10/320, SCREEN_WIDTH*40/320, SCREEN_HEIGHT*25/568)];
        monthLabel.textAlignment = NSTextAlignmentLeft;
        monthLabel.text = [NSString stringWithFormat:@"%@",monthStr];
        monthLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:13];
        [bgView addSubview:monthLabel];
        
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(monthLabel.frame.origin.x, monthLabel.frame.size.height+monthLabel.frame.origin.y-5, SCREEN_WIDTH*40/320, SCREEN_HEIGHT*25/568)];
        dayLabel.textAlignment = NSTextAlignmentLeft;
        dayLabel.text = [NSString stringWithFormat:@"%@",dayStr];
        dayLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:22];
        [bgView addSubview:dayLabel];
        
        UILabel *eventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(monthLabel.frame.origin.x+monthLabel.frame.size.width-8, monthLabel.frame.origin.y, SCREEN_WIDTH*220/320, SCREEN_HEIGHT*25/568)];
        eventNameLabel.textAlignment = NSTextAlignmentLeft;
        eventNameLabel.text = [NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"name"]];
        eventNameLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:16];
        [bgView addSubview:eventNameLabel];
        
        self.infoButton = [[UIButton alloc] initWithFrame:CGRectMake(monthLabel.frame.origin.x+2, dayLabel.frame.origin.y+dayLabel.frame.size.height+5, SCREEN_WIDTH*83/320, SCREEN_WIDTH*24/SCREEN_WIDTH)];
        self.infoButton.backgroundColor = [UIColor whiteColor];
        [self.infoButton setTitle:@"info" forState:UIControlStateNormal];
        [self.infoButton setTitleColor:[UIColor colorWithRed:0/255.0 green:130/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.infoButton.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
        self.infoButton.layer.cornerRadius =(SCREEN_WIDTH*24/SCREEN_WIDTH)/2;
        self.infoButton.layer.masksToBounds = YES;
        self.infoButton.layer.borderWidth = 1;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0/255.0, 130/255.0, 255/255.0, 1 });
        [self.infoButton.layer setBorderColor:colorref];
        self.infoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [self.infoButton addTarget:self action:@selector(onInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:self.infoButton];
        
        self.checkInButton = [[UIButton alloc] initWithFrame:CGRectMake(self.infoButton.frame.origin.x+self.infoButton.frame.size.width+15, dayLabel.frame.origin.y+dayLabel.frame.size.height+5, SCREEN_WIDTH*125/320, SCREEN_WIDTH*24/SCREEN_WIDTH)];
        self.checkInButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:130/255.0 blue:255/255.0 alpha:1.0];
        [self.checkInButton setTitle:@"check-in" forState:UIControlStateNormal];
        [self.checkInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.checkInButton.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
        self.checkInButton.layer.cornerRadius =(SCREEN_WIDTH*24/SCREEN_WIDTH)/2;
        self.checkInButton.layer.masksToBounds = YES;
        self.checkInButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [self.checkInButton addTarget:self action:@selector(onCheckInClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:self.checkInButton];
        
        //  查询数据
        NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"eventIndex"] integerValue]] objectForKey:@"id"];
        NSArray *result = [[NSArray alloc] initWithArray:[self.myAppDelegate selectCoreDataroomId:roomId]];
        NSLog(@"sffsdfsd--sdf-sd-----  %@",roomId);
        //  给数据源数组中添加数据
        
        self.historyMicListArr = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [result count]; i++) {
            [self.historyMicListArr addObject:[result objectAtIndex:i]];
        }
        if ([self.historyMicListArr count] > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
        }
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF == %@", roomId];
        NSArray *results1 = [userInfomationData.isGetMicListMutableArr filteredArrayUsingPredicate:predicate1];
        if([results1 count] == 0)
        {
//            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
//            [MMProgressHUD showWithTitle:@"拉取历史聊天记录" status:NSLocalizedString(@"Please wating", nil)];
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                [userInfomationData.commonService getMessageInRoom:@"" roomId:roomId];
            });
            
            [userInfomationData.isGetMicListMutableArr addObject:roomId];
        }
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.infoButton.frame.size.height+self.infoButton.frame.origin.y+SCREEN_HEIGHT*30/568,bgView.frame.size.width,SCREEN_HEIGHT*235/568)];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.bounces = NO;
        self.tableView.scrollEnabled =NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.separatorInset = UIEdgeInsetsMake(15, 0, 15, 0);
        [bgView addSubview:self.tableView];
        
//        NSInteger i = [self.historyMicListArr count]-1;
//        if (i>4) {
//            NSIndexPath *lastPath = [NSIndexPath indexPathForRow: [self.historyMicListArr count]-1 inSection: 0 ];
//            [self.tableView scrollToRowAtIndexPath:lastPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        }
        
//        CoverFlowAlpahView *coverFlowAlpahView = [[CoverFlowAlpahView alloc] init];
//        if (SCREEN_HEIGHT > 568) {
//            coverFlowAlpahView.frame = CGRectMake(0, -10, SCREEN_WIDTH*260/320, SCREEN_HEIGHT*450/568);
//        }
//        else{
//            coverFlowAlpahView.frame = CGRectMake(0, 0, SCREEN_WIDTH*260/320, SCREEN_HEIGHT*450/568);
//        }
//        coverFlowAlpahView.backgroundColor = [UIColor clearColor];
//        [bgView addSubview:coverFlowAlpahView];
        
    }
    
    return self;
}

//UTC时间转换成对应系统时间
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.historyMicListArr count] >= 4) {
        return 4;
    }
    return [self.historyMicListArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT*55/568;
}

#define headImageButtonTag 10001
#define nameLabelTag 20001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.micTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"MicTableViewCell"];
    if (self.micTableViewCell == nil)
    {
        self.micTableViewCell = [[CoverFlowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CoverFlowTableViewCell" index:indexPath.row];
        [self.micTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    NSInteger xx;
    if ([self.historyMicListArr count]>=4) {
        xx = 3;
    }
    else
    {
        xx = [self.historyMicListArr count]-1;
    }
    Mic *mic = self.historyMicListArr[xx-indexPath.row];
    //3.5为语音时间
    self.micTableViewCell.bgImageView.layer.cornerRadius = (SCREEN_WIDTH*35/320)/2;
    self.micTableViewCell.bgImageView.layer.masksToBounds = YES;
    [self.micTableViewCell.bgImageView setImage:[UIImage imageNamed:@"background.png"]];
    
    self.micTableViewCell.headImageButton.frame = CGRectMake((self.tableView.frame.size.width-(SCREEN_WIDTH*35/320))/2, 0, SCREEN_WIDTH*35/320, SCREEN_WIDTH*35/320);
    self.micTableViewCell.headImageButton.tag = headImageButtonTag+indexPath.row;
    self.micTableViewCell.headImageButton.layer.cornerRadius = (SCREEN_WIDTH*35/320)/2;
    self.micTableViewCell.headImageButton.layer.masksToBounds = YES;
    
    [self.micTableViewCell.headImageButton addTarget:self action:@selector(onHeadBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.micTableViewCell.headImageButton.tag = indexPath.row;
    
    self.micTableViewCell.nameLabel.frame = CGRectMake(0, SCREEN_WIDTH*35/320-5, self.tableView.frame.size.width, 35);
    self.micTableViewCell.nameLabel.tag = nameLabelTag+indexPath.row;
    [self.micTableViewCell.nameLabel setHidden:YES];
    //语音时间计算
     __block float timeF = [mic.time floatValue];
    if ([self.historyMicListArr count]>=4) {
        if (timeF <= 4) {
            timeF = 2.0;
        }
        if (timeF>4 && timeF < 20) {
            timeF = 2+timeF/5;
        }
        if (timeF>=20) {
            timeF = 6.5;
        }
        self.micTableViewCell.bgImageView.frame = CGRectMake((self.tableView.frame.size.width-(SCREEN_WIDTH*30/320*timeF))/2, 0, SCREEN_WIDTH*30/320*timeF, SCREEN_WIDTH*35/320);
        [self.micTableViewCell.headImageButton sd_setImageWithURL:mic.avatarImage forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"171604419.jpg"]];
        self.micTableViewCell.nameLabel.text = mic.fromUserName;
     }
    if ([self.historyMicListArr count] >0 && [self.historyMicListArr count] <4)
    {
        timeF = [mic.time floatValue];
        
        self.micTableViewCell.bgImageView.frame = CGRectMake((self.tableView.frame.size.width-(SCREEN_WIDTH*30/320*timeF))/2, 0, SCREEN_WIDTH*30/320*timeF, SCREEN_WIDTH*35/320);
        [self.micTableViewCell.headImageButton sd_setImageWithURL:mic.avatarImage forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"171604419.jpg"]];
        self.micTableViewCell.nameLabel.text = mic.fromUserName;
        NSLog(@"-*-*-*-*-*x-x-x-x-x-----%li-- %@",(long)indexPath.row,mic.fromUserName);
    }
    
    
    return self.micTableViewCell;
}

- (void)onHeadBtnClick:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onCoverFlowViewHeadBtnClick" object:self];
}



@end
