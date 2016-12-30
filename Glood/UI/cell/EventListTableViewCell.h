//
//  EventListTableViewCell.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/8.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventListTableViewCell : UITableViewCell
@property (retain, nonatomic) UIImageView *eventImageView;
@property (retain, nonatomic) UILabel *eventNameLabel;
@property (retain, nonatomic) UIImageView *redImageView;
@property (retain, nonatomic) UIImageView *lineImageView;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger )indexRow;
@end

