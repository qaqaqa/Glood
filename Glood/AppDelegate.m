//
//  AppDelegate.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/26.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "UserInfomationData.h"
#import "NetworkingTools.h"
#import "Mic.h"
#import "Node.h"
#import "Define.h"
#import <Bugly/Bugly.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AvoidCrash.h>
#import "ShowMessage.h"
@import Firebase;
@import FirebaseMessaging;
@import UserNotifications;

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIView *tipsView;
@property (strong, nonatomic) UIView *networkDisBGView;
@property (strong, nonatomic) NSString *isEnterGroundStr;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    [Bugly startWithAppId:@"900016269"];
    [AvoidCrash becomeEffective];
//    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"signlarStauts"];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    self.isEnterGroundStr = @"no";
    self.commonService = [[CommonService alloc] init];
    self.recordAudio = [[RecordAudio alloc] init];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.commonService = self.commonService;
    userInfomationData.recordAudio = self.recordAudio;
    userInfomationData.micMockListPageIndex = 1; //每次进入应用程序时，当前分页置为0
    userInfomationData.currentPage = 1;
    userInfomationData.mockViewNameLabelIsHiddenStr = @"no";
    
    [[UIApplication sharedApplication] setStatusBarHidden: YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.viewVC = [[ViewController alloc] init];
    userInfomationData.viewVC = self.viewVC;
    self.navigateC = [[UINavigationController alloc] initWithRootViewController:self.viewVC];
    self.window.rootViewController = self.navigateC;
    [self.window makeKeyAndVisible];
    
    self.tipsView = [[UIView alloc] init];
    self.tipsView.frame = CGRectMake(0, 0, self.window.frame.size.width, 44);
    self.tipsView.backgroundColor = [UIColor blackColor];
    [self.tipsView setHidden:YES];
    [self.window addSubview:self.tipsView];
    
    self.networkDisBGView = [[UIView alloc] init];
    self.networkDisBGView.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    self.networkDisBGView.backgroundColor = [UIColor blackColor];
    self.networkDisBGView.alpha = 0.1;
    [self.networkDisBGView setHidden:YES];
    [self.window addSubview:self.networkDisBGView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tipsView.frame.size.width, self.tipsView.frame.size.height)];
    label.text = @"network disconnect";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.tipsView addSubview:label];
    [self performSelector:@selector(listenNetWorkingPort) withObject:nil afterDelay:0.35f];
    
    userInfomationData.isGetMicListMutableArr = [[NSMutableArray alloc] initWithCapacity:10];
    
    userInfomationData.waitingSendMessageQunenMutableDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    userInfomationData.waitingSendMessageQunenMutableArr = [[NSMutableArray alloc] initWithCapacity:10];
    userInfomationData.yuMessageId = 9223372036854775000;
    NSLog(@"*-*-*-*---xxxxx-*x-  %lld",userInfomationData.yuMessageId);
    
    UNAuthorizationOptions authOptions =
    UNAuthorizationOptionAlert
    | UNAuthorizationOptionSound
    | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
    }];
    
    // For iOS 10 display notification (sent via APNS)
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    // For iOS 10 data message (sent via FCM)
//    [FIRMessaging messaging].remoteMessageDelegate = self;
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    [FIRApp configure];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    application.applicationIconBadgeNumber = 0;
    if( SYSTEM_VERSION_LESS_THAN( @"10.0" ) )
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |    UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        //if( option != nil )
        //{
        //    NSLog( @"registerForPushWithOptions:" );
        //}
    }
    else
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
         {
             if( !error )
             {
                 [[UIApplication sharedApplication] registerForRemoteNotifications];  // required to get the app to do anything at all about push notifications
                 NSLog( @"Push registration success." );
             }
             else
             {
                 NSLog( @"Push registration FAILED" );
                 NSLog( @"ERROR: %@ - %@", error.localizedFailureReason, error.localizedDescription );
                 NSLog( @"SUGGESTIONS: %@ - %@", error.localizedRecoveryOptions, error.localizedRecoverySuggestion );  
             }  
         }];  
    }
    
    self.showTipsView = [[UIView alloc] init];
    self.showTipsView.frame = CGRectMake(0, -70, SCREEN_WIDTH, 60);
    self.showTipsView.layer.masksToBounds = YES;
    self.showTipsView.layer.cornerRadius = 5;
    self.showTipsView.backgroundColor = [UIColor whiteColor];
    self.showTipsView.alpha = 0.9;
    [self.window addSubview:self.showTipsView];
    
    self.showTipsLabel = [[UILabel alloc] init];
    self.showTipsLabel.frame = CGRectMake(0, 10, self.showTipsView.frame.size.width, self.showTipsView.frame.size.height-10);
    self.showTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.showTipsLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
    self.showTipsLabel.userInteractionEnabled = YES;
    [self.showTipsView addSubview:self.showTipsLabel];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.showTipsLabel addGestureRecognizer:recognizer];
    
    return YES;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.5 animations:^{
        self.showTipsView.frame = CGRectMake(0, -70, SCREEN_WIDTH, 60);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark ============    通知，订阅主题 推送消息    ===========
- (void)subscribeToTopic:(NSDictionary*)dic
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSUserDefaults standardUserDefaults] setObject:@"open" forKey:@"signlarStauts"];
        for (NSInteger i = 0; i < [[dic objectForKey:@"result"] count]; i ++) {
            [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/events-%@",[[[dic objectForKey:@"result"] objectAtIndex:i] objectForKey:@"id"]]];
            NSLog(@"Subscribed to news topic");
        }
        
        //订阅喜欢消息的通知
        NSLog(@"xxxixixixixxiiiii---------%@",[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]);
        [[FIRMessaging messaging] subscribeToTopic:[NSString stringWithFormat:@"/topics/users-%@-like",[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
        
    });
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"received-*-*-*--*-*-*-*%@",response.notification.request.content.userInfo);
    [[NSUserDefaults standardUserDefaults] setObject:response.notification.request.content.userInfo forKey:@"pushUserInfo"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"becomeActive" object:self];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);

    // Print full message.
    NSLog(@"hahahah---收到消息：%@---- %@", [userInfo objectForKey:@"topic"], userInfo);
    if ([[userInfo objectForKey:@"from"] rangeOfString:@"/topics/events-"].location !=NSNotFound) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        NSDictionary *msg = [[NSDictionary alloc] init];
        msg = [self dictionaryWithJsonString:[userInfo objectForKey:@"message"]];
        NSLog(@"adfasd-f*as-f*-a*----  %@",msg);
        if (msg != nil) {
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
                    [self insertCoreData:[msg objectForKey:@"user_id"] avatarImage:[NSString stringWithFormat:@"%@?%@",[msg objectForKey:@"user_avatar"],@"width=300&height=300"] roomId:[msg objectForKey:@"room_id"] time:[NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]] message:[arr objectAtIndex:1] messageId:[msg objectForKey:@"id"] fromUserName:nameStr like:[msg objectForKey:@"like"]];
                    if ([[arr objectAtIndex:1] rangeOfString:@"https://"].location !=NSNotFound) {
                        //需要下载amr语音
                        [userInfomationData.recordAudio saveRecordAmr:[arr objectAtIndex:1] messageId:[msg objectForKey:@"id"]isNotifiction:@"no"];
                    }
                    
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
                    
                    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
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
                            [self saveContext];
                            if ([[arr objectAtIndex:1] rangeOfString:@"https://"].location !=NSNotFound) {
                                //需要下载amr语音
                                [userInfomationData.recordAudio saveRecordAmr:[arr objectAtIndex:1] messageId:[msg objectForKey:@"id"]isNotifiction:@"no"];
                            }
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
                        [self insertCoreData:[msg objectForKey:@"user_id"] avatarImage:[NSString stringWithFormat:@"%@?%@",[msg objectForKey:@"user_avatar"],@"width=300&height=300"] roomId:[msg objectForKey:@"room_id"] time:[NSNumber numberWithFloat:[[arr objectAtIndex:0] floatValue]] message:[arr objectAtIndex:1] messageId:[msg objectForKey:@"id"] fromUserName:nameStr like:[msg objectForKey:@"like"]];
                        if ([[arr objectAtIndex:1] rangeOfString:@"https://"].location !=NSNotFound) {
                            //需要下载amr语音
                            [userInfomationData.recordAudio saveRecordAmr:[arr objectAtIndex:1] messageId:[msg objectForKey:@"id"]isNotifiction:@"no"];
                        }
                        for (NSInteger i = 0; i < 10; i++) {
                            [self deletePreLoadingMessage:roomId message:[NSString stringWithFormat:@"%lld",userInfomationData.yuMessageId-i]];
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
        
    }
    
}

