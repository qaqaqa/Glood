//
//  QRNativeViewController.m
//  二维码生成与扫描
//
//  Created by 周鑫 on 15/11/7.
//  Copyright © 2015年 chris. All rights reserved.
//

#import "QRNativeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UserInfomationData.h"
#import "EventViewController.h"
#import "MMProgressHUD.h"


#define SCANVIEW_EdgeTop 150.0
#define SCANVIEW_EdgeLeft 50.0
#define TINTCOLOR_ALPHA 0.2 //浅色透明度
#define DARKCOLOR_ALPHA 0.3 //深色透明度
#define VIEW_WIDTH [UIScreen mainScreen].bounds.size.width
#define VIEW_HEIGHT [UIScreen mainScreen].bounds.size.height

static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";
@interface QRNativeViewController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>{
    //设置扫描画面
    UIView *_scanView;
    NSTimer *_timer;
    
    UIView *_QrCodeline;
    UIView *_QrCodeline1;
    UIImageView *_scanCropView;//扫描窗口
    AVCaptureSession *_captureSession;
    AVCaptureVideoPreviewLayer *_videoPreviewLayer;
    NSInteger xx;
}

@end

@implementation QRNativeViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor clearColor];
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ([self isCameraAvailable] && authStatus != AVAuthorizationStatusDenied) {
        //初始化扫描界面
        // 获取 AVCaptureDevice 实例
        NSError * error;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // 初始化输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!input) {
            NSLog(@"%@", [error localizedDescription]);
            return;
        }
        // 创建会话
        _captureSession = [[AVCaptureSession alloc] init];
        //提高图片质量为1080P，提高识别效果
        _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        // 添加输入流
        [_captureSession addInput:input];
        // 初始化输出流
        AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        //设置扫描范围
        captureMetadataOutput.rectOfInterest =CGRectMake((_scanCropView.frame.origin.y-10)/VIEW_HEIGHT, (_scanCropView.frame.origin.x-10)/VIEW_WIDTH, (_scanCropView.frame.size.width+10)/VIEW_HEIGHT, (_scanCropView.frame.size.height+10)/VIEW_WIDTH);
        // 添加输出流
        [_captureSession addOutput:captureMetadataOutput];
        
        // 创建dispatch queue.
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
        [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        // 设置元数据类型 AVMetadataObjectTypeQRCode
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
        // 创建输出对象
        _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        [_videoPreviewLayer setFrame:_scanView.layer.bounds];
        [_scanView.layer insertSublayer:_videoPreviewLayer atIndex:0];
        
        [self startReading];
        //启动定时器
        [self createTimer];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Please allow Glood to access your device's camera in \"Settings\" -> \"Privacy\" -> \"Camera\"."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Set", nil];
        alert.tag = 10212;
        [alert show];
        return;
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//        label.textColor = [UIColor whiteColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [UIFont systemFontOfSize:18];
//        label.lineBreakMode = NSLineBreakByWordWrapping;
//        label.numberOfLines = 0;
//        label.text = NSLocalizedString(@"A camera is required for\n QR code checkin.", nil);
//        label.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.view addSubview:label];
        
    }
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(OnJoinRoom)name:@"joinRoom"object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopTimer];
    _captureSession = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"joinRoom" object:nil];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10212) {
        if (buttonIndex == 1) {
            NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
            if ([phoneVersion doubleValue] < 10) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"]];
            }
            else{
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if( [[UIApplication sharedApplication]canOpenURL:url] ) {
                    [[UIApplication sharedApplication]openURL:url options:@{}completionHandler:^(BOOL        success) {
                    }];
                }
            }
            
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"]];
        }
    }
    else if (alertView.tag == 20000102) {
        [self startReading];
    }
}

#pragma mark - Private
- (BOOL)isCameraAvailable;
{
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    return [videoDevices count] > 0;
}

- (void)OnJoinRoom
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.pushEventVCTypeStr = @"QR";
    EventViewController *eventVC = [[EventViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:eventVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setScanView];
}

- (void)onCancelBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)startReading
{
    xx = 0;
    // 开始会话
    [_captureSession startRunning];
    
    return YES;
}

- (void)stopReading
{
    xx = 1;
    // 停止会话
    [_captureSession stopRunning];
    
}


#pragma AVCaptureMetadataOutputObjectsDelegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
        } else {
            NSLog(@"不是二维码");
        }
        //调用代理对象的协议方法来实现数据传递
        [self dismissViewControllerAnimated:YES completion:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result rangeOfString:@"event_id"].location !=NSNotFound) {
                [self stopReading];
                NSLog(@"urlStr: %@",result);
                NSArray *array = [result componentsSeparatedByString:@"="];
                NSLog(@"array:%@",array);
                NSString *barcode = [array objectAtIndex:[array count]-1];
                NSString *event_id = [array objectAtIndex:[array count]-2];
                NSArray *array2 = [event_id componentsSeparatedByString:@"&"];
                event_id = [array2 objectAtIndex:0];
                event_id = [event_id stringByReplacingOccurrencesOfString:@"“"withString:@""];
                NSLog(@"------- 扫描结果：%@--- %@",barcode,event_id);
                
                [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
                [MMProgressHUD showWithTitle:@"add ticket" status:NSLocalizedString(@"Please wating", nil)];
                [[userInfomationData.commonService addTicket:barcode eventId:event_id] then:^id(id value) {
                    [MMProgressHUD showWithTitle:@"join chatroom" status:NSLocalizedString(@"Please wating", nil)];
                    NSLog(@"-------%@",value);
                    [userInfomationData.commonService joinRoom:event_id];
                    return value;
                } error:^id(NSError *error) {
                    NSLog(@"添加票失败--- %@",error);
                    [MMProgressHUD dismissWithError:@"add tickets error,try again!" afterDelay:2.0f];
                    return error;
                }];
            }
            else if ([result rangeOfString:@","].location !=NSNotFound)
            {
                [self stopReading];
                NSLog(@"urlStr: %@",result);
                NSArray *array = [result componentsSeparatedByString:@","];
                NSLog(@"array:%@",array);
                if ([array count] == 2) {
                    NSString *barcode = [array objectAtIndex:1];
                    NSString *event_id = [array objectAtIndex:0];
                    NSLog(@"------- 扫描结果：%@--- %@",barcode,event_id);
                    
                    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleShrink];
                    [MMProgressHUD showWithTitle:@"add tickets" status:NSLocalizedString(@"Please wating", nil)];
                    [[userInfomationData.commonService addTicket:barcode eventId:event_id] then:^id(id value) {
                        [MMProgressHUD showWithTitle:@"join chatroom" status:NSLocalizedString(@"Please wating", nil)];
                        NSLog(@"-------%@",value);
                        [userInfomationData.commonService joinRoom:event_id];
                        return value;
                    } error:^id(NSError *error) {
                        NSLog(@"添加票失败--- %@",error);
                        [MMProgressHUD dismissWithError:@"add ticket error,try again!" afterDelay:2.0f];
                        return error;
                    }];
                }
                
            }
            else{
//                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"二维码有毛病"] preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                }];
//                [alertVC addAction:action];
//                [self presentViewController:alertVC animated:YES completion:^{
//                    
//                }];
                NSLog(@"不支持老版本扫描");
                
                if (xx == 0) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"QR code error" delegate:self cancelButtonTitle:@"try again" otherButtonTitles:nil, nil];
                    alertView.tag = 20000102;
                    [alertView show];
                }
                [self stopReading];
                
            }
        });
    
    }
    return;
}

- (void)createTimer
{
    _timer=[NSTimer scheduledTimerWithTimeInterval:2.2 target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats:YES];
}
- (void)stopTimer
{
    if ([_timer isValid] == YES) {
        [_timer invalidate];
        _timer = nil;
    }
    
}

