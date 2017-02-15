//
//  MicTableViewCell.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MicTableViewCell : UITableViewCell
@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIButton *headImageButton;
@property (strong, nonatomic) UILabel *nameLabel;
@property (retain, nonatomic) UIImageView *circleOneImageView;
@property (retain, nonatomic) UIImageView *circleTwoImageView;
@property (retain, nonatomic) UIButton *likeButton;
@property (retain, nonatomic) UILabel *userIdLabel;
@property (retain, nonatomic) UILabel *roomIdLabel;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger )indexRow;
@end
