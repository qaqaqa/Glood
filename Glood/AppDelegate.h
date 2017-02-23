//
//  AppDelegate.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/26.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ViewController.h"
#import "CommonService.h"
#import "RecordAudio.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) UINavigationController *navigateC;
@property (strong, nonatomic) ViewController *viewVC;
@property (strong, nonatomic) CommonService *commonService;
@property (strong, nonatomic) RecordAudio *recordAudio;
@property (strong, nonatomic) NSString *networkStatus;

@property (retain, nonatomic) UIView *showTipsView;
@property (retain, nonatomic) UILabel *showTipsLabel;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//通知，订阅主题 推送消息
- (void)subscribeToTopic:(NSDictionary*)dic;

//通知，订阅主题 推送喜欢信息
- (void)subscribeToTopicLikeMessage:(NSDictionary *)dicLikeMessage;

//插入聊天语音数据库
- (void)insertCoreData:(NSString *)userIdx avatarImage:(NSString *)avatarImagex roomId:(NSString *)roomIdx time:(NSNumber *)timex
               message:(NSString *)messagex messageId:(NSString *)messageIdx fromUserName:(NSString *) fromUserNamex like:(NSNumber *)likeMessage;


//查询数据
- (NSArray *)selectCoreDataroomId:(NSString *)roomIdx;

//插入lastMessageId到数据库（每次从服务器上拉取的时候插入）
- (void)insertCoraData:(NSString *)roomIdx lastMessageId:(NSString *)lastMessageIdx beginMessageId:(NSString *)beginMessageIdx;

//插入预加载数据库
- (void)insertCoreDataxx:(NSString *)userIdx avatarImage:(NSString *)avatarImagex roomId:(NSString *)roomIdx time:(NSNumber *)timex
                 message:(NSString *)messagex messageId:(NSString *)messageIdx fromUserName:(NSString *) fromUserNamex like:(NSNumber *)likeMessage;

//查询是否需要历史记录是从服务器上拉取还是从本地数据库加载
- (Boolean )selectCoreDataroomId:(NSString *)roomIdx refreshMessageId:(NSString *)refreshMessageIdx;

//查询数据库，拉取历史聊天记录
- (NSArray *)selectCoreDataroomId:(NSString *)roomIdx pageIndex:(NSInteger)pageIndexx pageSize:(NSInteger)pageSizex;

//删除数据库一条消息（预加载的消息）
- (void)deletePreLoadingMessage:(NSString *)roomIdx message:(NSString *)messageIdx;

//删除数据库中包含messageId等于“99999999999999999”的所有消息
- (void)deleteAllPreLoadingMessage;

//查询数据库，找出每个房间最大的messageId
- (NSString *)largeMessageIdFromDB:(NSString *)roomId;

//删除屏蔽人的信息
-(void)deleteShieldMessage:(NSString *)roomIdx userId:(NSString *)userIdx;

//更新 喜欢一条消息
- (void)updateLikeMessageId:(NSString *)messageId isRead:(NSString *)isReadContent;



@end

