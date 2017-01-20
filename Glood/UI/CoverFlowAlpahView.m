//
//  CoverFlowAlpahView.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/1/18.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import "CoverFlowAlpahView.h"

@implementation CoverFlowAlpahView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor blackColor];
        [self addSubview:view];
    }
    return self;
}

@end
