//
//  UserInfomationData.h
//  SmallMoney
//
//  Created by fanlin on 13-6-27.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfomationData : NSObject


+ (UserInfomationData *)shareInstance;

@property (strong, nonatomic) id commonService;
@property (strong, nonatomic) id recordAudio;
@property (strong, nonatomic) id viewVC;

@property (strong, nonatomic) NSDictionary *eventDic; //该用户的所有活动
@property (strong, nonatomic) NSDictionary *ticketsDic; //该用户某一个活动下的所有票类
@property (strong, nonatomic) NSDictionary *userDic; //当前用户的基本信息（singlar join）
//@property (strong, nonatomic) NSMutableArray *historyMicArr; //聊天历史记录
//
//@property (retain, nonatomic) NSMutableArray *historyMicListArr;//临时

@property (strong, nonatomic) NSMutableArray *isGetMicListMutableArr; //打开应用程序保存拉取过历史消息的活动roomid

@property (strong, nonatomic) NSString *inRoomMessageForRoomIdStr; //聊天室收到消息的房间号

@property (strong, nonatomic) NSString *pushEventVCTypeStr; //从那个页面进入聊天室或者卡片页面
@property (strong, nonatomic) NSString *QRRoomId; //通过扫描拿到的roomid
//@property (strong, nonatomic) NSString *QRTopImageUrl; //通过扫描拿到的roomid

@property (strong, nonatomic) NSString *shieldUserId;  //屏蔽人的的id
@property (strong, nonatomic) NSString *shieldRoomId;  //屏蔽人的房间id
@property (strong, nonatomic) NSString *likeMessageId;  //喜欢的这条消息的messageid
@property (strong, nonatomic) NSString *likeMessageIdSucess;  //喜欢一条消息成功后，的messageid

@property (strong, nonatomic) NSString *refushStr;  //是否加载更多历史记录


@property (strong, nonatomic) NSString *isEnterMicList; //判断当前是在聊天室还是在活动卡片列表

@property (assign, nonatomic) NSInteger getMessageHistoryCount; // 拉取历史消息的时候返回两次结果，这个标记暂时用于解决这个问题

@property (strong, nonatomic) id chat;

@property (assign, nonatomic) NSInteger micMockListPageIndex;

@property (strong, nonatomic) NSString *currtentRoomIdStr;  //用户当前所在哪个聊天室

@property (strong, nonatomic) id hubConnection; //保存SRHubConnection对象

@property (strong, nonatomic) NSMutableArray *waitingSendMessageQunenMutableArr; //等待发送的消息数组对象
@property (strong, nonatomic) NSDictionary *waitingSendMessageQunenMutableDic; //等待发送的消息队列对象
@property (assign, nonatomic) long long yuMessageId; //预设一个初始的messageId

@property (strong, nonatomic) NSString *mockViewNameLabelIsHiddenStr; //mock tableview cell是否显示发送语音消息的姓名

@property (assign, nonatomic) NSInteger refreshCount; //下拉加载更多的circle

@property (retain, nonatomic) NSTimer *timer; //断线重连计时器

@property (retain, nonatomic) NSMutableArray *blockUsersMutableArr;//本地解析屏蔽列表的存储结果

@property (strong, nonatomic) NSString *recordMessageTimeStr;  //当前这条消息的录音时间

@property (strong, nonatomic) NSString *yuLoadMessageTimeStr; //当前这条预加载语音的录音时间（录音还在继续，未停止的情况下，用于预加载动画使用）

@property (strong, nonatomic) NSString *getUsersLikesCountInRoom; //在这个房间中，有多少人喜欢了你

@property (strong, nonatomic) NSMutableArray *getUsersLikesInRoomMutableArr; //在这个房间中，喜欢你的人的列表

@end
