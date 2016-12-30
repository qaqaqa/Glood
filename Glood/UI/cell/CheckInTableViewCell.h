//
//  CheckInTableViewCell.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckInTableViewCell : UITableViewCell
@property (strong, nonatomic)UIImageView *bgImageView;
@property (strong, nonatomic)UIImageView *qrImageView;
@property (strong, nonatomic)UILabel *fristNameLabel;
@property (strong, nonatomic)UILabel *lastNameLabel;
@property (strong, nonatomic)UILabel *ticketTypeLabel;
@property (strong, nonatomic)UILabel *checkCodeLabel;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier index:(NSInteger )indexRow;
@end
