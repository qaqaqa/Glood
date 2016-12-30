//
//  CeHuaTableViewCell.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/10.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "CeHuaTableViewCell.h"

@implementation CeHuaTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger )indexRow;
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.ceHuaIconImageView = [[UIImageView alloc] init];
        self.ceHuaIconImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.ceHuaIconImageView];
        
        self.ceHuaTitleLabel = [[UILabel alloc] init];
        self.ceHuaTitleLabel.font = [UIFont systemFontOfSize:25];
        [self addSubview:self.ceHuaTitleLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
