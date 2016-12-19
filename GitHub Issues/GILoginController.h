//
//  GILoginController.h
//  Github Issues
//
//  Created by Matt Clarke on 16/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GILoginControllerDelegate <NSObject>

-(void)didFinishAuthenticationWithClient:(id)client;

@end

@interface GILoginController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) id<GILoginControllerDelegate> delegate;

@property (nonatomic, strong) UIView *backer;

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *explainLabel;

@property (nonatomic, strong) UITextField *username;
@property (nonatomic, strong) UITextField *password;
@property (nonatomic, strong) UITextField *twoFactorAuthPassword;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *twoFAButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinny;

@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIButton *createAccount;

-(void)_show2FAWithAnimation:(BOOL)anim;

@end
