//
//  ShowMessage.h
//  HuaYiZu
//
//  Created by Simon-fan on 15/6/5.
//  Copyright (c) 2015年 Simon.Fan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShowMessage : NSObject

+(void)showMessage:(NSString *)message;
+(void)showMessage:(UIView *) view setMessage:(NSString *) message ;
+(void)showLastPageMessage:(UIView *) view isHaveFooter:(Boolean) have;

@end
