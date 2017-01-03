//
//  ViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "ViewController.h"
#import "XNGuideView.h"
#import "Define.h"
#import "EventViewController.h"
#import "CommonService.h"
#import "MMProgressHUD.h"
#import "ShowMessage.h"
#import "UserInfomationData.h"
#import "AddATicketViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@interface ViewController ()<FBSDKLoginButtonDelegate >

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:YES];
    NSArray *array = @[@"bg", @"bg", @"bg", @"guied04.jpg"];
    [XNGuideView showGudieView:array];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:bgImageView];
    
    //facebook第三方登陆，服务器登陆
    UIButton *facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*50/320, 200, SCREEN_WIDTH*220/320, 50)];
    [facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [facebookButton setTitle:@"sign in with facebook" forState:UIControlStateNormal];
    facebookButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    facebookButton.backgroundColor = [UIColor colorWithRed:68/255.0 green:81/255.0 blue:183/255.0 alpha:1.0];
    [facebookButton addTarget:self action:@selector(onSignInBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:facebookButton];
    
    //    self.commonService = [[CommonService alloc] init];
    
    //facebook第三方登陆 sdK登陆
//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    // Optional: Place the button in the center of your view.
//    loginButton.readPermissions =
//    @[@"public_profile", @"email", @"user_friends"];
//    loginButton.delegate = self;
//    loginButton.center = self.view.center;
//    [self.view addSubview:loginButton];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error;
{
    NSLog(@"xxxxx---xxxxx---- %@---%@",result.token,error);
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSLog(@"fetched user:%@", result);
             }
         }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSLog(@"xxxx-*-------  %@",[[NSUserDefaults standardUserDefaults] objectForKey:Exchange_OAUTH2_TOKEN]);
    if (![CommonService isBlankString:[[NSUserDefaults standardUserDefaults] objectForKey:Exchange_OAUTH2_TOKEN]]) {
        //又置换后的token，则直接登陆
        [MMProgressHUD showWithTitle:@"正在连接聊天服务器" status:NSLocalizedString(@"Please wating", nil)];
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        [userInfomationData.commonService connectionSignlar];
    }
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(getEventList)name:@"getEventList"object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(exchangeToken)name:@"exchangeToken"object:nil];
    //    EventViewController *eventVC = [[EventViewController alloc] initWithNibName:nil bundle:nil];
    //   [self.navigationController pushViewController:eventVC animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getEventList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"exchangeToken" object:nil];
    [MMProgressHUD dismiss];
}

- (void)getEventList
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    if ([[userInfomationData.eventDic objectForKey:@"result"] count] == 0)
    {
        //当前用户没有活动
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getEventList" object:nil];
            AddATicketViewController *addATicketVC = [[AddATicketViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:addATicketVC animated:YES];
        });
        
    }
    else
    {
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        if ([userInfomationData.pushEventVCTypeStr isEqualToString:@"NOQR"]) {
            userInfomationData.pushEventVCTypeStr = @"NOQR";
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getEventList" object:nil];
        EventViewController *eventVC = [[EventViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:eventVC animated:YES];
        
    }
}
#pragma  mark ==========  点击连接facebook SDK登陆 ==========
- (void)onSignInBtnClick:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login
     logInWithReadPermissions: @[@"public_profile", @"email", @"user_friends"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         NSLog(@"xxxxx-*-*-*------  %@--- %@",result.token.userID,result.token.tokenString );
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             NSLog(@"Logged in");
             
             //置换token
             [[NSUserDefaults standardUserDefaults] setObject:result.token.tokenString forKey:FACEBOOK_OAUTH2_TOKEN];
             [self exchangeToken];
         }
     }];
}


#pragma  mark ==========  点击连接facebook 服务器登陆==========
/*
- (void)onSignInBtnClick:(id)sender
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    if([CommonService NetWorkIsOK])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([CommonService isBlankString:[[NSUserDefaults standardUserDefaults] objectForKey:Exchange_OAUTH2_TOKEN]]) {
            //在webview上显示facebook登录页面
            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
            [MMProgressHUD showWithTitle:@"连接Facebook" status:NSLocalizedString(@"Please wating", nil)];
            self.facebookLoginWebView = [[UIWebView alloc] init];
            self.facebookLoginWebView.backgroundColor = [UIColor whiteColor];
            self.facebookLoginWebView.scalesPageToFit = YES;
            self.facebookLoginWebView.delegate = self;
            self.facebookLoginWebView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.facebookLoginWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:FACEBOOK_OAUTH2_LOGIN_URL]  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30]];
            
            [self.view addSubview:self.facebookLoginWebView];
        }
        else
        {
            [MMProgressHUD showWithTitle:@"正在连接聊天服务器" status:NSLocalizedString(@"Please wating", nil)];
            [userInfomationData.commonService connectionSignlar];
        }
        
        
    }
    else
    {
        [ShowMessage showMessage:self.navigationController.view setMessage:NETWORK_ERROR];
    }
    
    //    免登录
    //    EventViewController *eventVC = [[EventViewController alloc] initWithNibName:nil bundle:nil];
    //    [self.navigationController pushViewController:eventVC animated:YES];
}
 */

