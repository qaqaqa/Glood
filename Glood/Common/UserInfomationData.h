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

@property (strong, nonatomic) NSString *refushStr;  //是否加载更多历史记录


@property (strong, nonatomic) NSString *isEnterMicList; //判断当前是在聊天室还是在活动卡片列表

@property (assign, nonatomic) NSInteger getMessageHistoryCount; // 拉取历史消息的时候返回两次结果，这个标记暂时用于解决这个问题

@property (strong, nonatomic) id chat;

@property (assign, nonatomic) NSInteger micMockListPageIndex;

@end
