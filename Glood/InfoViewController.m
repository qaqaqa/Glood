//
//  InfoViewController.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/7.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "InfoViewController.h"
#import "Define.h"
#import "EventViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CommonClass.h"

@interface InfoViewController ()<UIWebViewDelegate>

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *monthMutableArr = [[NSMutableArray alloc] initWithObjects:@"JAN",@"FEB",@"MAR",@"APR",@"MAY",@"JUN",@"JUL",@"AUG",@"SEP",@"OCT",@"NOV",@"DEC", nil];
    NSString *currentDateStr = [self getLocalDateFormateUTCDate:[[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"schedules"] objectAtIndex:0] objectForKey:@"begin_time_utc"]];
    NSString *monthStr = [monthMutableArr objectAtIndex:[[currentDateStr substringWithRange:NSMakeRange(5,2)] integerValue]-1];
    NSString *dayStr = [currentDateStr substringWithRange:NSMakeRange(8,2)];
    NSString *timeStr = [NSString stringWithFormat:@"%@ - %@",[self ssDate:[self getLocalTimeFormateUTCDate:[[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"schedules"] objectAtIndex:0] objectForKey:@"begin_time_local"]]],[self ssDate:[self getLocalTimeFormateUTCDate:[[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"schedules"] objectAtIndex:0] objectForKey:@"end_time_local"]]]];
    
    //UI布局
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [bgImageView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:bgImageView];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 30, 30)];
    [cancelButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(onCancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    self.bgScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bgScrollView];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*120/568)];
    [topImageView sd_setImageWithURL:[CommonClass showImage:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_url"] x1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x1"] y1:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y1"] x2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"x2"] y2:[[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"image_crop_info"] objectForKey:@"y2"] width:[NSString stringWithFormat:@"%.f",topImageView.frame.size.width*2]] placeholderImage:[UIImage imageNamed:@"event_background.jpg"]];
    
    [self.bgScrollView addSubview:topImageView];
    
    UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*10/320, topImageView.frame.size.height+topImageView.frame.origin.y+SCREEN_WIDTH*10/320, SCREEN_WIDTH*60/320, SCREEN_HEIGHT*30/568)];
    monthLabel.textAlignment = NSTextAlignmentRight;
    monthLabel.text = [NSString stringWithFormat:@"%@",monthStr];
//    monthLabel.font = [UIFont boldSystemFontOfSize:13];
    monthLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:25];
    [self.bgScrollView addSubview:monthLabel];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(monthLabel.frame.origin.x, monthLabel.frame.size.height+monthLabel.frame.origin.y, SCREEN_WIDTH*60/320, SCREEN_HEIGHT*35/568)];
    dayLabel.textAlignment = NSTextAlignmentRight;
    dayLabel.text = [NSString stringWithFormat:@"%@",dayStr];
//    dayLabel.font = [UIFont boldSystemFontOfSize:25];
    dayLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:35];
    [self.bgScrollView addSubview:dayLabel];
    
    CGSize eventNameSize = [[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"name"]] sizeWithFont:[UIFont fontWithName:@"ProximaNova-Regular" size:28] constrainedToSize:CGSizeMake(SCREEN_WIDTH*220/320, 60) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *eventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(monthLabel.frame.origin.x+monthLabel.frame.size.width+15, monthLabel.frame.origin.y+2, SCREEN_WIDTH*220/320, eventNameSize.height)];
    eventNameLabel.textAlignment = NSTextAlignmentLeft;
    eventNameLabel.numberOfLines = 0;
    eventNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    eventNameLabel.text = [NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"name"]];
//    eventNameLabel.font = [UIFont boldSystemFontOfSize:16];
    eventNameLabel.font = [UIFont fontWithName:@"ProximaNova-Regular" size:25];
    [self.bgScrollView addSubview:eventNameLabel];
    
    UIImageView *timelogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(dayLabel.frame.origin.x+(SCREEN_WIDTH*12/320), dayLabel.frame.origin.y+dayLabel.frame.size.height+(SCREEN_WIDTH*10/320), SCREEN_WIDTH*15/320, SCREEN_WIDTH*15/320)];
    [timelogoImageView setImage:[UIImage imageNamed:@"timeicon"]];
    [self.bgScrollView addSubview:timelogoImageView];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timelogoImageView.frame.size.width+timelogoImageView.frame.origin.x+5, timelogoImageView.frame.origin.y, SCREEN_WIDTH*200/320, SCREEN_WIDTH*15/320)];
    timeLabel.text = [NSString stringWithFormat:@"%@",timeStr];
    timeLabel.font = [UIFont systemFontOfSize:14];
    [self.bgScrollView addSubview:timeLabel];
    
    UIImageView *addresslogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(timelogoImageView.frame.origin.x+1, timeLabel.frame.origin.y+timeLabel.frame.size.height+(SCREEN_WIDTH*10/320), SCREEN_WIDTH*17/320, SCREEN_WIDTH*19/320)];
    [addresslogoImageView setImage:[UIImage imageNamed:@"addressicon"]];
    [self.bgScrollView addSubview:addresslogoImageView];
    
    CGSize addressSize = [[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"location"]] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(SCREEN_WIDTH*200/320, 100) lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(addresslogoImageView.frame.size.width+addresslogoImageView.frame.origin.x+5, addresslogoImageView.frame.origin.y, SCREEN_WIDTH*200/320, addressSize.height)];
    addressLabel.numberOfLines = 0;
    addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    addressLabel.text = [NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"location"]];
    addressLabel.font = [UIFont systemFontOfSize:14];
    [self.bgScrollView addSubview:addressLabel];
    
