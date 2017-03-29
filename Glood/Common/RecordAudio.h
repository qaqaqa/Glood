//
//  RecordAudio.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/17.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordAudio : NSObject<AVAudioRecorderDelegate,AVAudioPlayerDelegate>


@property (strong, nonatomic)   AVAudioRecorder  *recorder;
@property (strong, nonatomic)   AVAudioPlayer    *player;
@property (strong, nonatomic)   NSString         *recordFileName;
@property (strong, nonatomic)   NSString         *recordFilePath;

- (void)saveRecordAmr:(NSString *)amrDateUrl messageId:(NSString *)messageIdx;
- (void)arm:(NSString *)convertedPath fileName:(NSString *)fileName;
- (void)saveRecord:(NSString *)base64 messageId:(NSString *)messageIdx;
- (void)palyRecord:(NSString *)playName;
- (void)startRecoring:(NSString *)fileName;
- (NSString *)stopRecoring;
- (NSString *)stopRecoringCancel;
- (void)stopPlay;
+ (BOOL)clearCachesss;

@end
