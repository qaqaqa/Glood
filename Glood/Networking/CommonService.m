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
@import FirebaseMessaging;

@interface CommonService ()


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
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        [MMProgressHUD dismissWithError:[[serializedData objectForKey:@"error"] objectForKey:@"message"] afterDelay:2.0f];
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
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        NSLog(@"errorheiheihiehiehi--%@",serializedData);
        if ([[[serializedData objectForKey:@"error"] objectForKey:@"message"] isEqualToString:@"NotRegisterExternalAccount"]) {
            //调用外部注册
            UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
            [MMProgressHUD showWithTitle:@"register" status:NSLocalizedString(@"Please wating", nil)];
            [[userInfomationData.commonService signup_external:[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_TOKEN] provider:@"Facebook"] then:^id(id value) {
                NSLog(@"调用外部注册成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"exchangeToken" object:self];
                return value;
            } error:^id(NSError *error) {
                NSLog(@"调用外部注册失败--- %@",error);
//                [MMProgressHUD dismissWithError:@"register error" afterDelay:2.0f];
                return error;
            }];
        }
        else{
            [MMProgressHUD dismissWithError:[[serializedData objectForKey:@"error"] objectForKey:@"message"] afterDelay:2.0f];
        }

        NSLog(@"Errorxxxxxxxxx: %@hahha%@", error.description,operation);
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
        NSLog(@"json获取所有活动: ----%@", responseObject);
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
        [MMProgressHUD dismissWithError:@"Get ticket error,try again!" afterDelay:2.0f];
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
         [MMProgressHUD dismissWithError:@"add ticket error,try again!" afterDelay:2.0f];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onAddTicketsFail" object:self];
    }];
    return requestDeferred.promise;
}


#pragma mark ======== 连接聊天室 =========
- (void)connectionSignlar
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(reconntionSignlar)
                                                userInfo:nil
                                                 repeats:YES];
    id qs = @{
              @"access_token": [[NSUserDefaults standardUserDefaults] objectForKey:Exchange_OAUTH2_TOKEN],
              };
//    [userInfomationData.hubConnection didClose];
    SRHubConnection *hubConnection = [SRHubConnection connectionWithURLString:SIGNLAR_URL queryString:qs];
    self.chat = nil;
    self.chat = [hubConnection createHubProxy:@"chat"];
    
    userInfomationData.chat = self.chat;
    userInfomationData.hubConnection = nil;
    userInfomationData.hubConnection = hubConnection;
    [self.chat on:@"onUserJoinRoom" perform:self selector:@selector(onUserJoinRoom:)];
    [self.chat on:@"onUserLeaveRoom" perform:self selector:@selector(onUserLeaveRoom:)];
    [self.chat on:@"onSendMessageInRoom" perform:self selector:@selector(onSendMessageInRoom:)];
    [self.chat on:@"onUserLikeMessage" perform:self selector:@selector(onUserLikeMessage:)];
    [self.chat on:@"onBlockUser" perform:self selector:@selector(onBlockUser:)];
    [self.chat on:@"onCancelBlockUser" perform:self selector:@selector(onCancelBlockUser:)];
