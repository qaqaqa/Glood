//
//  CommonService.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/9.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "CommonService.h"
#import "MMProgressHUD.h"
#import "Define.h"
#import "AFNetworking.h"
#import "KSDeferred.h"
#import "ShowMessage.h"
#import "HMFJSONResponseSerializerWithData.h"
#import "UserInfomationData.h"
#import "AppDelegate.h"
#import "EventViewController.h"
#import "Mic.h"

@interface CommonService ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) EventViewController *eventVC;
@property (strong, nonatomic) AppDelegate *myAppDelegate;
@end
@implementation CommonService

+ (BOOL)NetWorkIsOK
{
    if(
       ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]
        != NotReachable)
       &&
       ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]
        != NotReachable)
       ){
        return YES;
    }else{
        return NO;
    }
}

//判断字符串为空
+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

#pragma mark =======连接facebook 外部注册======
- (KSPromise *)signup_external:(NSString *)external_access_token provider:(NSString *)providerContent
{
    NSLog(@"-*-----  %@",external_access_token);
    return [[self postFackBookWithParams:@{
                                        @"external_access_token": external_access_token,
                                        @"provider": providerContent,
                                        }endpoint:@"members/signup_external"]
            then:^id(id value) {
                return value;
            } error:nil];
}

- (KSPromise *)postFackBookWithParams:(NSDictionary *)params
                     endpoint:(NSString *)endpoint
{
    __block KSDeferred *requestDeferred = [KSDeferred defer];
    NSString *urlString = [REQUEST_BASE_URL stringByAppendingString:endpoint];
    NSLog(@"url string %@", urlString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [requestDeferred resolveWithValue:responseObject];
        
        NSLog(@"JSON: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [requestDeferred rejectWithError:error];
    }];
    
    NSLog(@"url string %@", urlString);
    return requestDeferred.promise;
}

#pragma mark =======连接facebook 置换token======
- (KSPromise *)obtain_local_access_token :(NSString *)external_access_token
{
    return [[self getExchangeTokenWithParams:nil endpoint:[NSString stringWithFormat:@"/oauth2/obtain_local_access_token?client_id=1&provider=Facebook&external_access_token=%@",external_access_token]]
            then:^id(id value) {
                return value;
            } error:nil];
}

- (KSPromise *)getExchangeTokenWithParams:(NSDictionary *)params
                    endpoint:(NSString *)endpoint
{
    __block KSDeferred *requestDeferred = [KSDeferred defer];
    NSString *urlString = [FACEBOOK_OAUTH2_EXCHANGE_URL stringByAppendingString:endpoint];
    
    NSLog(@"url string %@", urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [requestDeferred resolveWithValue:responseObject];
            NSLog(@"%@ JSON: %@", endpoint, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    return requestDeferred.promise;
}

#pragma mark ======== 获取当前用户的所有活动 =========
- (KSPromise *)getEventsList
{
    return [[self getEventWithParams:nil endpoint:[NSString stringWithFormat:@"members/current/events"]]
            then:^id(id value) {
                return value;
            } error:nil];
}

- (KSPromise *)getEventWithParams:(NSDictionary *)params
                                 endpoint:(NSString *)endpoint
{
    self.myAppDelegate = [UIApplication sharedApplication].delegate;
    __block KSDeferred *requestDeferred = [KSDeferred defer];
    NSString *urlString = [REQUEST_BASE_URL stringByAppendingString:endpoint];
    
    NSLog(@"url string %@", urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [HMFJSONResponseSerializerWithData serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:Exchange_OAUTH2_TOKEN]] forHTTPHeaderField:@"authorization"];
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, NSArray * responseObject) {
        [requestDeferred resolveWithValue:responseObject];
        NSLog(@"json: ----%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@----%@", error.description,operation);
    }];
    return requestDeferred.promise;
}

#pragma mark ======== 获取当前用户某一个活动的所有票 =========
- (KSPromise *)getTicket:(NSString *)eventId
{
    return [[self getTicketWithParams:nil endpoint:[NSString stringWithFormat:@"members/current/events/%@/ticket_subs",eventId]]
            then:^id(id value) {
                return value;
            } error:nil];
}