- (void)cleanCacheAndCookie{
    //清除cookies
    self.facebookLoginWebView = nil;
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

#pragma mark =========webview加载开始和结束=========
//- (void)webViewDidStartLoad:(UIWebView *)webView
//{
//    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
//    [MMProgressHUD showWithTitle:@"跳转到Facebook登录页面" status:NSLocalizedString(@"Please wating", nil)];
//}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MMProgressHUD dismiss];
    //[MMProgressHUD dismissWithSuccess:@"加载完成"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    
    NSLog(@"--error--%@－－－%ld",error,(long)[error code]);
    if ([error code] == -1001)
    {
        [MMProgressHUD dismissWithError:@"请求超时，请重新尝试" afterDelay:2.0f];
    }
    if([error code] == NSURLErrorCancelled)  {
        return;
    }
    [self.facebookLoginWebView removeFromSuperview];
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSString *requestString = [[request URL] absoluteString];
    NSLog(@"webview=====%@",requestString);
    NSRange range = [requestString rangeOfString:[NSString stringWithFormat:@"%@/#external_access_token",BASE_URL]];//匹配得到的下标
    NSLog(@"rang－－－－－:%@",NSStringFromRange(range));
    if (range.length > 0)
    {
        [self.facebookLoginWebView stopLoading];
        [self isRemoveWebView];
        //
        NSString *str = [requestString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"xxxxxxxxxx------ %@",str);
        str = [str stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/#",BASE_URL] withString:@""];
        NSArray *arr = [[NSArray alloc] init];
        arr = [str componentsSeparatedByString:@"&"];
        NSLog(@"------=====----request %@",arr);
        NSMutableDictionary *mutableDic = [[NSMutableDictionary alloc] initWithCapacity:10];
        for (NSInteger i = 0; i < [arr count]; i ++)
        {
            NSArray *arrr = [[NSArray alloc] init];
            arrr = [[arr objectAtIndex:i] componentsSeparatedByString:@"="];
            [mutableDic setObject:[arrr objectAtIndex:1] forKey:[arrr objectAtIndex:0]];
        }
        NSLog(@"mutableDic-------%@",mutableDic);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[mutableDic objectForKey:@"external_user_name"] forKey:FACEBOOK_OAUTH2_USERNAME];
        [defaults setObject:[mutableDic objectForKey:@"external_access_token"] forKey:FACEBOOK_OAUTH2_TOKEN];
        NSLog(@"has_local_account-----%@",[mutableDic objectForKey:@"has_local_account"]);
        if ([[mutableDic objectForKey:@"has_local_account"] isEqualToString:@"False"])
        {
            //调用外部注册
            [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
            [MMProgressHUD showWithTitle:@"外部账号注册中" status:NSLocalizedString(@"Please wating", nil)];
            [[userInfomationData.commonService signup_external:[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_TOKEN] provider:[mutableDic objectForKey:@"provider"]] then:^id(id value) {
                NSLog(@"调用外部注册成功");
                [self exchangeToken];
                return value;
            } error:^id(NSError *error) {
                NSLog(@"调用外部注册失败--- %@",error);
                [MMProgressHUD dismissWithError:@"外部注册失败，请重新尝试" afterDelay:2.0f];
                return error;
            }];
            
        }
        else
        {
            //置换token
            [self exchangeToken];
        }
    }
    
    
    return YES;
}

//置换token
- (void)exchangeToken
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
    [MMProgressHUD showWithTitle:@"置换token" status:NSLocalizedString(@"Please wating", nil)];
    [[userInfomationData.commonService obtain_local_access_token:[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_TOKEN]] then:^id(id value) {
        NSLog(@"置换token成功----%@",[[value objectForKey:@"result"] objectForKey:@"access_token"]);
        [MMProgressHUD showWithTitle:@"正在连接聊天服务器" status:NSLocalizedString(@"Please wating", nil)];
        [[NSUserDefaults standardUserDefaults] setObject:[[value objectForKey:@"result"] objectForKey:@"access_token"] forKey:Exchange_OAUTH2_TOKEN];
        [[NSUserDefaults standardUserDefaults] setObject:[[value objectForKey:@"result"] objectForKey:@"user_id"] forKey:FACEBOOK_OAUTH2_USERID];
        [userInfomationData.commonService connectionSignlar];
        return value;
    } error:^id(NSError *error) {
        NSLog(@"置换token失败--- %@",error.description);
        [MMProgressHUD dismissWithError:@"置换token失败，请重新尝试" afterDelay:2.0f];
        //如果报账号不存在，则调用外部登陆
        
        return error;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)isRemoveWebView
{
    [self.facebookLoginWebView removeFromSuperview];
}

@end
