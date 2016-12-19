//
//  GIUserViewController.m
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIUserViewController.h"
#import "GIResources.h"
#import <OctoKit.h>
#import <AFNetworking/AFNetworking.h>

@interface GIUserViewController ()

@end

@implementation GIUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:@"Loading..."];
    [self setTitle:@"Loading..."];
    
    OCTClient *client = (OCTClient*)[GIResources _getCurrentClient];
    
    RACSignal *sig = [client fetchUserInfo];
    [[sig collect] subscribeNext:^(NSArray *issues) {
        
        OCTUser *user = [issues firstObject];
        
        GIUserViewController * __weak weakself = self;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:user.avatarURL];
        [self.backgroundAvatarView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakself.backgroundAvatarView.image = image;
        } failure:nil];
        
        [self.foregroundAvatarView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakself.foregroundAvatarView.image = image;
        } failure:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationItem setTitle:@"Profile"];
            [self setTitle:@"Profile"];
            
            self.nameLabel.text = user.name;
            self.emailLabel.text = user.email;
        });
        
    } error:^(NSError *error) {
        // Invoked when an error occurs. You won't receive any results if this
        // happens.
        [self _presentError:error];
        
        [self.navigationItem setTitle:@"Error"];
        [self setTitle:@"Error"];
    }];
    
}

-(void)_presentError:(NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error.localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.backgroundAvatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.backgroundAvatarView.backgroundColor = [UIColor grayColor];
    self.backgroundAvatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundAvatarView.layer.masksToBounds = YES;
    
    [self.view addSubview:self.backgroundAvatarView];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.effectView.frame = CGRectZero;
    
    [self.view addSubview:self.effectView];
    
    self.centraliserView = [[UIView alloc] initWithFrame:CGRectZero];
    self.centraliserView.backgroundColor = [UIColor clearColor];
    
    [self.effectView.contentView addSubview:self.centraliserView];
    
    self.foregroundAvatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.foregroundAvatarView.backgroundColor = [UIColor lightGrayColor];
    self.foregroundAvatarView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.foregroundAvatarView.layer.borderWidth = 1;
    self.foregroundAvatarView.layer.masksToBounds = YES;
    self.foregroundAvatarView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.centraliserView addSubview:self.foregroundAvatarView];
    
    self.vibrancyView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:effect]];
    self.vibrancyView.frame = CGRectZero;
    
    [self.centraliserView addSubview:self.vibrancyView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.text = @"Loading";
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    
    [self.vibrancyView.contentView addSubview:self.nameLabel];
    
    self.emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.emailLabel.text = @"Loading";
    self.emailLabel.textAlignment = NSTextAlignmentCenter;
    self.emailLabel.font = [UIFont systemFontOfSize:14];
    
    [self.vibrancyView.contentView  addSubview:self.emailLabel];
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorView.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1.0];
    
    [self.view addSubview:self.separatorView];
    
    // Handle logout button.
    self.logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.logoutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor colorWithRed:0.86 green:0.38 blue:0.38 alpha:1.0] forState:UIControlStateNormal];
    [self.logoutButton setTitleColor:[UIColor colorWithRed:0.87 green:0.61 blue:0.61 alpha:1.0] forState:UIControlStateHighlighted];
    self.logoutButton.titleLabel.font = [UIFont systemFontOfSize:18];
    self.logoutButton.backgroundColor = [UIColor colorWithRed:0.93 green:0.80 blue:0.80 alpha:1.0];
    self.logoutButton.layer.borderColor = [UIColor colorWithRed:0.87 green:0.61 blue:0.61 alpha:1.0].CGColor;
    self.logoutButton.layer.borderWidth = 1;
    
    [self.logoutButton addTarget:self action:@selector(didTapLogoutButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.logoutButton];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat initialY = 0;
    initialY += [[UIApplication sharedApplication] statusBarFrame].size.height;
    initialY += self.navigationController.navigationBar.frame.size.height;
    
    // First, background image. Square if possible, but never taller than 40% of the height.
    CGFloat width = self.view.frame.size.width;
    CGFloat height = width;
    
    if (height > self.view.frame.size.height * 0.4) {
        height = self.view.frame.size.height * 0.4;
    }
    
    self.backgroundAvatarView.frame = CGRectMake(0, initialY, width, height);
    
    // Effect view.
    self.effectView.frame = self.backgroundAvatarView.frame;
    
    // Next, set up the centraliser view.
    CGFloat y = 0;
    
    self.foregroundAvatarView.frame = CGRectMake(self.view.frame.size.width/2 - 50, y, 100, 100);
    self.foregroundAvatarView.layer.cornerRadius = 100/2;
    
    y += self.foregroundAvatarView.frame.size.height + 10;
    
    self.vibrancyView.frame = CGRectMake(0, y, self.view.frame.size.width, 45);
    
    self.nameLabel.frame = CGRectMake(0, 0, self.view.frame.size.width, 20);
    
    y += self.nameLabel.frame.size.height + 5;
    
    self.emailLabel.frame = CGRectMake(0, self.nameLabel.frame.size.height + 5, self.view.frame.size.width, 20);
    
    y += self.emailLabel.frame.size.height;
    
    // However, if the height space available is less than the centraliser's height, we got a problem.
    
    if (y >= height) {
        height = y + 20;
        
        self.backgroundAvatarView.frame = CGRectMake(0, initialY, width, height);
        self.effectView.frame = self.backgroundAvatarView.frame;
        
        self.centraliserView.frame = CGRectMake(0, 10, self.view.frame.size.width, y);
    } else {
        self.centraliserView.frame = CGRectMake(0, self.effectView.frame.size.height/2 - y/2, self.view.frame.size.width, y);
    }
    
    self.separatorView.frame = CGRectMake(0, self.backgroundAvatarView.frame.size.height + self.backgroundAvatarView.frame.origin.y, self.view.frame.size.width, 1);
    
    self.logoutButton.frame = CGRectMake(-1, self.backgroundAvatarView.frame.size.height + self.backgroundAvatarView.frame.origin.y + 40, self.view.frame.size.width+2, 44);
}

-(void)didTapLogoutButton:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Out" message:@"Are you sure you want to sign out?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          
                                                              [GIResources _setSuccessfulClient:nil];
                                                              [self.navigationController popViewControllerAnimated:YES];
                                                              
                                                          }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
