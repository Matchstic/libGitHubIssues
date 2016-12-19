//
//  GIUserViewController.h
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIUserViewController : UIViewController

@property (nonatomic, strong) UIImageView *backgroundAvatarView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIVisualEffectView *vibrancyView;

@property (nonatomic, strong) UIView *centraliserView;
@property (nonatomic, strong) UIImageView *foregroundAvatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UIView *separatorView;

@property (nonatomic, strong) UIButton *logoutButton;

@end