//    self.eventVC = [[EventViewController alloc] init];
    
    [hubConnection setStarted:^{
        NSLog(@"Connection Started");
        
        [[NSUserDefaults standardUserDefaults] setObject:@"open" forKey:@"signlarStauts"];
        [MMProgressHUD showWithTitle:@"get event info" status:NSLocalizedString(@"Please wating", nil)];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
            [[self getEventsList] then:^id(id value) {
                UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
                userInfomationData.eventDic = [[NSDictionary alloc] init];
                userInfomationData.eventDic = value;
                [self.myAppDelegate subscribeToTopic:value];
                NSLog(@"拉取活动成功----%@",[[[value objectForKey:@"result"] objectAtIndex:0] objectForKey:@"id"]);
                [MMProgressHUD showWithTitle:@"join chatroom" status:NSLocalizedString(@"Please wating", nil)];
                [self joinChatRoom];
                [self getBlockUsers:@"yes"];
                return value;
            } error:^id(NSError *error) {
                NSLog(@"拉取活动失败--- %@",error);
                [MMProgressHUD dismissWithError:@"join chatroom error,try again!" afterDelay:2.0f];
                //拉取活动失败，继续拉取
//                [MMProgressHUD dismissWithError:@"get event info error,try again!" afterDelay:2.0f];
//                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
//                    [[self getEventsList] then:^id(id value) {
//                        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
//                        userInfomationData.eventDic = [[NSDictionary alloc] init];
//                        userInfomationData.eventDic = value;
//                        [self.myAppDelegate subscribeToTopic:value];
//                        NSLog(@"拉取活动成功----");
//                        [MMProgressHUD showWithTitle:@"join chatroom" status:NSLocalizedString(@"Please wating", nil)];
////                        [self joinChatRoom];
//                        return value;
//                    } error:^id(NSError *error) {
//                        NSLog(@"拉取活动失败--- %@",error);
//                        [MMProgressHUD dismissWithError:@"get event info error,try again!" afterDelay:2.0f];
//                        return error;
//                    }];
//                }
                return error;
            }];
        }
        else
        {
//            [ShowMessage showMessage:@"disconnect chatroom"];
        }
        
    }];
    [hubConnection setConnectionSlow:^{
//        [[NSUserDefaults standardUserDefaults] setObject:@"open" forKey:@"signlarStauts"];
        NSLog(@"Connection Slow");
    }];
    [hubConnection setReconnecting:^{
        NSLog(@"Connection Reconnecting");
    }];
    [hubConnection setReconnected:^{
        NSLog(@"Connection Reconnected");
//        [[NSUserDefaults standardUserDefaults] setObject:@"open" forKey:@"signlarStauts"];
    }];
    [hubConnection setClosed:^{
        NSLog(@"Connection Closed");
//        userInfomationData.hubConnection = nil;
//        [userInfomationData.hubConnection stop];
//        [userInfomationData.hubConnection disconnect];
        
        [self.myAppDelegate deleteAllPreLoadingMessage];
        [[NSUserDefaults standardUserDefaults] setObject:@"closedsocket" forKey:@"signlarStauts"];
    }];
    [hubConnection setError:^(NSError *error) {
        userInfomationData.hubConnection = nil;
//        [userInfomationData.hubConnection stop];
//        [userInfomationData.hubConnection disconnect];
        [self.myAppDelegate deleteAllPreLoadingMessage];
        NSLog(@"Connection Error %@",error.description);
        
        
        
        if ([error.description rangeOfString:@"Code=-1001"].location !=NSNotFound) {
//            [MMProgressHUD dismissWithError:@"time out,try again"];
            [[NSUserDefaults standardUserDefaults] setObject:@"closed" forKey:@"signlarStauts"];
        }
        else if([error.description rangeOfString:@"Code=-1005"].location !=NSNotFound)
        {
//            [MMProgressHUD dismissWithError:@"network error"];
            [[NSUserDefaults standardUserDefaults] setObject:@"closed" forKey:@"signlarStauts"];
        }
        else if([error.description rangeOfString:@"Code=-1009"].location !=NSNotFound)
        {
//            [MMProgressHUD dismissWithError:@"network error"];
            [[NSUserDefaults standardUserDefaults] setObject:@"closed" forKey:@"signlarStauts"];
        }
        
        else
        {
            [MMProgressHUD dismiss];
        }
//        [self reconntionSignlar];
        
    }];
    hubConnection.delegate = self;
    [hubConnection start];
    
}

#pragma mark ======== 连接signlar服务后，先让用户进入聊天室 =========
- (void)joinChatRoom
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        [self.chat invoke:@"join" withArgs:@[] completionHandler:^(id response, NSError *error) {
            if (error) {
                //加入聊天室失败，继续尝试加入
//                [self joinChatRoom];
//                [MMProgressHUD dismissWithError:@"join chatroom,try again!" afterDelay:2.0f];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
            }
            if (response == NULL) {
                return;
            }
            UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
            userInfomationData.userDic = [[NSDictionary alloc] init];
            userInfomationData.userDic = response;
            
            [MMProgressHUD dismiss];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getEventList" object:self];
            }
            
            if ([self.reConnectionTag isEqualToString:@"reConnetion"]) {
                UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
//                userInfomationData.isReconnectionStr = @"no";
//                userInfomationData.refushStr = @"no";
////                userInfomationData.isReconnectionGetMessageInRoomStr = @"yes";
//                userInfomationData.micMockListPageIndex = 1; //每次重新进入聊天室，当前分页置为0
//                userInfomationData.currentPage = 1;
//                [self getMessageInRoom:@"" roomId:userInfomationData.currtentRoomIdStr];

                    for (NSInteger i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
                        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
                            if (![userInfomationData.currtentRoomIdStr isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                                
                                [self getMessageInRoomReconnection:@"" roomId:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]];
                                if (i == [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]-1) {
                                    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
                                    userInfomationData.isReconnectionStr = @"no";
                                    userInfomationData.apiRoomIdStr = @"";
                                }
                            }
                            else
                            {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    userInfomationData.micMockListPageIndex = 1; //每次重新进入聊天室，当前分页置为0
                                    userInfomationData.currentPage = 1;
                                    [self getMessageInRoom:@"" roomId:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]];
                                });
                                
                            }
                            
                        }
                        
                    }
                    
                self.reConnectionTag = @"";
            }
            
            
            NSLog(@"join-*-*-*-*-*-*-*-*-*-*  %@",response);
            if ([response count]>=5) {
                
                NSString *nameStr;
                if ([response objectForKey:@"connected_clients"] > 0) {
                    if ([CommonService isBlankString:[[[response objectForKey:@"connected_clients"] objectAtIndex:0] objectForKey:@"name"]] || [CommonService isBlankString:[[[response objectForKey:@"connected_clients"] objectAtIndex:0] objectForKey:@"surname"]]) {
                        nameStr = [[[response objectForKey:@"connected_clients"] objectAtIndex:0] objectForKey:@"user_name"];
                    }
                    else
                    {
                        nameStr = [NSString stringWithFormat:@"%@ %@.",[[[response objectForKey:@"connected_clients"] objectAtIndex:0] objectForKey:@"name"],[[[[response objectForKey:@"connected_clients"] objectAtIndex:0] objectForKey:@"surname"] substringToIndex:1].uppercaseString];
                    }
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@?%@",[response objectForKey:@"avatar"],@"width=300&height=300"] forKey:USER_AVATAR_URL];
                [[NSUserDefaults standardUserDefaults] setObject:nameStr forKey:USER_NAME];
                [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"current_client_id"] forKey:USER_CLIENT_ID];
            }
            
        }];
    }
    else
    {
//        [ShowMessage showMessage:@"disconnect chatroom"];
    }
    
}