- (KSPromise *)getTicketWithParams:(NSDictionary *)params
                         endpoint:(NSString *)endpoint
{
    __block KSDeferred *requestDeferred = [KSDeferred defer];
    NSString *urlString = [REQUEST_BASE_URL stringByAppendingString:endpoint];
    
    NSLog(@"url string %@", urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [HMFJSONResponseSerializerWithData serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:Exchange_OAUTH2_TOKEN]] forHTTPHeaderField:@"authorization"];
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, NSArray * responseObject) {
        [requestDeferred resolveWithValue:responseObject];
        NSLog(@"json: ----%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@----%@", error.description,operation);
    }];
    return requestDeferred.promise;
}

#pragma mark ======== 扫描后，添加票到该用户 =========
- (KSPromise *)addTicket:(NSString *)barcode eventId:(NSString *)event_id
{
    return [[self postAddTicketWithParams:@{
                                           @"barcode": barcode,
                                           @"event_id": event_id,
                                           }endpoint:@"members/current/ticket_subs"]
            then:^id(id value) {
                return value;
            } error:nil];
}

- (KSPromise *)postAddTicketWithParams:(NSDictionary *)params
                         endpoint:(NSString *)endpoint
{
    __block KSDeferred *requestDeferred = [KSDeferred defer];
    NSString *urlString = [REQUEST_BASE_URL stringByAppendingString:endpoint];
    
    NSLog(@"url string %@", urlString);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [HMFJSONResponseSerializerWithData serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:Exchange_OAUTH2_TOKEN]] forHTTPHeaderField:@"authorization"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, NSArray * responseObject) {
        [requestDeferred resolveWithValue:responseObject];
        NSLog(@"add ticket json: ----%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@----%@", error.description,operation);
    }];
    return requestDeferred.promise;
}


#pragma mark ======== 连接聊天室 =========
- (void)connectionSignlar
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(reconntionSignlar)
                                                userInfo:nil
                                                 repeats:YES];
    id qs = @{
              @"access_token": [[NSUserDefaults standardUserDefaults] objectForKey:Exchange_OAUTH2_TOKEN],
              };
    SRHubConnection *hubConnection = [SRHubConnection connectionWithURLString:SIGNLAR_URL queryString:qs];
    self.chat = [hubConnection createHubProxy:@"chat"];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.chat = self.chat;
    [self.chat on:@"onUserJoinRoom" perform:self selector:@selector(onUserJoinRoom:)];
    [self.chat on:@"onUserLeaveRoom" perform:self selector:@selector(onUserLeaveRoom:)];
    [self.chat on:@"onSendMessageInRoom" perform:self selector:@selector(onSendMessageInRoom:)];
//    self.eventVC = [[EventViewController alloc] init];
    
    [hubConnection setStarted:^{
        NSLog(@"Connection Started");
        
        [[NSUserDefaults standardUserDefaults] setObject:@"open" forKey:@"signlarStauts"];
        [MMProgressHUD showWithTitle:@"拉取活动信息" status:NSLocalizedString(@"Please wating", nil)];
        [[self getEventsList] then:^id(id value) {
            UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
            userInfomationData.eventDic = [[NSDictionary alloc] init];
            userInfomationData.eventDic = value;
            NSLog(@"拉取活动成功----");
            [MMProgressHUD showWithTitle:@"正在加入聊天室" status:NSLocalizedString(@"Please wating", nil)];
            [self joinChatRoom];
            return value;
        } error:^id(NSError *error) {
            NSLog(@"拉取活动失败--- %@",error);
            //拉取活动失败，继续拉取
            [MMProgressHUD dismissWithError:@"拉取活动失败，请重新尝试" afterDelay:2.0f];
            [[self getEventsList] then:^id(id value) {
                UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
                userInfomationData.eventDic = [[NSDictionary alloc] init];
                userInfomationData.eventDic = value;
                NSLog(@"拉取活动成功----");
                [MMProgressHUD showWithTitle:@"正在加入聊天室" status:NSLocalizedString(@"Please wating", nil)];
                [self joinChatRoom];
                return value;
            } error:^id(NSError *error) {
                NSLog(@"拉取活动失败--- %@",error);
                [MMProgressHUD dismissWithError:@"拉取活动失败，请重新尝试" afterDelay:2.0f];
                return error;
            }];
            return error;
        }];
    }];
    [hubConnection setConnectionSlow:^{
        NSLog(@"Connection Slow");
    }];
    [hubConnection setClosed:^{
        NSLog(@"Connection Closed");
    }];
    [hubConnection setError:^(NSError *error) {
        NSLog(@"Connection Error %@",error.description);
    }];
    hubConnection.delegate = self;
    [hubConnection start];
}

