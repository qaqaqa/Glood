//
//  CommonClass.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/30.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "CommonClass.h"

@implementation CommonClass

+(NSURL *)showImage:(NSString *)imageUrl x1:(NSString *) x1x y1:(NSString *) y1x x2 :(NSString *) x2x y2:(NSString *) y2x width:(NSString *)widthx
{
    NSURL *new_image_url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?crop=(%@,%@,%@,%@)&width=%@",imageUrl,x1x,y1x,x2x,y2x,widthx]];
    return new_image_url;
}

@end
