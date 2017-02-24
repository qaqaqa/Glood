//
//  RecordAudio.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/17.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "RecordAudio.h"
#import "NSString+Base64.h"
#import "VoiceConverter.h"
#import "ShowMessage.h"
#import "MMProgressHUD.h"
#import "AppDelegate.h"
#import "UserInfomationData.h"
#import "CommonService.h"

@import AVFoundation;
@import AudioToolbox;

@interface RecordAudio()
{
    AVAudioSession *recordSession;
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    NSData *wavdata;
    NSString *pathForFile;
}

@property (strong, nonatomic) AppDelegate *myAppDelegate;

@end

@implementation RecordAudio


//开始录音
- (void)startRecoring:(NSString *)fileName
{
//    dispatch_async(dispatch_get_global_queue(0,0), ^{
        //根据当前时间生成文件名
        self.recordFileName = [self GetCurrentTimeString];
        //获取路径
        self.recordFilePath = [self GetPathByFileName:self.recordFileName ofType:@"wav"];
        //初始化录音
        self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:self.recordFilePath]
                                                   settings:[VoiceConverter GetAudioRecorderSettingDict]
                                                      error:nil];
        
        //准备录音
        if ([self.recorder prepareToRecord]){
            
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            
            //开始录音
            [self.recorder record];
            NSLog(@"xxxxxxxxx filename:%@",fileName);
        }
//    });
    
}

//停止录音
- (NSString *)stopRecoring
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopRecording" object:self];
    [self.recorder stop];
    NSDate *date = [NSDate date];
    NSString *amrPath = [self GetPathByFileName:self.recordFileName ofType:@"amr"];
#warning wav转amr
    if ([VoiceConverter ConvertWavToAmr:self.recordFilePath amrSavePath:amrPath]){
        
        date = [NSDate date];
        NSString *convertedPath = [self GetPathByFileName:[self.recordFileName stringByAppendingString:@""] ofType:@"wav"];
        //获取时间
        NSURL *audioFileURL = [NSURL fileURLWithPath:convertedPath];
        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:audioFileURL options:nil];
        CMTime audioDuration = audioAsset.duration;
        float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
        NSString *timeStr = [NSString stringWithFormat:@"%.1f",audioDurationSeconds];
        UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
        userInfomationData.recordMessageTimeStr = timeStr;
        //转码
        NSFileManager *fileManager = [NSFileManager defaultManager];
        wavdata = [fileManager contentsAtPath:amrPath];
        NSString *pictureDataString=[wavdata base64Encoding];
        pictureDataString = [NSString stringWithFormat:@"%@,%@",timeStr,pictureDataString];
//        NSLog(@"---------***** %@===%@----%@",[NSString stringWithFormat:@"%@.wav",self.recordFileName],timeStr,pictureDataString);
        return pictureDataString;
        
        
    }else
        self.myAppDelegate = [UIApplication sharedApplication].delegate;
        [self performSelector:@selector(cancelTimer) withObject:nil afterDelay:0.5f];
        [ShowMessage showMessage:@"recording error"];
    return nil;
    
}

- (void)cancelTimer
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    NSString *roomIdStr;
    if ([CommonService isBlankString:userInfomationData.QRRoomId]) {
        roomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"id"];
    }
    else
    {
        for (NSInteger i = 0; i < [(NSMutableArray*)[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] count]; i ++) {
            if ([userInfomationData.QRRoomId isEqualToString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"]]) {
                roomIdStr = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:i] objectForKey:@"id"];
            }
        }
        
    }
    [self.myAppDelegate deletePreLoadingMessage:roomIdStr message:[NSString stringWithFormat:@"%lld",userInfomationData.yuMessageId]];
}

- (NSString *)stopRecoringCancel
{
    [self.recorder stop];
    return nil;
    
}


#pragma mark ========= 生成当前时间字符串 =======
- (NSString*)GetCurrentTimeString{
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}

#pragma mark ========= 生成文件路径 =========
- (NSString*)GetPathByFileName:(NSString *)_fileName ofType:(NSString *)_type{
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];;
    NSString* fileDirectory = [[[directory stringByAppendingPathComponent:_fileName]
                                stringByAppendingPathExtension:_type]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return fileDirectory;
}

#pragma mark ======== 播放录音 ========
- (void)palyRecord:(NSString *)playName
{
    self.player = [[AVAudioPlayer alloc]init];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    playName = [playName stringByReplacingOccurrencesOfString:@".wav" withString:@""];
    NSString *convertedPath = [self GetPathByFileName:playName ofType:@"wav"];
    self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:convertedPath] error:nil];
    [self.player play];
    
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:convertedPath] options:nil];
    
    CMTime audioDuration = audioAsset.duration;
    
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    //    NSString *timeStr = [NSString stringWithFormat:@"%.1f",audioDurationSeconds];
    __block float timeout = audioDurationSeconds+0.5;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){
            //             [ShowMessage showMessage:@"播放完毕"];
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                timeout--;
            });
        }
    });
    dispatch_resume(_timer);
}

#pragma mark ====== 停止播放 =============
- (void)stopPlay
{
    [self.player stop];
    self.player = nil;
    [audioPlayer stop];
    audioPlayer = nil;
}

#pragma mark ======= 保存语音 ==========
- (void)saveRecord:(NSString *)base64 messageId:(NSString *)messageIdx
{
    NSLog(@"sdf-*-*-*---------  %@---%@",base64,messageIdx);
//    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSString *fileName = [NSString stringWithFormat:@"%@",messageIdx];
        NSString *cachePath = [self getCachePath];
        NSString *convertedPath = [self GetPathByFileName:fileName ofType:@"amr"];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:convertedPath isDirectory:&isDir];
        if ( !(isDir == YES && existed == YES) )
        {
            NSLog(@"----sdfsf--sdf-sd---- 文件bu存在");
            [fileManager createDirectoryAtPath:convertedPath withIntermediateDirectories:YES attributes:nil error:nil];
            pathForFile = [NSString stringWithFormat:@"%@/%@", convertedPath, fileName];
            NSData *sData   = [[NSData alloc] initWithBase64Encoding:base64];
            BOOL ss = [sData writeToFile:pathForFile atomically:YES];
            self.recordFilePath = [self GetPathByFileName:fileName ofType:@"wav"];
#warning amr转wav
            if ([VoiceConverter ConvertAmrToWav:pathForFile wavSavePath:self.recordFilePath]){
                NSLog(@"amr转wav成功");
            }else
            {
                NSLog(@"amr转wav失败");
            }
            
            
            NSURL *audioFileURL = [NSURL fileURLWithPath:self.recordFilePath];
            AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:audioFileURL options:nil];
            
            CMTime audioDuration = audioAsset.duration;
            
            float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
            NSString *timeStr = [NSString stringWithFormat:@"%.1f",audioDurationSeconds];
        }
    else
    {
        NSLog(@"----sdfsf--sdf-sd---- 文件存在");
    }
//    });
    
    
    
    
    // NSLog(@"-----**-*pathForFile:---%@  sData:%@ -- %@",pathForFile,sData,base64);
}

- (NSString *)getCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //    return [NSString stringWithFormat:@"%@/audioCache", documentsDirectory];
    return [NSString stringWithFormat:@"%@", documentsDirectory];
}

//UTC时间转换成对应系统时间
-(NSString *)getLocalDateFormateUTCDate:(NSString *)utcDate
{
    NSLog(@"UTC=========%@",utcDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    NSLog(@"UTC=========%@",dateString);
    return dateString;
}



@end