//- (void)userNotificationCenter:(UNUserNotificationCenter *)center
//       willPresentNotification:(UNNotification *)notification
//         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
//    // Print message ID.
//    NSDictionary *userInfo = notification.request.content.userInfo;
//    if (userInfo[@"com.aton.MyPushNotifications"]) {
//        NSLog(@"Message ID: %@", userInfo[@"com.aton.MyPushNotifications"]);
//    }
//    // Print full message.
//    NSLog(@"xxxxxxxxxx----收到消息：%@---- %@", userInfo,[userInfo objectForKey:@"from"]);
//    if ([[userInfo objectForKey:@"from"] rangeOfString:@"/topics/events-"].location !=NSNotFound) {
//        
//    }
//    
//    // Change this to your preferred presentation option
//    completionHandler(UNNotificationPresentationOptionNone);
//    
//}


//- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
//    // Print full message
//    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//    
//    content.title = @"Message received";
//    content.body = @"Message body";
//    content.sound = [UNNotificationSound defaultSound];
//    
//    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
//    
//    UNNotificationRequest* request = [UNNotificationRequest
//                                      requestWithIdentifier:@"MorningAlarm" content:content trigger:trigger];
//    
//    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
//    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"%@", error.localizedDescription);
//        }
//    }];
//    
//}


- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    [[NSUserDefaults standardUserDefaults] setObject:refreshedToken forKey:@"deviceToken"];
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to application server.
}

- (void)connectToFcm {
    // Won't connect since there is no token
    if (![[FIRInstanceID instanceID] token]) {
        return;
    }
    
    // Disconnect previous FCM connection if it exists.
    [[FIRMessaging messaging] disconnect];
    
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ];
    // 在此添加任意自定义逻辑。
    return handled;
}

- (void)listenNetWorkingPort{
    [[NSURLCache sharedURLCache] setMemoryCapacity:5 * 1024 * 1024];
    [[NSURLCache sharedURLCache] setDiskCapacity:50 * 1024 * 1024];
    
    AFHTTPRequestOperationManager * manager = [NetworkingTools sharedManager];
    
    // 设置网络状态变化回调
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        
        
        if (status == AFNetworkReachabilityStatusNotReachable ||status ==  AFNetworkReachabilityStatusUnknown)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showMenu" object:nil];
            self.networkStatus = @"lost";
            manager.requestSerializer.cachePolicy =  NSURLRequestReturnCacheDataDontLoad;
            [self.tipsView setHidden:NO];
            [self.networkDisBGView setHidden:NO];
            [[NSUserDefaults standardUserDefaults] setObject:@"closed" forKey:@"signlarStauts"];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hideMenu" object:nil];
            self.networkStatus = @"connetion";
            [self.tipsView setHidden:YES];
            [self.networkDisBGView setHidden:YES];
        }
    }];
    
    // 启动网络状态监听
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"device token:%@",deviceToken);
    [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
    
    NSString *tokenStr = [[NSString stringWithFormat:@"%@",deviceToken] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"regisger success:%@",tokenStr);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self connectToFcm];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"signlarStauts"] isEqualToString:@"closed"] && [self.isEnterGroundStr isEqualToString:@"yes"]) {
        self.isEnterGroundStr = @"no";
        [userInfomationData.commonService reconntionSignlar];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.sparxo.vambie.Glood" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Glood" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Glood2.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                              NSInferMappingModelAutomaticallyOption:@(YES)};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    NSError *error = nil;
    [managedObjectContext save:&error];
//    if (managedObjectContext != nil) {
//        NSError *error = nil;
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//    }
}


#pragma mark ====== 插入数据库======
- (void)insertCoreData:(NSString *)userIdx avatarImage:(NSString *)avatarImagex roomId:(NSString *)roomIdx time:(NSNumber *)timex
               message:(NSString *)messagex messageId:(NSString *)messageIdx fromUserName:(NSString *) fromUserNamex like:(NSNumber *)likeMessage
{
    //查询数据库，如果当前需要插入的messageid在数据库不存在，则
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"accountId = %@ AND roomId = %@ AND messageId = %@",[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],roomIdx,messageIdx]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"accountId = %@ AND messageId = %@",[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],messageIdx]];
    request.predicate = predicate;
    