- (void)listenNetWorkingPort
{
    for (NSInteger i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
            [self getMessageInRoom:@"" roomId:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]];
            if (i == [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]-1) {
                UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
                userInfomationData.isReconnectionStr = @"yes";
            }
        }
        
    }
}

#pragma mark ======== 断线重连 =========
- (void)reconntionSignlar
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"closedsocket"]){
//        [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
        [MMProgressHUD showWithTitle:@"connecting" status:NSLocalizedString(@"Please wating", nil)];
        [userInfomationData.timer invalidate];
        userInfomationData.timer = nil;
        userInfomationData.hubConnection = nil;
        [self connectionSignlar];
        self.reConnectionTag = @"reConnetion";
    }
}

#pragma mark ======== 某人加入聊天室通知 =========
- (void)onUserJoinRoom:(NSDictionary *)msg
{
    NSLog(@"-------join %@",msg);
//    [ShowMessage showMessage:[NSString stringWithFormat:@"%@ Join",[[msg objectForKey:@"user"] objectForKey:@"user_name"]]];
}

#pragma mark ======== 某人离开聊天室通知 =========
- (void)onUserLeaveRoom:(NSDictionary *)msg
{
    NSLog(@"------- Leave%@",msg);
//    [ShowMessage showMessage:[NSString stringWithFormat:@"%@ Leave",[[msg objectForKey:@"user"] objectForKey:@"user_name"]]];
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
        NSLog(@"收到消息----%@-%@---%@",[msg objectForKey:@"user_avatar"],[msg objectForKey:@"room_id"],[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]);
        
        userInfomationData.inRoomMessageForRoomIdStr = [msg objectForKey:@"room_id"];
        
        if (![[msg objectForKey:@"client_id"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:USER_CLIENT_ID]]) {
            NSString *nameStr;
            if ([CommonService isBlankString:[msg objectForKey:@"name"]] || [CommonService isBlankString:[msg objectForKey:@"surname"]]) {
                nameStr = [msg objectForKey:@"user_name"];
            }
            else
            {
                nameStr = [NSString stringWithFormat:@"%@ %@.",[msg objectForKey:@"name"],[[msg objectForKey:@"surname"] substringToIndex:1].uppercaseString];
            }
            [self.myAppDelegate insertCoreData:[msg objectForKey:@"user_id"] avatarImage:[NSString stringWithFormat:@"%@?%@",[msg objectForKey:@"user_avatar"],@"width=300&height=300"] roomId:[msg objectForKey:@"room_id"] time:[NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]] message:[arr objectAtIndex:1] messageId:[msg objectForKey:@"id"] fromUserName:nameStr like:[msg objectForKey:@"like"]];
        }
        else
        {
            //更新数据库一条消息
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
            //  2.设置排序
            //  2.1创建排序描述对象
//            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//            request.sortDescriptors = @[sortDescriptor];
            NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
            request.sortDescriptors = @[sortDescriptors];
            NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@ AND messageId = %@",roomId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],[msg objectForKey:@"id"]]];
            request.fetchOffset=0;
            request.fetchLimit=1000;
            request.predicate = predicate;
            
            //  执行这个查询请求
            NSError *error = nil;
            
            NSArray *result = [self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error];
            NSLog(@"xxxxcx-hahah--commonservice-%@===%@ --%lu---",roomId,[msg objectForKey:@"id"],(unsigned long)[result count]);
            
            if ([result count] != 0) {
                for (NSInteger i = 0; i < [result count]; i ++) {
                    NSString *nameStr;
                    if ([CommonService isBlankString:[msg objectForKey:@"name"]] || [CommonService isBlankString:[msg objectForKey:@"surname"]]) {
                        nameStr = [msg objectForKey:@"user_name"];
                    }
                    else
                    {
                        nameStr = [NSString stringWithFormat:@"%@ %@.",[msg objectForKey:@"name"],[[msg objectForKey:@"surname"] substringToIndex:1].uppercaseString];
                    }
                    Mic *mic = result[0];
                    NSLog(@"xxxxxx-*-*-------  ^%@",mic.messageId);
                    mic.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID];
                    mic.userId = [msg objectForKey:@"user_id"];
                    mic.avatarImage = NULL_TO_NIL([msg objectForKey:@"user_avatar"]);
                    mic.roomId = [msg objectForKey:@"room_id"];
                    mic.isRead = [msg objectForKey:@"like"];
                    mic.isReadReady = 0;
                    mic.time = [NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]];
                    mic.message = [arr objectAtIndex:1];
                    mic.messageId = [msg objectForKey:@"id"];
                    mic.fromUserName = nameStr;
                    [self.myAppDelegate saveContext];
                }
            }
            else
            {
                NSString *nameStr;
                if ([CommonService isBlankString:[msg objectForKey:@"name"]] || [CommonService isBlankString:[msg objectForKey:@"surname"]]) {
                    nameStr = [msg objectForKey:@"user_name"];
                }
                else
                {
                    nameStr = [NSString stringWithFormat:@"%@ %@.",[msg objectForKey:@"name"],[[msg objectForKey:@"surname"] substringToIndex:1].uppercaseString];
                }
                [self.myAppDelegate insertCoreData:[msg objectForKey:@"user_id"] avatarImage:[NSString stringWithFormat:@"%@?%@",[msg objectForKey:@"user_avatar"],@"width=300&height=300"] roomId:[msg objectForKey:@"room_id"] time:[NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]] message:[arr objectAtIndex:1] messageId:[msg objectForKey:@"id"] fromUserName:nameStr like:[msg objectForKey:@"like"]];
                
                for (NSInteger i = 0; i < 10; i++) {
                    [self.myAppDelegate deletePreLoadingMessage:roomId message:[NSString stringWithFormat:@"%lld",userInfomationData.yuMessageId-i]];
                }
                
