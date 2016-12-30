//
//  MicTableViewCell.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "MicTableViewCell.h"

@implementation MicTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger )indexRow;
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.bgImageView = [[UIImageView alloc] init];
        self.bgImageView.backgroundColor = [UIColor clearColor];
//        [self.bgImageView setImage:[UIImage imageNamed:@"background.png"]];
        [self addSubview:self.bgImageView];
        
        self.circleOneImageView = [[UIImageView alloc] init];
        self.circleOneImageView.backgroundColor = [UIColor whiteColor];
        self.circleOneImageView.alpha = 0.5;
        [self addSubview:self.circleOneImageView];
        
        self.circleTwoImageView = [[UIImageView alloc] init];
        self.circleTwoImageView.backgroundColor = [UIColor whiteColor];
        self.circleTwoImageView.alpha = 0.5;
        [self addSubview:self.circleTwoImageView];
        
        self.headImageButton = [[UIButton alloc] init];
        [self addSubview:self.headImageButton];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nameLabel];

        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
