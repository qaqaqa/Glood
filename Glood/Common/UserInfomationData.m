//
//  UserInfomationData.m
//  SmallMoney
//
//  Created by fanlin on 13-6-27.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "UserInfomationData.h"

static UserInfomationData *shareInstance = nil;

@implementation UserInfomationData


+ (UserInfomationData *)shareInstance
{
    if (shareInstance == nil)
    {
        shareInstance = [[UserInfomationData alloc] init];
    }
    return  shareInstance;
}

@end
