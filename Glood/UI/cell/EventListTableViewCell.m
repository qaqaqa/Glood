//
//  EventListTableViewCell.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/8.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "EventListTableViewCell.h"

@implementation EventListTableViewCell

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
                
        self.eventImageView = [[UIImageView alloc] init];
        self.eventImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.eventImageView];
        
        self.eventNameLabel = [[UILabel alloc] init];
        self.eventNameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.eventNameLabel];
        
        self.redImageView = [[UIImageView alloc] init];
        self.redImageView.backgroundColor = [UIColor colorWithRed:233/255.0 green:80/255.0 blue:23/255.0 alpha:1];
        [self addSubview:self.redImageView];
        
        self.lineImageView = [[UIImageView alloc] init];
        self.lineImageView.backgroundColor = [UIColor colorWithRed:99/255.0 green:200/255.0 blue:172/255.0 alpha:1];
        [self addSubview:self.lineImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