//    NSFetchRequest *requestxx = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
//    NSPredicate *predicatexx = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"accountId = %@ AND roomId = %@",[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],roomIdx]];
//    requestxx.predicate = predicatexx;
    //  执行这个查询请求
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if ([result count] == 0) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        if (![userInfomationData.currtentRoomIdStr isEqualToString:roomIdx]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@",@"red",roomIdx]];
        }
        //  创建实体描述对象
        NSEntityDescription *description = [NSEntityDescription entityForName:@"Mic" inManagedObjectContext:self.managedObjectContext];
        //  1.先创建一个模型对象
        
        Mic *mic = [[Mic alloc] initWithEntity:description insertIntoManagedObjectContext:self.managedObjectContext];
        mic.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID];
        mic.userId = userIdx;
        mic.avatarImage = NULL_TO_NIL(avatarImagex);
        mic.roomId = roomIdx;
        mic.isRead = likeMessage;
        mic.isReadReady = @0;
        mic.time = timex;
        mic.message = messagex;
        mic.messageId = messageIdx;
        mic.fromUserName = fromUserNamex;
        [self saveContext];
        
    }
    
}

#pragma mark ====== 插入预加载数据库======
- (void)insertCoreDataxx:(NSString *)userIdx avatarImage:(NSString *)avatarImagex roomId:(NSString *)roomIdx time:(NSNumber *)timex
               message:(NSString *)messagex messageId:(NSString *)messageIdx fromUserName:(NSString *) fromUserNamex like:(NSNumber *)likeMessage
{
    //查询数据库，如果当前需要插入的messageid在数据库不存在，则
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"messageId = %@ AND accountId = %@",messageIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
    request.predicate = predicate;
    //  执行这个查询请求
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
//    if ([result count] == 0) {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        if (![userInfomationData.currtentRoomIdStr isEqualToString:roomIdx]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@%@",@"red",roomIdx]];
        }
        //  创建实体描述对象
        NSEntityDescription *description = [NSEntityDescription entityForName:@"Mic" inManagedObjectContext:self.managedObjectContext];
        //  1.先创建一个模型对象
        Mic *mic = [[Mic alloc] initWithEntity:description insertIntoManagedObjectContext:self.managedObjectContext];
        mic.accountId = [[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID];
        mic.userId = userIdx;
        mic.avatarImage = NULL_TO_NIL(avatarImagex);
        mic.roomId = roomIdx;
        mic.isRead = likeMessage;
        mic.isReadReady = @0;
        mic.time = timex;
        mic.message = messagex;
        mic.messageId = messageIdx;
        mic.fromUserName = fromUserNamex;
        [self saveContext];
//    }
}

#pragma mark ====== 插入lastMessageId到数据库（每次从服务器上拉取的时候插入）======

- (void)insertCoraData:(NSString *)roomIdx lastMessageId:(NSString *)lastMessageIdx beginMessageId:(NSString *)beginMessageIdx
{
    //查询数据库，如果当前需要插入的messageid在数据库不存在，则
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Node"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beginMessageId" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@",roomIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    //找到refrshMessageId在那个区间
    NSInteger xx = -1;
    for (NSInteger i = 0; i < [result count]; i++) {
        Node *node = result[i];
        if ([node.beginMessageId integerValue] <= [beginMessageIdx integerValue] && [node.lastMessageId integerValue] >= [beginMessageIdx integerValue]) {
            xx = i;
        }
    }
    if (xx == -1) {
        //不在区间里，就在node表中插入一个新的区间
        //  创建实体描述对象
        NSEntityDescription *description = [NSEntityDescription entityForName:@"Node" inManagedObjectContext:self.managedObjectContext];
        //  1.先创建一个模型对象
        Node *node = [[Node alloc] initWithEntity:description insertIntoManagedObjectContext:self.managedObjectContext];
        node.roomId = roomIdx;
        node.lastMessageId = lastMessageIdx;
        [self saveContext];
    }
    else
    {
        //在区间里，如果从服务器上拉取的数据的beginMessageId在区间里，则替换所在区间的beginMessageId
        Node *node = result[xx];
        node.beginMessageId = beginMessageIdx;
    }
}

