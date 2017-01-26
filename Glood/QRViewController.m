//
//  QRViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/8.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "QRViewController.h"
#import "QRView.h"
#import "Masonry.h"
#import "UIColor+HEX.h"
#import "MMProgressHUD.h"
#import "EventViewController.h"
#import "CommonService.h"
#import "UserInfomationData.h"

#define IOS_VERSION    [[[UIDevice currentDevice] systemVersion] floatValue]

#define LIGHTBUTTONTAG      100
#define IMPORTBUTTONTAG     101
#define CONFIRMBUTTONTAG    102

@interface QRViewController ()
{
    ZBarReaderView *_readview;//扫描二维码ZBarReaderView
    QRView *_qrRectView;//自定义的扫描视图
}

@end

@implementation QRViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(IOS_VERSION>=7.0){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self.view setBackgroundColor:[UIColor colorWithRed:148.0/255.0 green:148.0/255.0 blue:148.0/255.0 alpha:1.0]];
    //初始化扫描视图
    [self configuredZBarReader];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 34, 34)];
    [cancelButton setImage:[UIImage imageNamed:@"backqr"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
//    self.commonService = [[CommonService alloc] init];
}

- (void)onCancelBtnClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 *初始化扫描二维码对象ZBarReaderView
 *@param 设置扫描二维码视图的窗口布局、参数
 */
-(void)configuredZBarReader{
    //初始化照相机窗口
    _readview = [[ZBarReaderView alloc] init];
    //设置扫描代理
    _readview.readerDelegate = self;
    //显示帧率
    _readview.showsFPS = NO;
    //将其照相机拍摄视图添加到要显示的视图上
    [self.view addSubview:_readview];
    //二维码/条形码识别设置
    ZBarImageScanner *scanner = _readview.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    //Layout ZBarReaderView
    __weak __typeof(self) weakSelf = self;
    [_readview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).with.offset(0);
        make.left.equalTo(weakSelf.view).with.offset(0);
        make.right.equalTo(weakSelf.view).with.offset(0);
        make.bottom.equalTo(weakSelf.view).with.offset(0);
    }];
    
    //初始化扫描二维码视图的子控件
    [self configuredZBarReaderMaskView];
    
    //启动，必须启动后，手机摄影头拍摄的即时图像菜可以显示在readview上
    //[_readview start];
    //[_qrRectView startScan];
}


/**
 *自定义扫描二维码视图样式
 *@param 初始化扫描二维码视图的子控件
 */
- (void)configuredZBarReaderMaskView{
    //扫描的矩形方框视图
    _qrRectView = [[QRView alloc] init];
    _qrRectView.transparentArea = CGSizeMake(220, 220);
    _qrRectView.backgroundColor = [UIColor clearColor];
    [_readview addSubview:_qrRectView];
    [_qrRectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_readview).with.offset(0);
        make.left.equalTo(_readview).with.offset(0);
        make.right.equalTo(_readview).with.offset(0);
        make.bottom.equalTo(_readview).with.offset(0);
    }];
    
}

#pragma mark -
#pragma mark ZBarReaderViewDelegate
//扫描二维码的时候，识别成功会进入此方法，读取二维码内容
- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    //停止扫描
    [self setZBarReaderViewStop];
    
    ZBarSymbol *symbol = nil;
    for (symbol in symbols) {
        break;
    }
    NSString *urlStr = symbol.data;
    __weak __typeof(self) weakSelf = self;
    if(urlStr==nil || urlStr.length<=0){
        //二维码内容解析失败
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"扫描失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //重新扫描
            [weakSelf setZBarReaderViewStart];
        }];
        [alertVC addAction:action];
        [self presentViewController:alertVC animated:YES completion:^{
        }];
        
        return;
    }
    if ([urlStr rangeOfString:@"event_id"].location !=NSNotFound) {
        NSLog(@"urlStr: %@",urlStr);
        NSArray *array = [urlStr componentsSeparatedByString:@"="];
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
            [MMProgressHUD dismissWithError:@"add ticket error,try again" afterDelay:2.0f];
            return error;
        }];
    }
    else if ([urlStr rangeOfString:@","].location !=NSNotFound)
    {
        NSLog(@"urlStr: %@",urlStr);
        NSArray *array = [urlStr componentsSeparatedByString:@","];
        NSLog(@"array:%@",array);
        if ([array count] == 2) {
            NSString *barcode = [array objectAtIndex:1];
            NSString *event_id = [array objectAtIndex:0];
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
                [MMProgressHUD dismissWithError:@"add ticket error,try again" afterDelay:2.0f];
                return error;
            }];
        }
        
    }
    else{
        NSLog(@"不支持老版本扫描");
        [weakSelf setZBarReaderViewStop];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"QR code error" delegate:self cancelButtonTitle:@"try again" otherButtonTitles:nil, nil];
        alertView.tag = 20000102;
        [alertView show];
//        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"二维码有毛病"] preferredStyle:UIAlertControllerStyleAlert];
//        __weak __typeof(self) weakSelf = self;
//        [weakSelf setZBarReaderViewStop];
//        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            //继续扫描
//            [weakSelf setZBarReaderViewStart];
//        }];
//        [alertVC addAction:action];
//        [self presentViewController:alertVC animated:YES completion:^{
//            
//        }];
    }

    //二维码扫描成功，弹窗提示
//    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"扫描成功" message:[NSString stringWithFormat:@"二维码内容:\n%@",urlStr] preferredStyle:UIAlertControllerStyleAlert];
//    __weak __typeof(self) weakSelf = self;
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//        //继续扫描
//        [weakSelf setZBarReaderViewStart];
//    }];
//    [alertVC addAction:action];
//    [self presentViewController:alertVC animated:YES completion:^{
//        
//    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 20000102) {
        [self setZBarReaderViewStart];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //开始扫描
    [self setZBarReaderViewStart];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(OnJoinRoom)name:@"joinRoom"object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //停止扫描
    [self setZBarReaderViewStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"joinRoom" object:nil];
}

- (void)setZBarReaderViewStart{
    _readview.torchMode = 0;//关闭闪光灯
    [_readview start];//开始扫描二维码
    [_qrRectView startScan];
    
}

- (void)OnJoinRoom
{
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    userInfomationData.pushEventVCTypeStr = @"QR";
    EventViewController *eventVC = [[EventViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:eventVC animated:YES];
}

/**
 *关闭二维码扫描视图ZBarReaderView
 *@param 关闭闪光灯
 */
- (void)setZBarReaderViewStop{
    _readview.torchMode = 0;//关闭闪光灯
    [_readview stop];//关闭扫描二维码
    [_qrRectView stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
