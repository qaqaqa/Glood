//
//  common.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

//网络错误
#define NETWORK_ERROR NSLocalizedString(@"Network Error",nil)

#define BASE_URL @"https://a.sparxo.com" //匹配facebook返回url
#define REQUEST_BASE_URL @"https://a.sparxo.com/1/" //http请求url
#define FACEBOOK_OAUTH2_EXCHANGE_URL @"https://identity.sparxo.com"
#define FACEBOOK_OAUTH2_LOGIN_URL @"https://identity.sparxo.com/oauth2/external_login?provider=Facebook&redirect_uri=https://a.sparxo.com&client_id=1"//跳转到facebook登录
#define FACEBOOK_OAUTH2_TOKEN @"facebook_oauth2_token"
#define Exchange_OAUTH2_TOKEN @"exchange_oauth2_token"
#define FACEBOOK_OAUTH2_USERNAME @"facebook_oauth2_username"
#define FACEBOOK_OAUTH2_USERID @"facebook_oauth2_userid"
#define USER_AVATAR_URL @"user_avatar_url"
#define USER_NAME @"user_name"
#define USER_CLIENT_ID @"user_client_id"

#define SIGNLAR_URL @"https://event-chat.sparxo.com/"

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })
