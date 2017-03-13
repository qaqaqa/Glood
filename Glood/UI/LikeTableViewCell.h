//
//  LikeTableViewCell.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/3/13.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeTableViewCell : UITableViewCell

@property (retain, nonatomic) UIButton *headImageButton;
@property (retain, nonatomic) UILabel *nameLabel;


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger )indexRow;


@end
