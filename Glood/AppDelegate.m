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


@interface AppDelegate ()

@property (strong, nonatomic) UIView *tipsView;
@property (strong, nonatomic) UIView *networkDisBGView;
@property (strong, nonatomic) NSString *isEnterGroundStr;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Bugly startWithAppId:@"900016269"];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    self.isEnterGroundStr = @"no";
    self.commonService = [[CommonService alloc] init];
    self.recordAudio = [[RecordAudio alloc] init];
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.commonService = self.commonService;
    userInfomationData.recordAudio = self.recordAudio;
    userInfomationData.micMockListPageIndex = 1; //每次进入应用程序时，当前分页置为0
    
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
    userInfomationData.yuMessageId = 99999999999000000;
    NSLog(@"*-*-*-*---xxxxx-*x-  %lld",userInfomationData.yuMessageId);
    
    return YES;
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
        if (status == AFNetworkReachabilityStatusNotReachable ||status ==  AFNetworkReachabilityStatusUnknown)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showMenu" object:nil];
            self.networkStatus = @"lost";
            manager.requestSerializer.cachePolicy =  NSURLRequestReturnCacheDataDontLoad;
            [self.tipsView setHidden:NO];
            [self.networkDisBGView setHidden:NO];
            
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


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
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
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Glood.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark ====== 插入数据库======
- (void)insertCoreData:(NSString *)userIdx avatarImage:(NSString *)avatarImagex roomId:(NSString *)roomIdx time:(NSNumber *)timex
               message:(NSString *)messagex messageId:(NSString *)messageIdx fromUserName:(NSString *) fromUserNamex
{
    //查询数据库，如果当前需要插入的messageid在数据库不存在，则
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"messageId = %@ AND accountId = %@",messageIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
    request.predicate = predicate;
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
        mic.isRead = 0;
        mic.time = timex;
        mic.message = messagex;
        mic.messageId = messageIdx;
        mic.fromUserName = fromUserNamex;
        [self saveContext];
    }
}

#pragma mark ====== 插入预加载数据库======
- (void)insertCoreDataxx:(NSString *)userIdx avatarImage:(NSString *)avatarImagex roomId:(NSString *)roomIdx time:(NSNumber *)timex
               message:(NSString *)messagex messageId:(NSString *)messageIdx fromUserName:(NSString *) fromUserNamex
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
        mic.isRead = 0;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@",roomIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
    request.predicate = predicate;
    
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
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
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
        request.sortDescriptors = @[sortDescriptor];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"roomId = %@ AND accountId = %@",roomIdx,[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID]]];
    request.fetchOffset=0; //分页起始索引
    request.fetchLimit=20*userInfomationData.micMockListPageIndex; //每页条数
    request.predicate = predicate;
    //  执行这个查询请求
    NSError *error = nil;
    
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    NSString *roomId = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"messageId >= %@",@"99999999999000000"]];
    request.fetchOffset=0;
    request.fetchLimit=100;
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

#pragma mark ====== 查询数据库，找出每个房间最大的messageId======
- (NSString *)largeMessageIdFromDB:(NSString *)roomId
{
    NSString *largeMessageId;
    //  查询数据
    //  1.NSFetchRequst对象
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Mic"];
    //  2.设置排序
    //  2.1创建排序描述对象
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageId" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
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


@end