#pragma mark ======== 连接signlar服务后，先让用户进入聊天室 =========
- (void)joinChatRoom
{
        [self.chat invoke:@"join" withArgs:@[] completionHandler:^(id response, NSError *error) {
            if (error) {
                //加入聊天室失败，继续尝试加入
                [self joinChatRoom];
                [MMProgressHUD dismissWithError:@"加入聊天室失败，请重新尝试" afterDelay:2.0f];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
            }
            if (response == NULL) {
                return;
            }
                UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
                userInfomationData.userDic = [[NSDictionary alloc] init];
                userInfomationData.userDic = response;
                
                [MMProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getEventList" object:self];
            if ([self.reConnectionTag isEqualToString:@"reConnetion"]) {
                [self getMessageInRoom:@"" roomId:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]];
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    for (NSInteger i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
                        [self getMessageInRoom:@"" roomId:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]];
                    }
                });
                
                self.reConnectionTag = @"";
            }
            
            
                NSLog(@"join-*-*-*-*-*-*-*-*-*-*  %@",response);
            [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"avatar"] forKey:USER_AVATAR_URL];
            [[NSUserDefaults standardUserDefaults] setObject:[[[response objectForKey:@"connected_clients"] objectAtIndex:0] objectForKey:@"user_name"] forKey:USER_NAME];
            [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"current_client_id"] forKey:USER_CLIENT_ID];
        }];
}

#pragma mark ======== 断线重连 =========
- (void)reconntionSignlar
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"closed"]){
        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:@"断线重连中" status:NSLocalizedString(@"Please wating", nil)];
        [self.timer invalidate];
        [self connectionSignlar];
        self.reConnectionTag = @"reConnetion";
    }
}

#pragma mark ======== 某人加入聊天室通知 =========
- (void)onUserJoinRoom:(NSDictionary *)msg
{
    NSLog(@"------- %@",msg);
    [ShowMessage showMessage:[NSString stringWithFormat:@"%@ Join",[msg objectForKey:@"user_name"]]];
}

#pragma mark ======== 某人离开聊天室通知 =========
- (void)onUserLeaveRoom:(NSDictionary *)msg
{
    NSLog(@"------- %@",msg);
    [ShowMessage showMessage:[NSString stringWithFormat:@"%@ Leave",[msg objectForKey:@"user_name"]]];
}

