//
//  CheckInViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "CheckInViewController.h"
#import "Define.h"
#import "UserInfomationData.h"
#import "LGRefreshView.h"

@interface CheckInViewController ()

@end

@implementation CheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //mock数据
    UserInfomationData *userInfomationData = [UserInfomationData shareInstance];
    self.mockTicketDataMutableArr = [[NSMutableArray alloc] initWithCapacity:10];
    self.mockTicketDataMutableArr = [userInfomationData.ticketsDic objectForKey:@"result"];

    //UI布局
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:bgImageView];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,34+30,SCREEN_WIDTH,SCREEN_HEIGHT-64)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.bounces = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsMake(15, 0, 15, 0);
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"-*-*--------  %lu",(unsigned long)[self.mockTicketDataMutableArr count]);
    return [self.mockTicketDataMutableArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT*240/568;
}

#define qrImageViewTag 10001
#define firstNameLabelTag 20001
#define lastNameLabelTag 30001
#define ticketTypeLabelTag 40001
#define checkCodeLabelTag 50001
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.checkInTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"CheckInTableViewCell"];
    if (self.checkInTableViewCell == nil)
    {
        self.checkInTableViewCell = [[CheckInTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CheckInTableViewCell" index:indexPath.row];
        [self.checkInTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    self.checkInTableViewCell.bgImageView.frame = CGRectMake(15,-20,SCREEN_WIDTH*290/320, SCREEN_HEIGHT*200/568);
//    self.checkInTableViewCell.bgImageView.layer.cornerRadius = 8;
//    self.checkInTableViewCell.bgImageView.layer.masksToBounds = YES;
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据(正则表达式/账号和密码)
    NSString *dataString = [NSString stringWithFormat:@"https://a.sparxo.com/1/qrcode/redirect?event_id=%@&barcode=%@",[[self.mockTicketDataMutableArr objectAtIndex:indexPath.row] objectForKey:@"event_id"],[[self.mockTicketDataMutableArr objectAtIndex:indexPath.row] objectForKey:@"barcode"]];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.显示二维码
    self.checkInTableViewCell.qrImageView.frame = CGRectMake(45, SCREEN_HEIGHT*18/568, SCREEN_WIDTH*118/320, SCREEN_WIDTH*118/320);
    self.checkInTableViewCell.qrImageView.tag = qrImageViewTag+indexPath.row;
    UIImage *qrcode = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:SCREEN_WIDTH*118/320];
    UIImage *customQrcode = [self imageBlackToTransparent:qrcode withRed:115.0f andGreen:116.0f andBlue:117.0f];
    self.checkInTableViewCell.qrImageView.image = customQrcode;
    
    self.checkInTableViewCell.fristNameLabel.frame = CGRectMake(self.checkInTableViewCell.qrImageView.frame.size.width+self.checkInTableViewCell.qrImageView.frame.origin.x, self.checkInTableViewCell.qrImageView.frame.origin.y+10, SCREEN_WIDTH*150/320, SCREEN_WIDTH*28/568);
    self.checkInTableViewCell.fristNameLabel.textAlignment = NSTextAlignmentCenter;
    self.checkInTableViewCell.fristNameLabel.text = [[self.mockTicketDataMutableArr objectAtIndex:indexPath.row] objectForKey:@"attendee_first_name"];
    self.checkInTableViewCell.fristNameLabel.tag = firstNameLabelTag+indexPath.row;
    
    self.checkInTableViewCell.lastNameLabel.frame = CGRectMake(self.checkInTableViewCell.fristNameLabel.frame.origin.x, self.checkInTableViewCell.fristNameLabel.frame.origin.y+self.checkInTableViewCell.fristNameLabel.frame.size.height+5, self.checkInTableViewCell.fristNameLabel.frame.size.width, self.checkInTableViewCell.fristNameLabel.frame.size.height);
    self.checkInTableViewCell.lastNameLabel.textAlignment = NSTextAlignmentCenter;
    self.checkInTableViewCell.lastNameLabel.text = [[self.mockTicketDataMutableArr objectAtIndex:indexPath.row] objectForKey:@"attendee_last_name"];
    self.checkInTableViewCell.lastNameLabel.tag = lastNameLabelTag+indexPath.row;
    
    self.checkInTableViewCell.ticketTypeLabel.frame = CGRectMake(self.checkInTableViewCell.fristNameLabel.frame.origin.x+(SCREEN_WIDTH*25/320), self.checkInTableViewCell.lastNameLabel.frame.origin.y+self.checkInTableViewCell.lastNameLabel.frame.size.height+5, self.checkInTableViewCell.fristNameLabel.frame.size.width-(SCREEN_WIDTH*50/320), self.checkInTableViewCell.fristNameLabel.frame.size.height*3);
    self.checkInTableViewCell.ticketTypeLabel.numberOfLines = 2;
    self.checkInTableViewCell.ticketTypeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.checkInTableViewCell.ticketTypeLabel.textAlignment = NSTextAlignmentCenter;
    self.checkInTableViewCell.ticketTypeLabel.text = [[self.mockTicketDataMutableArr objectAtIndex:indexPath.row] objectForKey:@"ticket_name"];
    self.checkInTableViewCell.ticketTypeLabel.tag = ticketTypeLabelTag+indexPath.row;
    
    self.checkInTableViewCell.checkCodeLabel.frame = CGRectMake(self.checkInTableViewCell.fristNameLabel.frame.origin.x, self.checkInTableViewCell.ticketTypeLabel.frame.origin.y+self.checkInTableViewCell.ticketTypeLabel.frame.size.height, self.checkInTableViewCell.fristNameLabel.frame.size.width, self.checkInTableViewCell.fristNameLabel.frame.size.height);
    self.checkInTableViewCell.checkCodeLabel.textAlignment = NSTextAlignmentCenter;
    self.checkInTableViewCell.checkCodeLabel.text = [[self.mockTicketDataMutableArr objectAtIndex:indexPath.row] objectForKey:@"check_code"];
    self.checkInTableViewCell.checkCodeLabel.tag = checkCodeLabelTag+indexPath.row;
    
    
    return self.checkInTableViewCell;
}

//使生成的二维码清晰
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

//修改生成的二维码颜色
#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

- (void)onCancelBtnClick:(id)sender
{
    NSLog(@"check-in cancel");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