//                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
//                //  2.设置排序
//                //  2.1创建排序描述对象
//                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//                request.sortDescriptors = @[sortDescriptor];
//                NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
//                NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@ AND messageId = %@",roomId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],@"84113604084776960"]];
//                request.fetchOffset=0;
//                request.fetchLimit=1000;
//                request.predicate = predicate;
//                NSLog(@"789456465165456489466");
//                //  执行这个查询请求
//                NSError *error = nil;
//                
//                NSArray *resultx = [self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error];
//                NSLog(@"--*-*-*-*--fsdfsdfdf----  %@",result);
//                
//                for (NSInteger i = 0; i < [resultx count]; i ++) {
//                    
//                    Mic *mic = resultx[0];
//                    for (NSInteger i = 0; i < [userInfomationData.waitingSendMessageQunenMutableArr count]; i ++) {
//                        if ([[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:i] objectForKey:@"message_id"] isEqualToString:mic.messageId] && [[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:i] objectForKey:@"room_id"] isEqualToString:[msg objectForKey:@"room_id"]]) {
//                            [userInfomationData.waitingSendMessageQunenMutableArr removeObjectAtIndex:i];
//                            return;
//                        }
//                    }
//                    
//
//                    NSLog(@"xxxxxx-*-*-------  ^%@",mic.messageId);
//                    mic.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID];
//                    mic.userId = [msg objectForKey:@"user_id"];
//                    mic.avatarImage = NULL_TO_NIL([msg objectForKey:@"user_avatar"]);
//                    mic.roomId = [msg objectForKey:@"room_id"];
//                    mic.isRead = 0;
//                    mic.time = [NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]];
//                    mic.message = [arr objectAtIndex:1];
//                    mic.messageId = [msg objectForKey:@"id"];
//                    mic.fromUserName = [msg objectForKey:@"user_name"];
//                    [self.myAppDelegate saveContext];
//                }
            }
            
            
        }
        
        //活动列表后的未读消息小红点标记
        
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@",@"red",[msg objectForKey:@"room_id"]]];
        if ([userInfomationData.isEnterMicList isEqualToString:@"true"] && [[msg objectForKey:@"room_id"] isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
        }
    }
    
}