#pragma mark ======== 聊天室收到消息 =========
- (void)onSendMessageInRoom:(NSDictionary *)msg
{
    NSLog(@"------- %@",msg);
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    //当前用户userid
    //发送消息的用户
    if (msg == NULL) {
        return;
    }
    NSArray *arr = [[NSArray alloc] init];
    arr = [[msg objectForKey:@"content"] componentsSeparatedByString:@","];
    if ([[msg objectForKey:@"message_type"] isEqualToString:@"Audio"] && [arr count]==2) {
        NSLog(@"收到消息---%@---%@",[msg objectForKey:@"room_id"],[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]);
        
        userInfomationData.inRoomMessageForRoomIdStr = [msg objectForKey:@"room_id"];
        
        if (![[msg objectForKey:@"client_id"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:USER_CLIENT_ID]]) {
            [self.myAppDelegate insertCoreData:[msg objectForKey:@"user_id"] avatarImage:[msg objectForKey:@"user_avatar"] roomId:[msg objectForKey:@"room_id"] time:[NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]] message:[arr objectAtIndex:1] messageId:[msg objectForKey:@"id"] fromUserName:[msg objectForKey:@"user_name"]];
        }
        else
        {
            //更新数据库一条消息
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
            //  2.设置排序
            //  2.1创建排序描述对象
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
            request.sortDescriptors = @[sortDescriptor];
            NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@ AND messageId = %@",roomId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],@"99999999999999999"]];
            request.fetchOffset=0;
            request.fetchLimit=100;
            request.predicate = predicate;
            
            //  执行这个查询请求
            NSError *error = nil;
            
            NSArray *result = [self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error];
//            NSLog(@"xxxxcx---commonservice-%@===%@ --%lu--- %@",roomId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],(unsigned long)[result count],messageIdStr);
            
            for (NSInteger i = 0; i < [result count]; i ++) {
                
                Mic *mic = result[0];
                NSLog(@"xxxxxx-*-*-------  ^%@",mic.messageId);
                mic.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID];
                mic.userId = [msg objectForKey:@"user_id"];
                mic.avatarImage = NULL_TO_NIL([msg objectForKey:@"user_avatar"]);
                mic.roomId = [msg objectForKey:@"room_id"];
                mic.isRead = 0;
                mic.time = [NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]];
                mic.message = [arr objectAtIndex:1];
                mic.messageId = [msg objectForKey:@"id"];
                mic.fromUserName = [msg objectForKey:@"user_name"];
                [self.myAppDelegate saveContext];
            }
        }
        
        //活动列表后的未读消息小红点标记
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@",@"red",[msg objectForKey:@"room_id"]]];
        if ([userInfomationData.isEnterMicList isEqualToString:@"true"] && [[msg objectForKey:@"room_id"] isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
        }
    }
    
}

#pragma mark ======== 扫描后，加入聊天室 =========
- (void)joinRoom:(NSString *)roomId
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.QRRoomId = roomId;
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        [userInfomationData.chat invoke:@"joinRoom" withArgs:@[roomId] completionHandler:^(id response, NSError *error) {
            if (error) {
                NSLog(@"加入聊天室失败--- %@",error.description);
                [MMProgressHUD dismissWithError:@"加入聊天室失败，请重新再试" afterDelay:2.0f];
                return;
            }
            if (response == NULL) {
                return;
            }
            NSLog(@"扫描后加入聊天室joinroom-*-*-*-*-*-*-*-*-*-*xxxx  %@",response);
            [[self getEventsList] then:^id(id value) {
                UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
                userInfomationData.eventDic = [[NSDictionary alloc] init];
                userInfomationData.eventDic = value;
                NSLog(@"拉取活动成功----");
                [self joinChatRoom];
                [MMProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"joinRoom" object:self];
                return value;
            } error:^id(NSError *error) {
                NSLog(@"拉取活动失败--- %@",error);
                return error;
            }];
//            if ([response integerValue] == 1) {
//                [MMProgressHUD dismiss];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"joinRoom" object:self];
//            }
        }];
//    }
//    else{
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"network error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alertView show];
//    }
}

#pragma mark ======== 在聊天室内，发送消息 =========
- (void)sendMessageInRoom:(NSString *)messgae roomId:(NSString *)roomIdContent messageType:(NSInteger)messageType
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageScu" object:self];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSLog(@"-*-/-*-*-*- ----  %@",messgae);
        [userInfomationData.chat invoke:@"sendMessageInRoom" withArgs:@[messgae,roomIdContent,[NSNumber numberWithInteger:messageType]] completionHandler:^(id response, NSError *error) {
            if (error) {
                [self.myAppDelegate deletePreLoadingMessage];
                [ShowMessage showMessage:@"消息发送失败"];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            
            [ShowMessage showMessage:@"消息发送成功"];
            NSLog(@"发送消息-*-*-*-*-*-*-*-*-*-*  %@",response);
        }];
}