#pragma mark ====== 查询是否需要历史记录是从服务器上拉取还是从本地数据库加载 ======
- (Boolean )selectCoreDataroomId:(NSString *)roomIdx refreshMessageId:(NSString *)refreshMessageIdx
{
    //  查询数据
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Node"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beginMessageId" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSLog(@"fadf*asd-fa-sf*-a*-*------  %@------ %@",roomIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@",roomIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"hahahhahahahahxxuxuxux ---- %lu",(unsigned long)[result count]);
    //找到refrshMessageId在那个区间
    NSInteger xx = -1;
    for (NSInteger i = 0; i < [result count]; i++) {
        Node *node = result[i];
        if ([node.beginMessageId integerValue] <= [refreshMessageIdx integerValue] && [node.lastMessageId integerValue] >= [refreshMessageIdx integerValue]) {
            xx  = i;
        }
    }
    if (xx == -1) {
        //不在区间里，从服务器拉取数据
        //service
        return NO;
    }
    else
    {
        //在区间里，并且在i这个区间里
        //开始查询Mic表，看refrshMessageId到beginMessageId之间的区域是否大于20条数据，如果大于，则直接加载本地数据库数据，否则，就拉去服务器数据，并且把拉取下来的最小的messageId更新到之前的beginMessageId
        Node *node = result[xx];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
//        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//        request.sortDescriptors = @[sortDescriptor];
        NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
        request.sortDescriptors = @[sortDescriptors];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@ AND messageId BWTEEN {%@，%@}",roomIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],node.beginMessageId,refreshMessageIdx]];
        request.predicate = predicate;
        NSError *error = nil;
        NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
        if ([result count] >= 20) {
            //直接从本地数据库加载
            //coreData
            return YES;
        }
        else
        {
            return NO;
            //从服务器拉取
            //service
            //注意，此时拉下来的数据要把最小的beginMessage🆔，放到区域中去比较替换
        }
        
        
    }
    
    return NO;
}


#pragma mark ====== 查询数据======
- (NSArray *)selectCoreDataroomId:(NSString *)roomIdx
{
    //  查询数据
    //  1.NSFetchRequst对象
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//    request.sortDescriptors = @[sortDescriptor];
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptors];
    NSString *str = @"";
    for (NSInteger i = 0; i < [userInfomationData.blockUsersMutableArr count]; i ++) {
        str = [NSString stringWithFormat:@"%@ AND userId != %@",str,[[userInfomationData.blockUsersMutableArr objectAtIndex:i] objectForKey:@"id"]];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"accountId = %@ AND roomId = %@ %@",[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],roomIdx,str]];
    request.fetchOffset=0; //分页起始索引
    request.fetchLimit=20*userInfomationData.currentPage; //每页条数
    request.predicate = predicate;
    //  执行这个查询请求
    NSError *error = nil;
    
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"--*sfasdfasd*-*-*-*-sd*fs-d*-xc*c-x*v------  %ld---- %ld",[result count],userInfomationData.micMockListPageIndex);
    //判断本地数据库coredata返回的语音是否够20条
    userInfomationData.getCoredataMicCount = [result count];
    return result;
}

#pragma mark ====== 查询数据======(没有屏蔽人的情况)
- (NSArray *)selectCoreDataroomIdNoBlock:(NSString *)roomIdx
{
    //  查询数据
    //  1.NSFetchRequst对象
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
    //    request.sortDescriptors = @[sortDescriptor];
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"accountId = %@ AND roomId = %@",[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],roomIdx]];
    request.fetchOffset=0; //分页起始索引
    request.fetchLimit=20*userInfomationData.micMockListPageIndex; //每页条数
    request.predicate = predicate;
    //  执行这个查询请求
    NSError *error = nil;
    
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"--*-*-*-*-*-sd*fs-d*-xc*c-x*v------  %ld",[result count]);
    //判断本地数据库coredata返回的语音是否够20条
    return result;
}


//#pragma mark ====== 查询数据库，拉取历史聊天记录======
//- (NSArray *)selectCoreDataroomId:(NSString *)roomIdx fromMessageId:(NSInteger)fromMessageIdx pageSize:(NSInteger)pageSizex
//{
//    //  查询数据
//    //  1.NSFetchRequst对象
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
//    //  2.设置排序
//    //  2.1创建排序描述对象
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//    request.sortDescriptors = @[sortDescriptor];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@",roomIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
//    request.fetchOffset=fromMessageIdx; //分页起始索引
//    request.fetchLimit=pageSizex; //每页条数
//    request.predicate = predicate;
//    
//    //  执行这个查询请求
//    NSError *error = nil;
//    
//    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
//    
//    return result;
//}