#pragma mark ======== 喜欢一条消息 =========
- (void)onUserLikeMessage:(NSDictionary *)message
{
    NSLog(@"----saaaadafdsfas--- %@",message);
    self.myAppDelegate.showTipsLabel.text = [NSString stringWithFormat:@"%@ like you message",[message objectForKey:@"user_name"]];
    NSString *currentRroomIdStr;
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
        currentRroomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    }
    else
    {
        for (NSInteger i = 0; i < [(NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
            if ([userInfomationData.QRRoomId isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                currentRroomIdStr = userInfomationData.QRRoomId;
            }
        }
    }
    
    if ([[[message objectForKey:@"message"] objectForKey:@"room_id"] isEqualToString:currentRroomIdStr]) {
        userInfomationData.getUsersLikesCountInRoom = [NSString stringWithFormat:@"%d",[userInfomationData.getUsersLikesCountInRoom integerValue]+1];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onGetLikesCountInRoom" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"belike" object:self];
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.myAppDelegate.showTipsView.frame = CGRectMake(0, -10, SCREEN_WIDTH, 60);
    } completion:^(BOOL finished) {
    }];
    [self performSelector:@selector(closedShowTipsView) withObject:nil afterDelay:2.0f];
}

- (void)closedShowTipsView
{
    [UIView animateWithDuration:0.5 animations:^{
        self.myAppDelegate.showTipsView.frame = CGRectMake(0, -70, SCREEN_WIDTH, 60);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark ======== 屏蔽一条消息 =========
- (void)onBlockUser:(NSDictionary *)msg
{
    NSLog(@"----xxxxdfasdfsdfx--- %@",msg);
}

#pragma mark ======== 取消屏蔽一条消息 =========
- (void)onCancelBlockUser:(NSDictionary *)msg
{
    NSLog(@"---ssssssdfsdfsds---- %@",msg);
}

#pragma mark ======== 扫描后，加入聊天室 =========
- (void)joinRoom:(NSString *)roomId
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        userInfomationData.QRRoomId = roomId;
        //    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        [userInfomationData.chat invoke:@"joinRoom" withArgs:@[roomId] completionHandler:^(id response, NSError *error) {
            if (error) {
                NSLog(@"加入聊天室失败--- %@",error.description);
//                [MMProgressHUD dismissWithError:@"join chatroom,try again" afterDelay:2.0f];
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
                [self.myAppDelegate subscribeToTopic:value];
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
    else
    {
//        [ShowMessage showMessage:@"disconnect chatroom"];
    }
    
}

#pragma mark ======== 在聊天室内，发送消息 =========
- (void)sendMessageInRoom:(NSString *)messgae roomId:(NSString *)roomIdContent messageType:(NSInteger)messageType messageId:(NSString *)messageIdx
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageScu" object:self];
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        NSLog(@"-*-/-*-*-*- ----  %@",messgae);
        [userInfomationData.chat invoke:@"sendMessageInRoom" withArgs:@[messgae,roomIdContent,[NSNumber numberWithInteger:messageType]] completionHandler:^(id response, NSError *error) {
            
            if (error) {
                [ShowMessage showMessage:@"message sending failed"];
                [self.myAppDelegate deletePreLoadingMessage:roomIdContent message:messageIdx];
                for (NSInteger i = 0; i < [userInfomationData.waitingSendMessageQunenMutableArr count]; i ++) {
                    if ([[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:i] objectForKey:@"message_id"] isEqualToString:messgae] && [[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:i] objectForKey:@"room_id"] isEqualToString:roomIdContent]) {
                        [userInfomationData.waitingSendMessageQunenMutableArr removeObjectAtIndex:i];
                        return ;
                    }
                }
                //                [self.myAppDelegate deleteAllPreLoadingMessage];
                NSLog(@"xxxxxxxxxxx发送失败----%@----%@",error.description,messageIdx);
                return;
            }
            if (response == NULL) {
                return;
            }
            
            
            [ShowMessage showMessage:@"message sent successfully"];
            NSLog(@"发送消息-*-*-*-*-*-*-*-*-*-*  %@",response);
            
            for (NSInteger x = 0; x < [userInfomationData.waitingSendMessageQunenMutableArr count]; x ++) {
                //                NSLog(@"*--*-*-*-*-*- %@---%@",[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:i] objectForKey:@"message_id"],messgae)
                if ([[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:x] objectForKey:@"message_id"] isEqualToString:messageIdx] && [[[userInfomationData.waitingSendMessageQunenMutableArr objectAtIndex:x] objectForKey:@"room_id"] isEqualToString:roomIdContent]) {
                    [userInfomationData.waitingSendMessageQunenMutableArr removeObjectAtIndex:x];
                    
                    //更新数据库一条消息
                    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
                    //  2.设置排序
                    //  2.1创建排序描述对象
//                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//                    request.sortDescriptors = @[sortDescriptor];
                    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
                    request.sortDescriptors = @[sortDescriptors];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@ AND messageId = %@",roomIdContent,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],messageIdx]];
                    request.fetchOffset=0;
                    request.fetchLimit=1000;
                    request.predicate = predicate;
                    
                    //  执行这个查询请求
                    NSError *error = nil;
                    
                    NSArray *result = [self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error];
                    NSLog(@"xxxxcx---发送消息成功-%@===%@ --%lu---",roomIdContent,messageIdx,(unsigned long)[result count]);
                    
                    for (NSInteger i = 0; i < [result count]; i ++) {
                        
                        Mic *mic = result[0];
                        NSLog(@"xxxxxx-*-*-------  ^%@---- %@",mic.messageId,response);
                        mic.messageId = response;
                        NSLog(@"xxxxxx-*-*------hahah-  ^%@----- %@",mic.messageId,response);
                        [self.myAppDelegate saveContext];
                    }
                    return;
                }
                
            }

            
        }];
    }
    else
    {
//        [ShowMessage showMessage:@"disconnect chatroom"];
    }
    
}
#pragma mark ======== 断线重连后，拉取所有房间的历史消息 =========
- (void)getMessageInRoomReconnection:(NSString *)lastMessageId roomId:(NSString *)roomIdContent
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"] && ![CommonService isBlankString:roomIdContent]) {
        
        
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        userInfomationData.apiRoomIdStr = roomIdContent;
        NSLog(@"***-------  %@",roomIdContent);
        [userInfomationData.chat invoke:@"getMessagesInRoom" withArgs:@[roomIdContent,@"Audio",lastMessageId,@"20"] completionHandler:^(id response, NSError *error) {
                if (error) {
                    NSLog(@"xxxxxxxxxxx----%@",error.description);
                    [MMProgressHUD dismissWithError:@"Error"];
                    if ([userInfomationData.isEnterMicList isEqualToString:@"true"]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                    }
                    return;
                }
                if (response == NULL) {
                    return;
                }
                if ([response isKindOfClass:[NSArray class]])
                {
                    userInfomationData.getApiMicCount = [response count];
                    if ([response count] > 0) {
                        for (NSInteger i = 0;i < [response count] ; i ++) {
                            NSArray *arr = [[NSArray alloc] init];
                            arr = [[[(NSArray *)response objectAtIndex:i] objectForKey:@"content"] componentsSeparatedByString:@","];
                            if ([[[response objectAtIndex:i] objectForKey:@"message_type"] isEqualToString:@"Audio"] && [arr count]==2) {
                                NSString *nameStr;
                                if ([CommonService isBlankString:[[response objectAtIndex:i] objectForKey:@"name"]] || [CommonService isBlankString:[[response objectAtIndex:i] objectForKey:@"surname"]]) {
                                    nameStr = [[response objectAtIndex:i] objectForKey:@"user_name"];
                                    
                                }
                                else
                                {
                                    nameStr = [NSString stringWithFormat:@"%@ %@.",[[response objectAtIndex:i] objectForKey:@"name"],[[[response objectAtIndex:i] objectForKey:@"surname"] substringToIndex:1].uppercaseString];
                                }
                                
                                [self.myAppDelegate insertCoreData:[[response objectAtIndex:i] objectForKey:@"user_id"] avatarImage:[NSString stringWithFormat:@"%@?%@",[[response objectAtIndex:i] objectForKey:@"user_avatar"],@"width=300&height=300"] roomId:[[response objectAtIndex:i] objectForKey:@"room_id"] time:[NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]] message:[arr objectAtIndex:1] messageId:[[response objectAtIndex:i] objectForKey:@"id"] fromUserName:nameStr like:[[response objectAtIndex:i] objectForKey:@"like"]];
                                [self.myAppDelegate insertCoraData:[[response objectAtIndex:i] objectForKey:@"room_id"] lastMessageId:[[response objectAtIndex:[response count]-1] objectForKey:@"id"] beginMessageId:[[response objectAtIndex:0] objectForKey:@"id"]];
                                userInfomationData.inRoomMessageForRoomIdStr = [[response objectAtIndex:i] objectForKey:@"room_id"];
                                
                            }
                        }
                    }
                }
            
        }];
    }
    else
    {
        //        [ShowMessage showMessage:@"disconnect chatroom"];
    }
    
}


