//
//  LoginView.h
//  Glood
//
//  Created by sparxo-dev-ios-1 on 2016/12/6.
//  Copyright © 2016年 sparxo-dev-ios-1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginView : UIView<UITextFieldDelegate>

@property (retain, nonatomic) UIImageView *bgImageView;
@property (retain, nonatomic) UIButton *signInButton;
@property (retain, nonatomic) UIButton *signUpButton;
@property (retain, nonatomic) UIView *signInView;
@property (retain, nonatomic) UIView *signUpView;
@property (retain, nonatomic) UIButton *bottomLoginOrRegisterButton;
@property (retain, nonatomic) UITextField *emailTextField;
@property (retain, nonatomic) UITextField *passwordTextField;

@end