#pragma mark ====== 删除数据库一条消息（预加载的消息)======
- (void)deletePreLoadingMessage:(NSString *)roomIdx message:(NSString *)messageIdx
{
    //  查询数据
    //  1.NSFetchRequst对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//    request.sortDescriptors = @[sortDescriptor];
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptors];
    NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@ AND messageId = %@",roomIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],messageIdx]];
    request.fetchOffset=0;
    request.fetchLimit=1000;
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"xxxxcx---appdelegate-%@===%@ --%lu",roomId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],(unsigned long)[result count]);
    if ([result count] != 0) {
        for (NSInteger i = 0; i < [result count]; i++) {
            [self.managedObjectContext deleteObject:[result objectAtIndex:i]];
            [self saveContext];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
    }
    
}

#pragma mark ====== 删除数据库中包含messageId大于“99999999999000000”的所有消息======
- (void)deleteAllPreLoadingMessage
{
    //  查询数据
    //  1.NSFetchRequst对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//    request.sortDescriptors = @[sortDescriptor];
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptors];
    NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"messageId = %@ OR messageId = %@ OR messageId = %@ OR messageId = %@ OR messageId = %@ OR messageId = %@ OR messageId = %@ OR messageId = %@ OR messageId = %@ OR messageId = %@",@"9223372036854775000",@"9223372036854775001",@"9223372036854775002",@"9223372036854775003",@"9223372036854775004",@"9223372036854775005",@"9223372036854775006",@"9223372036854775007",@"9223372036854775008",@"9223372036854775009"]];
    request.fetchOffset=0;
    request.fetchLimit=100;
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"xxxxcx---appdelegatesdfsdfsdfsd-%@===%@ --%lu",roomId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID],(unsigned long)[result count]);
    if ([result count] != 0) {
        for (NSInteger i = 0; i < [result count]; i++) {
            [self.managedObjectContext deleteObject:[result objectAtIndex:i]];
            [self saveContext];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
    }
        
}

#pragma mark ====== 查询数据库，找出每个房间最大的messageId======
- (NSString *)largeMessageIdFromDB:(NSString *)roomId
{
    NSString *largeMessageId;
    //  查询数据
    //  1.NSFetchRequst对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//    request.sortDescriptors = @[sortDescriptor];
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@",roomId]];
    request.fetchOffset=0;
    request.fetchLimit=1;
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([result count] != 0) {
        Mic *mic = result[0];
        largeMessageId = mic.messageId;
    }
    NSLog(@"消息列表中最大的messageId：%@",largeMessageId);
    return largeMessageId;
}

#pragma mark ====== 删除屏蔽人的信息======
-(void)deleteShieldMessage:(NSString *)roomIdx userId:(NSString *)userIdx
{
    //  查询数据
    //  1.NSFetchRequst对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//    request.sortDescriptors = @[sortDescriptor];
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptors];
    NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND userId= %@",roomIdx,userIdx]];
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([result count] != 0) {
        for (NSInteger i = 0; i < [result count]; i++) {
            [self.managedObjectContext deleteObject:[result objectAtIndex:i]];
            [self saveContext];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getMicHistoryListMock" object:self];
    }
}

#pragma mark ====== 更新 喜欢一条消息======
- (void)updateLikeMessageId:(NSString *)messageId isRead:(NSString *)isReadContent
{
    //  查询数据
    //  1.NSFetchRequst对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
//    request.sortDescriptors = @[sortDescriptor];
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptors];
    NSLog(@"asfasdfasdkfjlkll---------  %@",messageId);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"messageId= %@ AND accountId = %@",messageId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([result count] != 0) {
        Mic *mic = result[0];
        mic.isRead =  @([isReadContent integerValue]);
        [self saveContext];
    }
}

#pragma mark ====== 跟新 已读一条消息======
- (void)updateIsReadMessageId:(NSString *)messageId isReadReady:(NSString *)isReadReadyContent
{
    //  查询数据
    //  1.NSFetchRequst对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
    //    request.sortDescriptors = @[sortDescriptor];
    NSSortDescriptor *sortDescriptors = [NSSortDescriptor sortDescriptorWithKey:@"messageId" ascending:NO selector:@selector(localizedStandardCompare:)];
    request.sortDescriptors = @[sortDescriptors];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"messageId= %@ AND accountId = %@",messageId,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"asfasdfasdkfjlkll---------  %@----%ld",messageId,(unsigned long)[result count]);
    for (Mic *mic in result) {
        mic.isReadReady =  @([isReadReadyContent integerValue]);
    }
    //保存
    [self saveContext];
}


@end