//    CGSize contentSize = [[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"long_description"]] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(SCREEN_WIDTH*290/320, 10000) lineBreakMode:NSLineBreakByWordWrapping];
//    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*15/320, addressLabel.frame.size.height+addressLabel.frame.origin.y+25, SCREEN_WIDTH*290/320, contentSize.height)];
//    contentLabel.font = [UIFont systemFontOfSize:14];
//    contentLabel.numberOfLines = 0 ;
//    contentLabel.text = [NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"long_description"]];
//    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    [self.bgScrollView addSubview:contentLabel];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*15/320, addressLabel.frame.size.height+addressLabel.frame.origin.y+25, SCREEN_WIDTH*290/320, (SCREEN_HEIGHT*(568-250)/568)-addressSize.height-35)];
    [webView setBackgroundColor:[UIColor clearColor]];
    webView.delegate = self;
    [webView setOpaque:NO];
    webView.scalesPageToFit = YES;
    [webView loadHTMLString:[NSString stringWithFormat:@"%@",[[[[NSUserDefaults standardUserDefaults] objectForKey:@"eventList"] objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"currentIndex"] integerValue]] objectForKey:@"long_description"]] baseURL:nil];
    [self.bgScrollView addSubview:webView];
    
    for (UIView *_aView in [webView subviews])
    {
        if ([_aView isKindOfClass:[UIScrollView class]])
        {
            [(UIScrollView *)_aView setShowsVerticalScrollIndicator:NO];
            //右侧的滚动条
            
            [(UIScrollView *)_aView setShowsHorizontalScrollIndicator:NO];
            //下侧的滚动条
            
            for (UIView *_inScrollview in _aView.subviews)
            {
                if ([_inScrollview isKindOfClass:[UIImageView class]])
                {
                    _inScrollview.hidden = YES;  //上下滚动出边界时的黑色的图片
                }
            }
        }
    }
    
//    self.bgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, (SCREEN_HEIGHT*250/568)+contentSize.height);
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    NSURL *requestString = [request URL];
    if ( ( [ [ requestString scheme ] isEqualToString: @"http" ] || [ [ requestString scheme ] isEqualToString: @"https" ] || [ [ requestString scheme ] isEqualToString: @"mailto" ])
        && ( navigationType == UIWebViewNavigationTypeLinkClicked ) ) {
        return ![ [ UIApplication sharedApplication ] openURL: requestString ];
    }
    return YES;
}

- (void)onCancelBtnClick:(id)sender
{
    NSLog(@"check-in cancel");
//    EventViewController *eventVC = [[EventViewController alloc] initWithNibName:nil bundle:nil];
//    CATransition* transition = [CATransition animation];
//    transition.type = kCATransitionPush;//可更改为其他方式
//    transition.subtype = kCATransitionFromRight;//可更改为其他方式
//    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    [self.navigationController pushViewController:eventVC animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
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

-(NSString *)getLocalTimeFormateUTCDate:(NSString *)utcDate
{
    NSLog(@"UTC=========%@",utcDate);
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //输入格式
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
//    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
//    [dateFormatter setTimeZone:localTimeZone];
    
//    NSDate *dateFormatted = [dateFormatter dateFromString:utcDate];
    //输出格式
//    [dateFormatter setDateFormat:@"HH:mm a"];
//    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
//    NSLog(@"UTC=========%@",dateString);
    NSArray *arr = [[NSArray alloc] init];
    arr = [utcDate componentsSeparatedByString:@"T"];
    NSString *dateString;
    if ([arr count] >= 2) {
        if ([[[arr objectAtIndex:1] substringWithRange:NSMakeRange(0,2)] integerValue] > 12) {
            dateString = [NSString stringWithFormat:@"%@ pm",[[arr objectAtIndex:1] substringWithRange:NSMakeRange(0,5)]];
        }
        else
        {
            dateString = [NSString stringWithFormat:@"%@ am",[[arr objectAtIndex:1] substringWithRange:NSMakeRange(0,5)]];
        }
        
    }
    NSLog(@"hahahahhahahahah -----  %@",dateString);
    return dateString;
}


- (NSString *)ssDate:(NSString *)date
{
    NSString *dateString = [date stringByReplacingOccurrencesOfString:@"上午"withString:@"am"];
    dateString = [dateString stringByReplacingOccurrencesOfString:@"AM"withString:@"am"];
    dateString = [dateString stringByReplacingOccurrencesOfString:@"下午"withString:@"pm"];
    dateString = [dateString stringByReplacingOccurrencesOfString:@"PM"withString:@"pm"];
    NSString *hh = [dateString substringWithRange:NSMakeRange(0,2)];
    NSString *newHH=hh;
    NSLog(@"newhh:%@",newHH);
    if ([newHH integerValue]>12) {
        newHH=[NSString stringWithFormat:@"%li",[hh integerValue]-12];
    }
    if ([[newHH substringWithRange:NSMakeRange(0,1)] integerValue] == 0) {
       newHH = [hh stringByReplacingOccurrencesOfString:@"0"withString:@""];
    }
    if([newHH integerValue] == 00)
    {
        newHH = @"12";
    }
    dateString = [dateString stringByReplacingOccurrencesOfString:hh withString:newHH];
    
    NSArray *arr = [[NSArray alloc] init];
    arr = [dateString componentsSeparatedByString:@":"];
    NSString *newMM = [arr objectAtIndex:1];
    if ([[arr objectAtIndex:1] integerValue]<10 && [[arr objectAtIndex:1] integerValue] != 00 && [[[arr objectAtIndex:1] substringWithRange:NSMakeRange(0,1)] integerValue] != 0) {
        newMM = [NSString stringWithFormat:@"0%@",[arr objectAtIndex:1]];
    }
    dateString = [NSString stringWithFormat:@"%@:%@",[arr objectAtIndex:0],newMM];
    NSLog(@"sfsdfs-------   %@",dateString);
    return dateString;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
