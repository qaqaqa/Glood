//
//  MicTableViewCell.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "MicTableViewCell.h"
#import "Define.h"

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
        
        self.userIdLabel = [[UILabel alloc] init];
        self.userIdLabel.textColor = [UIColor clearColor];
        self.userIdLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.userIdLabel];
        
        self.roomIdLabel = [[UILabel alloc] init];
        self.roomIdLabel.backgroundColor = [UIColor clearColor];
        self.roomIdLabel.textColor = [UIColor clearColor];
        [self addSubview:self.roomIdLabel];
        
        self.messageIdLabel = [[UILabel alloc] init];
        self.messageIdLabel.backgroundColor = [UIColor clearColor];
        self.messageIdLabel.textColor = [UIColor clearColor];
        [self addSubview:self.messageIdLabel];
        
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
        
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.headImageButton addGestureRecognizer:recognizer];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nameLabel];
        
        self.likeButton = [[UIButton alloc] init];
        self.likeButton.backgroundColor = [UIColor clearColor];
        [self.likeButton setImage:[UIImage imageNamed:@"app_img_like2"] forState:UIControlStateNormal];
        [self addSubview:self.likeButton];
        
        self.blockLogoButton = [[UIButton alloc] init];
        self.blockLogoButton.backgroundColor = [UIColor clearColor];
        [self.blockLogoButton setImage:[UIImage imageNamed:@"ban_sign"] forState:UIControlStateNormal];
        [self.headImageButton addSubview:self.blockLogoButton];

        
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:FACEBOOK_OAUTH2_USERID] isEqualToString:self.userIdLabel.text]) {
        // Figure out where the user is trying to drag the view.
        CGPoint translation = [recognizer translationInView:self.bgImageView];
        CGPoint newCenter = CGPointMake(recognizer.view.center.x+ translation.x,
                                        recognizer.view.center.y + translation.y);//    限制屏幕范围：
        newCenter.y = MAX(recognizer.view.frame.size.height/2, newCenter.y);
        newCenter.y = MIN(self.bgImageView.frame.size.height - recognizer.view.frame.size.height/2,  newCenter.y);
        newCenter.x = MAX(self.frame.size.width/2-self.bgImageView.frame.size.width/2+recognizer.view.frame.size.width/2, newCenter.x);
        newCenter.x = MIN(self.frame.size.width/2+self.bgImageView.frame.size.width/2 - recognizer.view.frame.size.width/2,newCenter.x);
        recognizer.view.center = newCenter;
        [recognizer setTranslation:CGPointZero inView:self.bgImageView];
        
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            [self.circleOneImageView setHidden:YES];
            [self.circleTwoImageView setHidden:YES];
            self.headImageButton.userInteractionEnabled = NO;
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled ||
                 recognizer.state == UIGestureRecognizerStateFailed)
        {
            float leftX = self.bgImageView.frame.origin.x;
            float rightX = self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width;
            if (newCenter.x+self.headImageButton.frame.size.width/2+1 >= rightX) {
                NSLog(@"喜欢");
                self.likeButton.frame = CGRectMake(self.bgImageView.frame.origin.x+self.bgImageView.frame.size.width-(SCREEN_WIDTH*8/320), self.bgImageView.frame.origin.y-self.likeButton.frame.size.height, SCREEN_WIDTH*10/320, SCREEN_WIDTH*8/320);
                NSDictionary *dic = @{@"name":self.nameLabel.text,
                                      @"headImage":self.headImageButton.currentImage,
                                      @"userId":self.userIdLabel.text,
                                      @"roomId":self.roomIdLabel.text,
                                      @"messageId":self.messageIdLabel.text
                                      };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"slideRightLike" object:dic];
            }
            else if (newCenter.x-self.headImageButton.frame.size.width/2-1 <= leftX)
            {
                NSLog(@"屏蔽");
                self.blockLogoButton.frame = CGRectMake(-4, -4, self.headImageButton.frame.size.width+8, self.headImageButton.frame.size.width+8);
                NSDictionary *dic = @{@"name":self.nameLabel.text,
                                      @"headImage":self.headImageButton.currentImage,
                                      @"userId":self.userIdLabel.text,
                                      @"roomId":self.roomIdLabel.text,
                                      @"messageId":self.messageIdLabel.text
                                      };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"slideLeftShield" object:dic];
            }
            else
            {
                self.headImageButton.frame = CGRectMake(self.circleOneImageView.frame.origin.x, self.headImageButton.frame.origin.y, self.headImageButton.frame.size.width, self.headImageButton.frame.size.height);
                [UIView animateWithDuration:1.5 animations:^{
                    [recognizer setTranslation:CGPointZero inView:self.bgImageView];
                } completion:^(BOOL finished) {
                    [self.circleOneImageView setHidden:NO];
                    [self.circleTwoImageView setHidden:NO];
                    self.headImageButton.userInteractionEnabled = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"slideCenterRestore" object:self];
                }];
            }
            
            
        }
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
