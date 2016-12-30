//
//  CeHuaView.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/10.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "CeHuaView.h"
#import "Define.h"

@interface CeHuaView ()

@property(retain, nonatomic) NSArray *cehuaArr;

@end

@implementation CeHuaView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self.bgView setImage:[UIImage imageNamed:@"bg"]];
        [self addSubview:self.bgView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-50, SCREEN_HEIGHT)];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.alpha = 0.3;
        [self addSubview:imageView];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,45,SCREEN_WIDTH-70,SCREEN_HEIGHT)];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.scrollEnabled =NO;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tableView];
        
        self.cehuaArr = [[NSArray alloc] initWithObjects:@{@"MingleTitle":@"Communities",@"MingleIcon":@"mingle"},
                             @{@"MingleTitle":@"Settings",@"MingleIcon":@"setting"},
                             @{@"MingleTitle":@"Feedback",@"MingleIcon":@"feedback"},
                             nil];

        
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cehuaArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

#define ceHuaIconImageViewTag 10001
#define ceHuaTitleLabelTag 20001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.ceHuaTabelViewCell = [tableView dequeueReusableCellWithIdentifier:@"CeHuaTableViewCell"];
    if (self.ceHuaTabelViewCell == nil)
    {
        self.ceHuaTabelViewCell = [[CeHuaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CeHuaTableViewCell" index:indexPath.row];
        [self.ceHuaTabelViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    self.ceHuaTabelViewCell.ceHuaIconImageView.frame = CGRectMake(35, 15, SCREEN_WIDTH*20/320, SCREEN_WIDTH*20/320);
    [self.ceHuaTabelViewCell.ceHuaIconImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[[self.cehuaArr objectAtIndex:indexPath.row] objectForKey:@"MingleIcon"]]]];
    self.ceHuaTabelViewCell.ceHuaIconImageView.tag = ceHuaIconImageViewTag+indexPath.row;
    
    self.ceHuaTabelViewCell.ceHuaTitleLabel.frame = CGRectMake(35+(SCREEN_WIDTH*20/320)+40, self.ceHuaTabelViewCell.ceHuaIconImageView.frame.origin.y-5, 250, self.ceHuaTabelViewCell.ceHuaIconImageView.frame.size.height+10);
    self.ceHuaTabelViewCell.ceHuaTitleLabel.text = [NSString stringWithFormat:@"%@",[[self.cehuaArr objectAtIndex:indexPath.row] objectForKey:@"MingleTitle"]];
    
    return self.ceHuaTabelViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSLog(@"ming");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onMing" object:self];
    }
    else if (indexPath.row == 1) {
        NSLog(@"setting");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onSetting" object:self];
    }
    else{
        NSLog(@"feedback");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onFeedback" object:self];
    }
}

@end
