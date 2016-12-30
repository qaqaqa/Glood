//
//  NSString+Base64.h
//  ReduxTest
//
//  Created by sparxo-dev-ios-1 on 16/5/20.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Base64)

/**
 *  转换为Base64编码
 */
- (NSString *)base64EncodedString;
/**
 *  将Base64编码还原
 */
- (NSString *)base64DecodedString;
@end
