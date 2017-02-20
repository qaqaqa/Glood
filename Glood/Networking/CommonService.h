//
//  CommonService.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/9.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "KSDeferred.h"
#import "SignalR.h"
#import <CoreData/CoreData.h>

@class CommonService;
@protocol getMicHistoryListDelegate <NSObject>

- (void)getMicHistoryList;

@end


@interface CommonService : NSObject<SRConnectionDelegate,NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) id<getMicHistoryListDelegate> delegate;
@property (strong, nonatomic) SRHubProxy *chat;
@property (strong, nonatomic) NSString *reConnectionTag;

+ (BOOL) isBlankString:(NSString *)string;

+ (id) processDictionaryIsNSNull:(id)obj;

//检查网络
+ (BOOL)NetWorkIsOK;

//清除聊天信息
- (void)clearData;

//外部账号注册
- (KSPromise *)signup_external:(NSString *)external_access_token provider:(NSString *)providerContent;

//通过外部账号token获取本地资源服务器token
- (KSPromise *)obtain_local_access_token:(NSString *)external_access_token;

//连接signlar
- (void)connectionSignlar;

//连接signlar服务后，先让用户进入聊天室
- (void)joinChatRoom;

//断线重连
- (void)reconntionSignlar;

//获取当前用户的所有活动
- (KSPromise *)getEventsList;

//获取当前用户某一个活动的所有票
- (KSPromise *)getTicket:(NSString *)eventId;

//扫描后，添加票到该用户
- (KSPromise *)addTicket:(NSString *)barcode eventId:(NSString *)event_id;

//扫描后，加入聊天室
- (void)joinRoom:(NSString *)roomId;

//在聊天室内，发送消息
- (void)sendMessageInRoom:(NSString *)messgae roomId:(NSString *)roomIdContent messageType:(NSInteger)messageType messageId:(NSString *)messageIdx;

//进入聊天室时，获取历史消息
- (void)getMessageInRoom:(NSString *)lastMessageId roomId:(NSString *)roomIdContent;

//反馈意见
- (void)sendFeedback:(NSString *)feedbackContent;

//喜欢一条消息
- (void)likeMessage:(NSString *)likeMessageId;

//屏蔽一个人的所有发言
- (void)blockUser:(NSString *)blockUserId;

//取消屏蔽一个人的所有发言
- (void)cancelBlockUser:(NSString *)cancelBlockUserId;

//获取当前用户屏蔽发言人的列表
- (void)getBlockUsers;

@end