#pragma mark ======== 进入聊天室时，获取历史消息 =========
- (void)getMessageInRoom:(NSString *)lastMessageId roomId:(NSString *)roomIdContent
{
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"] && ![CommonService isBlankString:roomIdContent]) {
        
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        userInfomationData.apiRoomIdStr = roomIdContent;
        NSLog(@"***-------  %@",roomIdContent);
        [userInfomationData.chat invoke:@"getMessagesInRoom" withArgs:@[roomIdContent,@"Audio",lastMessageId,@"20"] completionHandler:^(id response, NSError *error) {
            if (error) {
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                [MMProgressHUD dismissWithError:@"Error"];
                if ([userInfomationData.isEnterMicList isEqualToString:@"true"]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                }
                return;
            }
            if (response == NULL) {
                return;
            }
            if ([response isKindOfClass:[NSArray class]])
            {
                userInfomationData.getApiMicCount = [response count];
                if ([response count] > 0) {
                    for (NSInteger i = 0;i < [response count] ; i ++) {
                        NSArray *arr = [[NSArray alloc] init];
                        arr = [[[(NSArray *)response objectAtIndex:i] objectForKey:@"content"] componentsSeparatedByString:@","];
                        if ([[[response objectAtIndex:i] objectForKey:@"message_type"] isEqualToString:@"Audio"] && [arr count]==2) {
                            NSString *nameStr;
                            if ([CommonService isBlankString:[[response objectAtIndex:i] objectForKey:@"name"]] || [CommonService isBlankString:[[response objectAtIndex:i] objectForKey:@"surname"]]) {
                                nameStr = [[response objectAtIndex:i] objectForKey:@"user_name"];
                                
                            }
                            else
                            {
                                nameStr = [NSString stringWithFormat:@"%@ %@.",[[response objectAtIndex:i] objectForKey:@"name"],[[[response objectAtIndex:i] objectForKey:@"surname"] substringToIndex:1].uppercaseString];
                            }
                            [self.myAppDelegate insertCoreData:[[response objectAtIndex:i] objectForKey:@"user_id"] avatarImage:[NSString stringWithFormat:@"%@?%@",[[response objectAtIndex:i] objectForKey:@"user_avatar"],@"width=300&height=300"] roomId:[[response objectAtIndex:i] objectForKey:@"room_id"] time:[NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]] message:[arr objectAtIndex:1] messageId:[[response objectAtIndex:i] objectForKey:@"id"] fromUserName:nameStr like:[[response objectAtIndex:i] objectForKey:@"like"]];
                            [self.myAppDelegate insertCoraData:[[response objectAtIndex:i] objectForKey:@"room_id"] lastMessageId:[[response objectAtIndex:[response count]-1] objectForKey:@"id"] beginMessageId:[[response objectAtIndex:0] objectForKey:@"id"]];
                            userInfomationData.inRoomMessageForRoomIdStr = [[response objectAtIndex:i] objectForKey:@"room_id"];
                            
                        }
                    }
                    
                    if ([userInfomationData.isEnterMicList isEqualToString:@"true"] && [userInfomationData.currtentRoomIdStr isEqualToString:userInfomationData.apiRoomIdStr]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
                    }
                }
            }
            
//            else {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryList" object:self];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
//            }
            if (![self.reConnectionTag isEqualToString:@"reConnetion"]) {
                [MMProgressHUD dismiss];
            }
            
            
        }];
    }
    else
    {
//        [ShowMessage showMessage:@"disconnect chatroom"];
    }
    
}

