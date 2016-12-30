//
//  ViewController.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonService.h"

@interface ViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic)UIWebView *facebookLoginWebView;

- (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view;
- (void)cleanCacheAndCookie;
@end

