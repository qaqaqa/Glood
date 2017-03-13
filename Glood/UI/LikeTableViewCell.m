//
//  LikeTableViewCell.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/3/13.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import "LikeTableViewCell.h"

@implementation LikeTableViewCell

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
        
        self.headImageButton = [[UIButton alloc] init];
        [self addSubview:self.headImageButton];
        
        self.nameLabel = [[UILabel alloc] init];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
