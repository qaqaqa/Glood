//
//  CommonNavView.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "CommonNavView.h"
#import "Define.h"

@implementation CommonNavView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*50/568)];
        [self addSubview:self.topBgView];
        
        self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*10/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*34/320, SCREEN_HEIGHT*36/568)];
        [self.leftButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [self.leftButton addTarget:self action:@selector(onLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.topBgView addSubview:self.leftButton];
        
        UIButton *largeLeftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*54/320, SCREEN_HEIGHT*56/568)];
        [largeLeftButton addTarget:self action:@selector(onLeftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        largeLeftButton.backgroundColor = [UIColor clearColor];
        [self.topBgView addSubview:largeLeftButton];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*80/320, SCREEN_HEIGHT*10/568, SCREEN_WIDTH*160/320, SCREEN_HEIGHT*36/568)];
        self.titleLabel.text = @"Communities";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Light.otf" size:17];
        self.titleLabel.textColor = [UIColor colorWithRed:115/255.0 green:113/255.0 blue:114/255.0 alpha:1.0];
        [self.topBgView addSubview:self.titleLabel];
        
        self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-(SCREEN_WIDTH*54/320), SCREEN_HEIGHT*10/568, SCREEN_WIDTH*34/320, SCREEN_HEIGHT*36/568)];
        [self.rightButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        [self.rightButton addTarget:self action:@selector(onRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.topBgView addSubview:self.rightButton];
    }
    return self;
}

- (void)onLeftBtnClick:(id)sender
{
    NSLog(@"left--------");
}
- (void)onRightBtnClick:(id)sender
{
    NSLog(@"right--------");
}

@end
