//
//  CheckInTableViewCell.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "CheckInTableViewCell.h"

@implementation CheckInTableViewCell

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
//        self.bgImageView.backgroundColor = [UIColor whiteColor];
        [self.bgImageView setImage:[UIImage imageNamed:@"ticket_box"]];
        [self addSubview:self.bgImageView];
        
        self.qrImageView = [[UIImageView alloc] init];
        self.qrImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.qrImageView];
        
        self.fristNameLabel = [[UILabel alloc] init];
        self.fristNameLabel.textColor = [UIColor blackColor];
//        self.fristNameLabel.font = [UIFont systemFontOfSize:14];
        self.fristNameLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:16];
        self.fristNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.fristNameLabel];
        
        self.lastNameLabel = [[UILabel alloc] init];
        self.lastNameLabel.textColor = [UIColor blackColor];
//        self.lastNameLabel.font = [UIFont systemFontOfSize:14];
        self.lastNameLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:16];
        self.lastNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lastNameLabel];
        
        self.ticketTypeLabel = [[UILabel alloc] init];
        self.ticketTypeLabel.textColor = [UIColor colorWithRed:43/255.0 green:44/255.0 blue:45/255.0 alpha:1];
//        self.ticketTypeLabel.font = [UIFont systemFontOfSize:14];
        self.ticketTypeLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:16];
        self.ticketTypeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.ticketTypeLabel];
        
        self.checkCodeLabel = [[UILabel alloc] init];
        self.checkCodeLabel.textColor = [UIColor blackColor];
//        self.checkCodeLabel.font = [UIFont boldSystemFontOfSize:20];
        self.checkCodeLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:22];
        self.checkCodeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.checkCodeLabel];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