//二维码的扫描区域
- (void)setScanView
{
    _scanView=[[UIView alloc] initWithFrame:CGRectMake(0,0, VIEW_WIDTH,VIEW_HEIGHT )];
    _scanView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_scanView];
    
    //最上部view
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0,0, VIEW_WIDTH,SCANVIEW_EdgeTop)];
    upView.alpha =TINTCOLOR_ALPHA;
    upView.backgroundColor = [UIColor blackColor];
    [_scanView addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, SCANVIEW_EdgeTop, SCANVIEW_EdgeLeft,VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft)];
    leftView.alpha =TINTCOLOR_ALPHA;
    leftView.backgroundColor = [UIColor blackColor];
    [_scanView addSubview:leftView];
    
    // 中间扫描区
    _scanCropView=[[UIImageView alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft,SCANVIEW_EdgeTop, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft)];
    //scanCropView.image=[UIImage imageNamed:@""];
    _scanCropView.layer.borderColor=[UIColor greenColor].CGColor;
    _scanCropView.layer.borderWidth=2.0;
    _scanCropView.backgroundColor=[UIColor clearColor];
    [_scanView addSubview:_scanCropView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(VIEW_WIDTH - SCANVIEW_EdgeLeft,SCANVIEW_EdgeTop, SCANVIEW_EdgeLeft, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft)];
    rightView.alpha =TINTCOLOR_ALPHA;
    rightView.backgroundColor = [UIColor blackColor];
    [_scanView addSubview:rightView];
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop, VIEW_WIDTH, VIEW_HEIGHT - (VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop))];
    //downView.alpha = TINTCOLOR_ALPHA;
    downView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:TINTCOLOR_ALPHA];
    [_scanView addSubview:downView];
    
    //画中间的基准线
    _QrCodeline = [[UIView alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop, VIEW_WIDTH- 2 * SCANVIEW_EdgeLeft, 2)];
    _QrCodeline.backgroundColor = [UIColor greenColor];
    [_scanView addSubview:_QrCodeline];
    
    //画中间的基准线
    _QrCodeline1 = [[UIView alloc] initWithFrame:CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop, VIEW_WIDTH- 2 * SCANVIEW_EdgeLeft, 2)];
    _QrCodeline1.backgroundColor = [UIColor greenColor];
    [_scanView addSubview:_QrCodeline1];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 48, 45)];
    [cancelButton setImage:[UIImage imageNamed:@"backqr"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    // 先让第二根线运动一次,避免定时器执行的时差,让用户感到启动App后,横线就开始移动
    [UIView animateWithDuration:2.2 animations:^{
        
        _QrCodeline1.frame = CGRectMake(SCANVIEW_EdgeLeft, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop - 2, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft, 1);
    }];
    
    
}

// 当地一根线到达底部时,第二根线开始下落运动,此时第一根线已经在顶部,当第一根线接着下落时,第二根线到达顶部.依次循环
- (void)moveUpAndDownLine
{
    CGFloat Y = _QrCodeline.frame.origin.y;
    if (Y == SCANVIEW_EdgeTop) {
        [UIView animateWithDuration:2.2 animations:^{
            
            _QrCodeline.frame = CGRectMake(SCANVIEW_EdgeLeft, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop - 2, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft, 1);
        }];
        _QrCodeline1.frame = CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft, 1);
    }
    else if (Y == VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop - 2) {
        _QrCodeline.frame = CGRectMake(SCANVIEW_EdgeLeft, SCANVIEW_EdgeTop, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft, 1);
        [UIView animateWithDuration:2.2 animations:^{
            
            _QrCodeline1.frame = CGRectMake(SCANVIEW_EdgeLeft, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft + SCANVIEW_EdgeTop - 2, VIEW_WIDTH - 2 * SCANVIEW_EdgeLeft, 1);
        }];
    }
    
}

//取消button
- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
