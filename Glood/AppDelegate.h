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


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//插入聊天语音数据库
- (void)insertCoreData:(NSString *)userIdx avatarImage:(NSString *)avatarImagex roomId:(NSString *)roomIdx time:(NSNumber *)timex
               message:(NSString *)messagex messageId:(NSString *)messageIdx fromUserName:(NSString *) fromUserNamex;


//查询数据
- (NSArray *)selectCoreDataroomId:(NSString *)roomIdx;

//插入lastMessageId到数据库（每次从服务器上拉取的时候插入）
- (void)insertCoraData:(NSString *)roomIdx lastMessageId:(NSString *)lastMessageIdx beginMessageId:(NSString *)beginMessageIdx;

//查询是否需要历史记录是从服务器上拉取还是从本地数据库加载
- (Boolean )selectCoreDataroomId:(NSString *)roomIdx refreshMessageId:(NSString *)refreshMessageIdx;

//查询数据库，拉取历史聊天记录
- (NSArray *)selectCoreDataroomId:(NSString *)roomIdx pageIndex:(NSInteger)pageIndexx pageSize:(NSInteger)pageSizex;

//删除数据库一条消息（预加载的消息）
- (void)deletePreLoadingMessage;

//删除数据库中包含messageId等于“99999999999999999”的所有消息
- (void)deleteAllPreLoadingMessage;

//查询数据库，找出每个房间最大的messageId
- (NSString *)largeMessageIdFromDB:(NSString *)roomId;

@end