#pragma mark ======== 反馈意见 =========
- (void)sendFeedback:(NSString *)feedbackContent
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.chat invoke:@"sendFeedback" withArgs:@[feedbackContent] completionHandler:^(id response, NSError *error) {
            if (error) {
                [ShowMessage showMessage:@"feedback sending fail"];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            if (response == NULL) {
                return;
            }
            [ShowMessage showMessage:@"feedback sent successfully"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendFeedbackScu" object:self];
        }];
    }
    else
    {
        [ShowMessage showMessage:@"disconnect chatroom"];
    }
    
}

#pragma mark ======== 喜欢一条消息 =========
- (void)likeMessage:(NSString *)likeMessageId
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.chat invoke:@"likeMessage" withArgs:@[likeMessageId] completionHandler:^(id response, NSError *error) {
            if (error) {
                [ShowMessage showMessage:@"likeMessage fail"];
                userInfomationData.likeMessageId = @"";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"likeResultFaile" object:self];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            if (response == NULL) {
                return;
            }
            userInfomationData.likeMessageIdSucess = userInfomationData.likeMessageId;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"likeResultSucess" object:self];
            [ShowMessage showMessage:@"likeMessage successfully"];
        }];
    }
    else
    {
        [ShowMessage showMessage:@"disconnect chatroom"];
    }
}

