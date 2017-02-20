//
//  BlockUsersTableViewCell.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2017/2/20.
//  Copyright © 2017年 sparxo-dev-ios-1. All rights reserved.
//

#import "BlockUsersTableViewCell.h"

@implementation BlockUsersTableViewCell

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
        
        self.cancleBlockButton = [[UIButton alloc] init];
        [self.cancleBlockButton setTitle:@"cancel" forState:UIControlStateNormal];
        [self.cancleBlockButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.cancleBlockButton.backgroundColor = [UIColor whiteColor];
        self.cancleBlockButton.layer.cornerRadius = 8;
        self.cancleBlockButton.layer.masksToBounds = YES;
        [self addSubview:self.cancleBlockButton];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
