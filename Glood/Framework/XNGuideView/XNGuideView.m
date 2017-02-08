//
//  XNGuideView.m
//
//  Created by LuohanCC on 15/11/30.
//  Copyright © 2015年 罗函. All rights reserved.
//

#import "XNGuideView.h"
#import "BFKit.h"
#define     GUIDE_FLAGS    @"/guide"

@interface XNGuideView() <UIScrollViewDelegate> {
    int screen_width;
    int screen_height;
}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *bottomImage;
@property (nonatomic, retain) NSArray *imageArray;
@end

@implementation XNGuideView

+ (void)showGudieView:(NSArray *)imageArray {
    if(imageArray && imageArray.count > 0) {
        NSFileManager *fmanager=[NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], GUIDE_FLAGS];
        BOOL isHasFile = [fmanager fileExistsAtPath:docDir];
        if(!isHasFile) {
            XNGuideView *xnGuideView = [[XNGuideView alloc] init:imageArray];
            [[UIApplication sharedApplication].delegate.window addSubview:xnGuideView];
            [fmanager createFileAtPath:docDir contents:nil attributes:nil];
        }
    }
}

+ (void)skipGuide {
    NSFileManager *fmanager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], GUIDE_FLAGS];
    [fmanager createFileAtPath:docDir contents:nil attributes:nil];
}
- (instancetype)init:(NSArray *)imageArray {
    self = [super init];
    
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {//判断系统是否支持本地通知
//        notification.fireDate = [NSDate dateWithTimeIntervalSince1970:18*60*60*24];//本次开启立即执行的周期
//        notification.repeatInterval=kCFCalendarUnitWeekday;//循环通知的周期
//        notification.timeZone=[NSTimeZone defaultTimeZone];
//        notification.alertBody=@"you have a new message!";//弹出的提示信息
//        notification.applicationIconBadgeNumber=0; //应用程序的右上角小数字
//        notification.soundName= UILocalNotificationDefaultSoundName;//本地化通知的声音
//        notification.hasAction = NO;
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    if(self) [self initThisView:imageArray];
    return self;
}

- (void)initThisView:(NSArray *)imageArray {
    _imageArray = imageArray;
    screen_width  = [UIScreen mainScreen].bounds.size.width;
    screen_height = [UIScreen mainScreen].bounds.size.height;
    self.frame = CGRectMake(0, 0, screen_width, screen_height);

    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    _scrollView.contentSize=CGSizeMake(screen_width * (_imageArray.count + 1), screen_height);
    _scrollView.pagingEnabled=YES;
    _scrollView.bounces = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.tag=7000;
    _scrollView.delegate = self;
    for (int i = 0; i < imageArray.count; i++) {
        CGRect frame = CGRectMake(i * screen_width, 0, screen_width, screen_height);
        UIImageView *img=[[UIImageView alloc] initWithFrame:frame];
        img.image=[UIImage imageNamed:imageArray[i]];
        [_scrollView addSubview:img];
        //skip
        CGRect skiprect = CGRectMake(i*screen_width, screen_height-100, screen_width, 50);
        UIButton *passbtn = [[UIButton alloc] initWithFrame:skiprect];
        [passbtn setHidden:YES];
        [passbtn addTarget:self action:@selector(dismissGuideView) forControlEvents:(UIControlEventTouchUpInside)];
        passbtn.backgroundColor = [UIColor clearColor];
        [passbtn.titleLabel setFont:[UIFont systemFontOfSize:25]];
        passbtn.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:45.f];
        [passbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSString *title;
        switch (i) {
            case 0:
                break;
            case 1:
                break;
            case 2:
                break;
            case 3:
                [passbtn setHidden:NO];
                break;
                
            default:
                break;
        }
        [passbtn setTitle:title forState:(UIControlStateNormal)];
        [_scrollView addSubview:passbtn];
        
    }
    [self addSubview:_scrollView];
    
    for (int i = 0; i < imageArray.count; i++) {
        CGRect bottomrect = CGRectMake(((screen_width-(60*imageArray.count))/2)+10+5*i+50*i, screen_height-50, 50, 5);
        _bottomImage = [[UIImageView alloc] initWithFrame:bottomrect];
        _bottomImage.layer.cornerRadius = 2.5;
        if (i==0) {
            _bottomImage.alpha= 0.8f;
        }
        else{
            _bottomImage.alpha= 0.2f;
        }
        _bottomImage.tag = 10001+i;
        _bottomImage.backgroundColor = [UIColor blackColor];
        [self addSubview:_bottomImage];
    }
    
    
    
}

#pragma mark scrollView的代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x >= 4 * screen_width) [self dismissGuideView];
    if (scrollView.contentOffset.x < screen_width) {
        for (id object in [self subviews]) {
            if ([object isKindOfClass:[UIView class]]) {
                UIImageView * imageView = (UIImageView *)object;
                if (imageView.tag == 10001) {
                    imageView.alpha = 0.8f;
                }
                else if(imageView.tag == 10002 || imageView.tag == 10003 || imageView.tag == 10004){
                    imageView.alpha = 0.2f;
                }
            }
        }
    }
    if (scrollView.contentOffset.x >= screen_width && scrollView.contentOffset.x<screen_width*2) {
        for (id object in [self subviews]) {
            if ([object isKindOfClass:[UIView class]]) {
                UIImageView * imageView = (UIImageView *)object;
                if (imageView.tag == 10002) {
                    imageView.alpha = 0.8f;
                }
                else if(imageView.tag == 10001 || imageView.tag == 10003 || imageView.tag == 10004){
                    imageView.alpha = 0.2f;
                }
            }
        }
    }
    if (scrollView.contentOffset.x >= 2*screen_width && scrollView.contentOffset.x<screen_width*3) {
        for (id object in [self subviews]) {
            if ([object isKindOfClass:[UIView class]]) {
                UIImageView * imageView = (UIImageView *)object;
                if (imageView.tag == 10003) {
                    imageView.alpha = 0.8f;
                }
                else if(imageView.tag == 10002 || imageView.tag == 10001 || imageView.tag == 10004){
                    imageView.alpha = 0.2f;
                }
            }
        }
    }
    if (scrollView.contentOffset.x >= 3*screen_width) {
        for (id object in [self subviews]) {
            if ([object isKindOfClass:[UIView class]]) {
                UIImageView * imageView = (UIImageView *)object;
                if(imageView.tag == 10002 || imageView.tag == 10003 || imageView.tag == 10001 || imageView.tag == 10004){
                    imageView.alpha = 0.0f;
                }
            }
        }
    }
        
}

-(void)dismissGuideView {
    [UIView animateWithDuration:0.6f animations:^{
        self.transform = (CGAffineTransformMakeScale(1.5, 1.5));
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0; //让scrollview 渐变消失
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    } ];


}

@end
