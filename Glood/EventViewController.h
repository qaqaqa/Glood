//
//  EventViewController.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EventListView.h"
#import "CommonService.h"
#import "RecordAudio.h"
#import <AVFoundation/AVFoundation.h>

@interface EventViewController : UIViewController<eventListViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,getMicHistoryListDelegate>

@property (strong, nonatomic)   AVAudioRecorder  *recorder;
@property (strong, nonatomic)   AVAudioPlayer    *player;
@property (strong, nonatomic)   NSString         *recordFileName;
@property (strong, nonatomic)   NSString         *recordFilePath;
@property (strong, nonatomic) UILabel *navtitleLabel;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *largeLeftButton;

@property (strong, nonatomic) UIView *gcdView;
@property (strong, nonatomic) UILabel *gcdLabel;

@property (strong, nonatomic) NSString *recordAudioTimeOutStr;

//- (void)saveRecord:(NSString *)base64 messageId:(NSString *)messageIdx;
//- (void)palyRecord:(NSString *)playName;

@end
