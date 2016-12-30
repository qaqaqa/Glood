//
//  NSString+Base64.m
//  ReduxTest
//
//  Created by sparxo-dev-ios-1 on 16/5/20.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "NSString+Base64.h"

@implementation NSString (Base64)

- (NSString *)base64EncodedString;
{
  NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
  return [data base64EncodedStringWithOptions:0];
}

- (NSString *)base64DecodedString
{
  NSData *data = [[NSData alloc]initWithBase64EncodedString:self options:0];
  return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

@end
