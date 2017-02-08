//
//  CoverFlowTableViewCell.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/2/8.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoverFlowTableViewCell : UITableViewCell

@property (strong, nonatomic)UIImageView *bgImageView;
@property (strong, nonatomic)UIButton *headImageButton;
@property (strong, nonatomic)UILabel *nameLabel;
@property (retain, nonatomic) UIImageView *circleOneImageView;
@property (retain, nonatomic) UIImageView *circleTwoImageView;
@property (retain, nonatomic) UIButton *likeButton;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger )indexRow;

@end
