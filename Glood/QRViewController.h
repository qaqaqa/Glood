//
//  QRViewController.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/8.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
#import "CommonService.h"

@interface QRViewController : UIViewController<ZBarReaderViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (retain, nonatomic) CommonService *commonService;

//打开二维码扫描视图
- (void)setZBarReaderViewStart;
//关闭二维码扫描视图
- (void)setZBarReaderViewStop;

@end