#pragma mark ======== 屏蔽一个人的所有发言 =========
- (void)blockUser:(NSString *)blockUserId
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.chat invoke:@"blockUser" withArgs:@[blockUserId] completionHandler:^(id response, NSError *error) {
            if (error) {
                [ShowMessage showMessage:@"blockUser fail"];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            if (response == NULL) {
                return;
            }
            [self getBlockUsers:@"no"];
            [ShowMessage showMessage:@"blockUser successfully"];
        }];
    }
    else
    {
        [ShowMessage showMessage:@"disconnect chatroom"];
    }
}

#pragma mark ======== 取消屏蔽一个人的所有发言 =========
- (void)cancelBlockUser:(NSString *)cancelBlockUserId
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.chat invoke:@"cancelBlockUser" withArgs:@[cancelBlockUserId] completionHandler:^(id response, NSError *error) {
            if (error) {
                [ShowMessage showMessage:@"cancelBlockUser fail"];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            if (response == NULL) {
                return;
            }
            [self getBlockUsers:@"no"];
            [ShowMessage showMessage:@"cancelBlockUser successfully"];
        }];
    }
    else
    {
        [ShowMessage showMessage:@"disconnect chatroom"];
    }
}

#pragma mark ======== 获取当前用户屏蔽发言人的列表 =========
- (void)getBlockUsers:(NSString *)isShowMessage
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.chat invoke:@"getBlockUsers" withArgs:@[] completionHandler:^(id response, NSError *error) {
            if (error) {
                if ([isShowMessage isEqualToString:@"yes"]) {
                    [ShowMessage showMessage:@"getBlockUsers fail"];
                }
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            if (response == NULL) {
                return;
            }
            if (!error && [response isKindOfClass:[NSArray class]]) {
                NSLog(@"屏蔽用户列表:%@",response);
                [[NSUserDefaults standardUserDefaults] setObject:[CommonService processDictionaryIsNSNull:response] forKey:@"blockUsersList"];
                userInfomationData.blockUsersMutableArr = [[NSMutableArray alloc] initWithCapacity:10];
                NSLog(@"x-*-df*s-d*f-s*f-s*d-a*------- %ld---%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"blockUsersList"] count],[[NSUserDefaults standardUserDefaults] objectForKey:@"blockUsersList"]);
                for (NSInteger i = 0; i < [[[NSUserDefaults standardUserDefaults] objectForKey:@"blockUsersList"] count]; i++) {
                    [userInfomationData.blockUsersMutableArr addObject:[[[NSUserDefaults standardUserDefaults] objectForKey:@"blockUsersList"] objectAtIndex:i]];
                }
                if ([isShowMessage isEqualToString:@"yes"]) {
//                    [ShowMessage showMessage:@"getBlockUsers successfully"];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"blockUserSucess" object:self];
                }
            }
            
            
        }];
    }
    else
    {
        [ShowMessage showMessage:@"disconnect chatroom"];
    }
}

#pragma mark ======== 获取一个聊天室中被用户喜欢的数量 =========
- (void)getUserLikesCountInRoom:(NSString *)roomId
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.chat invoke:@"getUserLikesCountInRoom" withArgs:@[roomId] completionHandler:^(id response, NSError *error) {
            if (error) {
                [ShowMessage showMessage:@"getUserLikesCountInRoom fail"];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            if (response == NULL) {
                return;
            }
            NSLog(@"ahhahahhadfasdf-*-----  %@",response);
            if ([response isKindOfClass:[NSString class]])
            {
                userInfomationData.getUsersLikesCountInRoom = response;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onGetLikesCountInRoom" object:self];
            }
            
            
        }];
    }
    else
    {
//        [ShowMessage showMessage:@"disconnect chatroom"];
    }
}

#pragma mark ======== 获取一个聊天室中被用户喜欢的列表 =========
- (void)getUserLikesInRoom:(NSString *)roomId lastLikeId:(NSString *)lastLikeIdContent count:(NSString *)countContent
{
    NSLog(@"adfasfas-*--*---*-*-*----- %@",roomId);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"open"]) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.chat invoke:@"getUserLikesInRoom" withArgs:@[roomId,lastLikeIdContent,countContent] completionHandler:^(id response, NSError *error) {
            if (error) {
                [ShowMessage showMessage:@"getUserLikesInRoom fail"];
                NSLog(@"xxxxxxxxxxx----%@",error.description);
                return;
            }
            if (response == NULL) {
                return;
            }
            NSLog(@"ahhahahhadfasdfxxxxxx-*-----  %@",response);
            if ([response isKindOfClass:[NSArray class]])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onGetLikesInRoom" object:self];
                for (NSInteger i = 0; i < [response count]; i ++) {
                    [userInfomationData.getUsersLikesInRoomMutableArr addObject:[response objectAtIndex:i]];
                }
            }
            
            
        }];
    }
    else
    {
//        [ShowMessage showMessage:@"disconnect chatroom"];
    }
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
+ (id) processDictionaryIsNSNull:(id)obj{
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
