//
//  CeHuaTableViewCell.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/10.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CeHuaTableViewCell : UITableViewCell
@property (retain, nonatomic) UIImageView *ceHuaIconImageView;
@property (retain, nonatomic) UILabel *ceHuaTitleLabel;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger )indexRow;

@end