#pragma mark ======== 进入聊天室时，获取历史消息 =========
- (void)getMessageInRoom:(NSString *)lastMessageId roomId:(NSString *)roomIdContent
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        NSLog(@"***-------  %@",roomIdContent);
        [userInfomationData.chat invoke:@"getMessagesInRoom" withArgs:@[roomIdContent,lastMessageId,@"20"] completionHandler:^(id response, NSError *error) {
            if (error) {
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            if (response == NULL) {
                return;
            }
            NSLog(@"xxxxjxjxjxlll----- %lu",[response count]);
            for (NSInteger i = 0;i < [response count] ; i ++) {
                NSArray *arr = [[NSArray alloc] init];
                arr = [[[response objectAtIndex:i] objectForKey:@"content"] componentsSeparatedByString:@","];
                if ([[[response objectAtIndex:i] objectForKey:@"message_type"] isEqualToString:@"Audio"] && [arr count]==2) {
                    [self.myAppDelegate insertCoreData:[[response objectAtIndex:i] objectForKey:@"user_id"] avatarImage:[[response objectAtIndex:i] objectForKey:@"user_avatar"] roomId:[[response objectAtIndex:i] objectForKey:@"room_id"] time:[NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]] message:[arr objectAtIndex:1] messageId:[[response objectAtIndex:i] objectForKey:@"id"] fromUserName:[[response objectAtIndex:i] objectForKey:@"user_name"]];
                    [self.myAppDelegate insertCoraData:[[response objectAtIndex:i] objectForKey:@"room_id"] lastMessageId:[[response objectAtIndex:[response count]-1] objectForKey:@"id"] beginMessageId:[[response objectAtIndex:0] objectForKey:@"id"]];
//                    [userInfomationData.historyMicArr insertObject:[self processDictionaryIsNSNull:[response objectAtIndex:i]] atIndex:0];
                    userInfomationData.inRoomMessageForRoomIdStr = [[response objectAtIndex:i] objectForKey:@"room_id"];
                }
            }
            
//            [[NSUserDefaults standardUserDefaults] setObject:userInfomationData.historyMicArr forKey:roomIdContent];
            
                if ([userInfomationData.isEnterMicList isEqualToString:@"true"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                }
            
        }];
}

#pragma mark ======== 反馈意见 =========
- (void)sendFeedback:(NSString *)feedbackContent
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    [userInfomationData.chat invoke:@"sendFeedback" withArgs:@[feedbackContent] completionHandler:^(id response, NSError *error) {
        if (error) {
            [ShowMessage showMessage:@"反馈发送失败"];
            NSLog(@"xxxxxxxxxxx----%@",error.description);
            return;
        }
        if (response == NULL) {
            return;
        }
        [ShowMessage showMessage:@"反馈发送成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendFeedbackScu" object:self];
    }];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoreMicInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"message_id" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"CoreMicInfo"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}


//清除聊天信息
- (void)clearData
{
    for (NSInteger i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:0] objectForKey:@"id"]];
    }
}


#pragma mark ============    替换dictionary中的<null>为@“”    ===========
- (id) processDictionaryIsNSNull:(id)obj{
    const NSString *blank = @"";
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dt = [(NSMutableDictionary*)obj mutableCopy];
        for(NSString *key in [dt allKeys]) {
            id object = [dt objectForKey:key];
            if([object isKindOfClass:[NSNull class]]) {
                [dt setObject:blank
                       forKey:key];
            }
            else if ([object isKindOfClass:[NSString class]]){
                NSString *strobj = (NSString*)object;
                if ([strobj isEqualToString:@"<null>"]) {
                    [dt setObject:blank
                           forKey:key];
                }
            }
            else if ([object isKindOfClass:[NSArray class]]){
                NSArray *da = (NSArray*)object;
                da = [self processDictionaryIsNSNull:da];
                [dt setObject:da
                       forKey:key];
            }
            else if ([object isKindOfClass:[NSDictionary class]]){
                NSDictionary *ddc = (NSDictionary*)object;
                ddc = [self processDictionaryIsNSNull:object];
                [dt setObject:ddc forKey:key];
            }
        }
        return [dt copy];
    }
    else if ([obj isKindOfClass:[NSArray class]]){
        NSMutableArray *da = [(NSMutableArray*)obj mutableCopy];
        for (int i=0; i<[da count]; i++) {
            NSDictionary *dc = [obj objectAtIndex:i];
            dc = [self processDictionaryIsNSNull:dc];
            [da replaceObjectAtIndex:i withObject:dc];
        }
        return [da copy];
    }
    else{
        return obj;
    }
}

@end
