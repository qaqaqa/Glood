//
//  LoginView.m
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import "LoginView.h"
#import "Define.h"

@interface LoginView()

@end

@implementation LoginView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.bgImageView setImage:[UIImage imageNamed:@"bg"]];
        [self addSubview:self.bgImageView];
        
        UIScrollView *bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        bgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT*2-(SCREEN_HEIGHT*79/568));
        bgScrollView.bounces = NO;
        [self addSubview:bgScrollView];
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-(SCREEN_HEIGHT*79/568))];
        [bgScrollView addSubview:topView];
        
        UIImageView *eyeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*153/320))/2, (SCREEN_HEIGHT*50/568), SCREEN_WIDTH*153/320, SCREEN_HEIGHT*184/568)];
        [eyeImageView setImage:[UIImage imageNamed:@"eye"]];
        [topView addSubview:eyeImageView];
        
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*23/320))/2, eyeImageView.frame.origin.y+eyeImageView.frame.size.height-SCREEN_HEIGHT*20/568, SCREEN_WIDTH*23/320, SCREEN_HEIGHT*139/568)];
        [lineImageView setImage:[UIImage imageNamed:@"line"]];
        [topView addSubview:lineImageView];
        
        UIImageView *gloodLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-(SCREEN_WIDTH*136/320))/2+SCREEN_WIDTH*10/320, lineImageView.frame.size.height+lineImageView.frame.origin.y-SCREEN_HEIGHT*40/568, SCREEN_WIDTH*136/320, SCREEN_HEIGHT*80/568)];
        [gloodLogoImageView setImage:[UIImage imageNamed:@"glood_text2"]];
        [topView addSubview:gloodLogoImageView];
        
        UIImageView *rowLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-SCREEN_HEIGHT*79/568, SCREEN_WIDTH, 1)];
        rowLineImageView.backgroundColor = [UIColor whiteColor];
        [topView addSubview:rowLineImageView];
        
        UIImageView *changeSigninOrUpBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, rowLineImageView.frame.origin.y+0.5, SCREEN_WIDTH, SCREEN_HEIGHT*79/568)];
        changeSigninOrUpBgImageView.backgroundColor = [UIColor whiteColor];
        changeSigninOrUpBgImageView.alpha = 0.3f;
        [topView addSubview:changeSigninOrUpBgImageView];
        
        self.signInButton = [[UIButton alloc] initWithFrame:CGRectMake(0, topView.frame.origin.y+topView.frame.size.height, SCREEN_WIDTH/2, changeSigninOrUpBgImageView.frame.size.height)];
        [self.signInButton setTitle:@"sign in" forState:UIControlStateNormal];
        self.signInButton.titleLabel.font = [UIFont systemFontOfSize:25.f];
        [self.signInButton setTitleColor:[UIColor colorWithRed:49/255.0 green:157/255.0 blue:237/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.signInButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.signInButton addTarget:self action:@selector(onSignInBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgScrollView addSubview:self.signInButton];
        
        self.signUpButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, topView.frame.origin.y+topView.frame.size.height, SCREEN_WIDTH/2, changeSigninOrUpBgImageView.frame.size.height)];
        [self.signUpButton setTitle:@"sign up" forState:UIControlStateNormal];
        self.signUpButton.titleLabel.font = [UIFont systemFontOfSize:25.f];
        [self.signUpButton setTitleColor:[UIColor colorWithRed:157/255.0 green:158/255.0 blue:160/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.signUpButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.signUpButton addTarget:self action:@selector(onSignUpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgScrollView addSubview:self.signUpButton];
        
        //sign in
        self.signInView = [[UIView alloc] initWithFrame:CGRectMake(0, self.signInButton.frame.size.height+self.signInButton.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.signInView setHidden:NO];
        [bgScrollView addSubview:self.signInView];
        
        UILabel *titleEmail = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*40/320, SCREEN_HEIGHT*90/568, SCREEN_WIDTH*150/320, SCREEN_HEIGHT*30/568)];
        titleEmail.text = @"email";
        titleEmail.font = [UIFont fontWithName:@"ProximaNova-Light.otf" size:17];
        titleEmail.textColor = [UIColor colorWithRed:115/255.0 green:113/255.0 blue:114/255.0 alpha:1.0];
        [self.signInView addSubview:titleEmail];
        
        self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(titleEmail.frame.origin.x, titleEmail.frame.size.height+titleEmail.frame.origin.y-10, SCREEN_WIDTH*240/320, 40)];
        self.emailTextField.borderStyle = UITextBorderStyleNone;
        self.emailTextField.returnKeyType = UIReturnKeyNext;
        self.emailTextField.backgroundColor = [UIColor clearColor];
        self.emailTextField.delegate = self;
        [self.signInView addSubview:self.emailTextField];
        
        UIImageView *emailLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.emailTextField.frame.origin.x-5, self.emailTextField.frame.size.height+self.emailTextField.frame.origin.y-8, self.emailTextField.frame.size.width+10, 0.3)];
        emailLineImageView.backgroundColor = [UIColor blackColor];
        [self.signInView addSubview:emailLineImageView];
        
        UILabel *titlePassworde = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*40/320, emailLineImageView.frame.origin.y+30, SCREEN_WIDTH*150/320, SCREEN_HEIGHT*30/568)];
        titlePassworde.text = @"password";
        titlePassworde.font = [UIFont fontWithName:@"ProximaNova-Light.otf" size:17];
        titlePassworde.textColor = [UIColor colorWithRed:115/255.0 green:113/255.0 blue:114/255.0 alpha:1.0];
        [self.signInView addSubview:titlePassworde];
        
        self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(titlePassworde.frame.origin.x, titlePassworde.frame.size.height+titlePassworde.frame.origin.y-10, SCREEN_WIDTH*240/320, 40)];
        self.passwordTextField.secureTextEntry = YES;
        self.passwordTextField.borderStyle = UITextBorderStyleNone;
        self.passwordTextField.returnKeyType = UIReturnKeyGo;
        self.passwordTextField.delegate = self;
        [self.signInView addSubview:self.passwordTextField];
        
        UIImageView *passwordLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.passwordTextField.frame.origin.x-5, self.passwordTextField.frame.size.height+self.passwordTextField.frame.origin.y-8, self.passwordTextField.frame.size.width+10, 0.3)];
        passwordLineImageView.backgroundColor = [UIColor blackColor];
        [self.signInView addSubview:passwordLineImageView];
        
        UIButton *forgetButton = [[UIButton alloc] initWithFrame:CGRectMake(passwordLineImageView.frame.origin.x, passwordLineImageView.frame.size.height+passwordLineImageView.frame.origin.y+10, passwordLineImageView.frame.size.width, 35)];
        [forgetButton setTitle:@"forget password?" forState:UIControlStateNormal];
        [forgetButton setTitleColor:[UIColor colorWithRed:115/255.0 green:113/255.0 blue:114/255.0 alpha:1.0] forState:UIControlStateNormal];
        forgetButton.titleLabel.textAlignment = NSTextAlignmentRight;
        [self.signInView addSubview:forgetButton];
        
        //sign up
        self.signUpView = [[UIView alloc] initWithFrame:CGRectMake(0, self.signInButton.frame.size.height+self.signInButton.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.signUpView setHidden:YES];
        [bgScrollView addSubview:self.signUpView];
        
        //login or register
        self.bottomLoginOrRegisterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (2*SCREEN_HEIGHT)-(SCREEN_HEIGHT*129/568), SCREEN_WIDTH, SCREEN_HEIGHT*50/568)];
        [self.bottomLoginOrRegisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.bottomLoginOrRegisterButton.titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
        [self.bottomLoginOrRegisterButton setTitle:@"sign in" forState:UIControlStateNormal];
        self.bottomLoginOrRegisterButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.bottomLoginOrRegisterButton.backgroundColor = [UIColor colorWithRed:72/255.0 green:164/255.0 blue:233/255.0 alpha:1];
        [bgScrollView addSubview:self.bottomLoginOrRegisterButton];
        
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField == self.emailTextField)
        [self.passwordTextField becomeFirstResponder];
    
    else{
        [self.emailTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
        //登陆
    }
    
    return NO;
}

- (void)onSignInBtnClick:(id)sender
{
    [self.signInView setHidden:NO];
    [self.signUpView setHidden:YES];
    [self.bottomLoginOrRegisterButton setTitle:@"sign in" forState:UIControlStateNormal];
    [self.signInButton setTitleColor:[UIColor colorWithRed:49/255.0 green:157/255.0 blue:237/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:[UIColor colorWithRed:157/255.0 green:158/255.0 blue:160/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)onSignUpBtnClick:(id)sender
{
    [self.signInView setHidden:YES];
    [self.signUpView setHidden:NO];
    [self.bottomLoginOrRegisterButton setTitle:@"sign up" forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:[UIColor colorWithRed:49/255.0 green:157/255.0 blue:237/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.signInButton setTitleColor:[UIColor colorWithRed:157/255.0 green:158/255.0 blue:160/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

@end
