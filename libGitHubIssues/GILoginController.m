//
//  GILoginController.m
//  Github Issues
//
//  Created by Matt Clarke on 16/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GILoginController.h"
#import "GIResources.h"
#import "OCTClient+Fingerprint.h"
#import <OctoKit.h>

typedef enum : NSUInteger {
    kGIStateBegin,
    kGIStateWaiting2FA,
} GILoginState;

@interface GILoginController ()

@property (nonatomic, readwrite) GILoginState state;

@end

@implementation GILoginController

-(instancetype)init {
    self = [super init];
    
    if (self) {
        [self.navigationItem setTitle:@"Sign In"];
        [self setTitle:@"Sign In"];
        self.state = kGIStateBegin;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.backer = [[UIView alloc] initWithFrame:CGRectZero];
    self.backer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.backer];
    
    UIImage *ret = [GIResources imageWithName:@"libGitHubIssues_Mark"];
    
    self.headerImageView = [[UIImageView alloc] initWithImage:ret];
    self.headerImageView.frame = CGRectMake(0, 0, 50, 50);
    
    [self.backer addSubview:self.headerImageView];
    
    self.explainLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.explainLabel.text = @"GitHub is used to keep track of bugs and features";
    self.explainLabel.numberOfLines = 0;
    self.explainLabel.textColor = [UIColor darkTextColor];
    self.explainLabel.textAlignment = NSTextAlignmentCenter;
    self.explainLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    [self.backer addSubview:self.explainLabel];
    
    UIView *leftBlock = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    leftBlock.backgroundColor = [UIColor clearColor];
    
    UIView *leftBlock2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    leftBlock2.backgroundColor = [UIColor clearColor];
    
    UIView *leftBlock3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    leftBlock3.backgroundColor = [UIColor clearColor];
    
    self.username = [[UITextField alloc] initWithFrame:CGRectZero];
    self.username.textAlignment = NSTextAlignmentNatural;
    self.username.textColor = [UIColor grayColor];
    self.username.placeholder = @"Username...";
    self.username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.username.autocorrectionType = UITextAutocorrectionTypeNo;
    self.username.returnKeyType = UIReturnKeyNext;
    self.username.delegate = self;
    [self.username addTarget:self action:@selector(textFieldContentDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.username.layer.cornerRadius = 2.5;
    self.username.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.username.layer.borderWidth = 1;
    self.username.leftView = leftBlock;
    self.username.leftViewMode = UITextFieldViewModeAlways;
    
    [self.backer addSubview:self.username];
    
    self.password = [[UITextField alloc] initWithFrame:CGRectZero];
    self.password.textAlignment = NSTextAlignmentNatural;
    self.password.textColor = [UIColor grayColor];
    self.password.placeholder = @"Password...";
    self.password.autocorrectionType = UITextAutocorrectionTypeNo;
    self.password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.password.secureTextEntry = YES;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.delegate = self;
    [self.password addTarget:self action:@selector(textFieldContentDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.password.layer.cornerRadius = 2.5;
    self.password.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.password.layer.borderWidth = 1;
    self.password.leftView = leftBlock2;
    self.password.leftViewMode = UITextFieldViewModeAlways;
    
    [self.backer addSubview:self.password];
    
    self.twoFactorAuthPassword = [[UITextField alloc] initWithFrame:CGRectZero];
    self.twoFactorAuthPassword.textAlignment = NSTextAlignmentNatural;
    self.twoFactorAuthPassword.textColor = [UIColor grayColor];
    self.twoFactorAuthPassword.placeholder = @"Enter code...";
    self.twoFactorAuthPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.twoFactorAuthPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.twoFactorAuthPassword.secureTextEntry = YES;
    self.twoFactorAuthPassword.returnKeyType = UIReturnKeyDone;
    self.twoFactorAuthPassword.delegate = self;
    [self.twoFactorAuthPassword addTarget:self action:@selector(textFieldContentDidChange2FA:) forControlEvents:UIControlEventEditingChanged];
    self.twoFactorAuthPassword.layer.cornerRadius = 2.5;
    self.twoFactorAuthPassword.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.twoFactorAuthPassword.layer.borderWidth = 1;
    self.twoFactorAuthPassword.leftView = leftBlock3;
    self.twoFactorAuthPassword.leftViewMode = UITextFieldViewModeAlways;
    self.twoFactorAuthPassword.hidden = YES;
    
    [self.backer addSubview:self.twoFactorAuthPassword];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.loginButton addTarget:self action:@selector(didClickLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton setTitle:@"Sign In" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Sign In" forState:UIControlStateDisabled];
    self.loginButton.enabled = NO;
    
    // Styling.
    [self.loginButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.loginButton.layer.borderWidth = 1;
    self.loginButton.backgroundColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.84 alpha:1.0];
    self.loginButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.loginButton.layer.cornerRadius = 2.5;
    
    [self.backer addSubview:self.loginButton];
    
    // Submit code for 2FA
    self.twoFAButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.twoFAButton addTarget:self action:@selector(didClickLoginWith2FA:) forControlEvents:UIControlEventTouchUpInside];
    [self.twoFAButton setTitle:@"Submit Code" forState:UIControlStateNormal];
    [self.twoFAButton setTitle:@"Submit Code" forState:UIControlStateDisabled];
    self.twoFAButton.enabled = NO;
    self.twoFAButton.hidden = YES;
    
    // Styling.
    [self.twoFAButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.twoFAButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.twoFAButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    self.twoFAButton.layer.borderWidth = 1;
    self.twoFAButton.backgroundColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.84 alpha:1.0];
    self.twoFAButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.twoFAButton.layer.cornerRadius = 2.5;
    
    [self.backer addSubview:self.twoFAButton];
    
    // Cancel button for going back from 2FA UI
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton addTarget:self action:@selector(didClickCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.enabled = YES;
    self.cancelButton.hidden = YES;
    
    // Styling.
    [self.cancelButton setTitleColor:[UIColor colorWithRed:0.86 green:0.38 blue:0.38 alpha:1.0] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:0.87 green:0.61 blue:0.61 alpha:1.0] forState:UIControlStateHighlighted];
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.backgroundColor = [UIColor colorWithRed:0.93 green:0.80 blue:0.80 alpha:1.0];
    self.cancelButton.layer.borderColor = [UIColor colorWithRed:0.87 green:0.61 blue:0.61 alpha:1.0].CGColor;
    self.cancelButton.layer.cornerRadius = 2.5;
    
    [self.backer addSubview:self.cancelButton];
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectZero];
    self.separatorView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    [self.backer addSubview:self.separatorView];
    
    self.createAccount = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.createAccount addTarget:self action:@selector(didClickCreateNewAccount:) forControlEvents:UIControlEventTouchUpInside];
    [self.createAccount setTitle:@"Sign Up for GitHub" forState:UIControlStateNormal];
    
    [self.createAccount setTitleColor:[UIColor colorWithRed:103.0f/255.0f green:153.0f/255.0f blue:76.0f/255.0f alpha:1.0] forState:UIControlStateNormal];
    [self.createAccount setTitleColor:[UIColor colorWithRed:180.0f/255.0f green:219.0f/255.0f blue:158.0f/255.0f alpha:1.0] forState:UIControlStateHighlighted];
    self.createAccount.layer.borderWidth = 1;
    self.createAccount.backgroundColor = [UIColor colorWithRed:218.0f/255.0f green:241.0f/255.0f blue:205.0f/255.0f alpha:1.0];
    self.createAccount.layer.borderColor = [UIColor colorWithRed:180.0f/255.0f green:219.0f/255.0f blue:158.0f/255.0f alpha:1.0].CGColor;
    self.createAccount.layer.cornerRadius = 2.5;
    
    [self.backer addSubview:self.createAccount];
    
    self.spinny = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.spinny.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.spinny.hidden = YES;
    
    [self.backer addSubview:self.spinny];
}

-(void)viewDidLayoutSubviews {
    // Setup our UI.
    [super viewDidLayoutSubviews];
    
    // Set initial width for backer.
    // TODO: Adjust for iPad.
    CGFloat maxWidth = self.view.frame.size.width*0.75;
    
    CGFloat y = 0;
    
    self.headerImageView.frame = CGRectMake(maxWidth/2 - 25, y, 50, 50);
    
    y += self.headerImageView.frame.size.height + 10;
    
    CGRect rect = [GIResources boundedRectForFont:self.explainLabel.font andText:self.explainLabel.text width:maxWidth];
    self.explainLabel.frame = CGRectMake(maxWidth/2 - rect.size.width/2, y, rect.size.width, rect.size.height);
    
    y += self.explainLabel.frame.size.height + 20;
    
    if (self.state == kGIStateBegin) {
        self.username.frame = CGRectMake(0, y, maxWidth, 40);
    
        y += self.username.frame.size.height + 5;
    
        self.password.frame = CGRectMake(self.username.frame.origin.x, y, self.username.frame.size.width, self.username.frame.size.height);
        
        y += self.password.frame.size.height + 5;
    
        self.loginButton.frame = CGRectMake(self.username.frame.origin.x, y, self.username.frame.size.width, 40);
    
        y += self.loginButton.frame.size.height + 20;
    
        self.separatorView.frame = CGRectMake(self.username.frame.origin.x, y, self.username.frame.size.width, 1);
    
        y += 21;
    
        self.createAccount.frame = CGRectMake(self.username.frame.origin.x, y, self.username.frame.size.width, self.loginButton.frame.size.height);
    
        y += self.createAccount.frame.size.height;
    } else {
        self.twoFactorAuthPassword.frame = CGRectMake(0, y, maxWidth, 40);
        
        y += self.twoFactorAuthPassword.frame.size.height + 5;
        
        self.twoFAButton.frame = CGRectMake(self.twoFactorAuthPassword.frame.origin.x, y, self.twoFactorAuthPassword.frame.size.width, 40);
        
        y += self.twoFAButton.frame.size.height + 20;
        
        self.separatorView.frame = CGRectMake(self.username.frame.origin.x, y, self.username.frame.size.width, 1);
        
        y += 21;
        
        self.cancelButton.frame = CGRectMake(self.twoFactorAuthPassword.frame.origin.x, y, self.twoFactorAuthPassword.frame.size.width, 40);
        
        y += self.cancelButton.frame.size.height;
    }
    
    self.backer.frame = CGRectMake(self.view.frame.size.width/2 - maxWidth/2, self.view.frame.size.height/2 - y/2, maxWidth, y);
}

#pragma mark UIButton Callbacks

-(void)didClickLoginButton:(id)sender {
    NSLog(@"Clicked login!");
    
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    
    NSString *pass = self.password.text;
    
    OCTUser *user = [OCTUser userWithRawLogin:self.username.text server:OCTServer.dotComServer];
    
    self.spinny.hidden = NO;
    self.spinny.alpha = 0.0;
    self.spinny.center = self.loginButton.center;
    [self.spinny startAnimating];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.spinny.alpha = 1.0;
        self.loginButton.alpha = 0.25;
    }];
    
    NSString *fingerprint = [GIResources _generateFingerprint];
    
    [[[OCTClient
       _gi_signInAsUser:user password:pass oneTimePassword:nil scopes:OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesRepository note:@"GitHub Issues App" noteURL:nil fingerprint:fingerprint]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTClient *client) {
         
         // We have success!
         [self _successfulAuth:client];
         
         [UIView animateWithDuration:0.15 animations:^{
             self.spinny.alpha = 0.0;
             self.loginButton.alpha = 1.0;
         } completion:^(BOOL finished) {
             [self.spinny stopAnimating];
             self.spinny.hidden = YES;
         }];
         
     } error:^(NSError *error) {
         if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorTwoFactorAuthenticationOneTimePasswordRequired) {
             // Show OTP field and have the user try again.
             [self _show2FAWithAnimation:YES];
         } else {
             // The error isn't a 2FA prompt, so present it to the user.
             [self _presentError:error];
         }
         
         [UIView animateWithDuration:0.15 animations:^{
             self.spinny.alpha = 0.0;
             self.loginButton.alpha = 1.0;
         } completion:^(BOOL finished) {
             [self.spinny stopAnimating];
             self.spinny.hidden = YES;
         }];
     }];
}

-(void)_successfulAuth:(OCTClient*)client {    
    [GIResources _setSuccessfulClient:client];
    
    // Now, we move back to whatever called us with this client.
    [self.delegate didFinishAuthenticationWithClient:client];
}

-(void)_presentError:(NSError*)error {
    if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorAuthenticationFailed) {
        
        if (self.state == kGIStateBegin) {
            self.explainLabel.text = @"Authentication failed!\nIncorrect username or password";
        } else {
            self.explainLabel.text = @"Authentication failed!\nInvalid 2-Factor code provided";
        }
        
        CGRect rect = [GIResources boundedRectForFont:self.explainLabel.font andText:self.explainLabel.text width:self.backer.frame.size.width];
        self.explainLabel.frame = CGRectMake(self.backer.frame.size.width/2 - rect.size.width/2, self.explainLabel.frame.origin.y, rect.size.width, rect.size.height);
        self.explainLabel.textColor = [UIColor colorWithRed:0.63 green:0.02 blue:0.02 alpha:1.0];
        
        return;
        
    } else if ([error.domain isEqual:OCTClientErrorDomain] && error.code == OCTClientErrorRequestForbidden) {
        
        self.explainLabel.text = @"Too many attempts to sign in, please try again later.";
        CGRect rect = [GIResources boundedRectForFont:self.explainLabel.font andText:self.explainLabel.text width:self.backer.frame.size.width];
        self.explainLabel.frame = CGRectMake(self.backer.frame.size.width/2 - rect.size.width/2, self.explainLabel.frame.origin.y, rect.size.width, rect.size.height);
        self.explainLabel.textColor = [UIColor colorWithRed:0.63 green:0.02 blue:0.02 alpha:1.0];
        
        return;
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error.localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

-(void)_show2FAWithAnimation:(BOOL)anim {
    self.state = kGIStateWaiting2FA;
    
    [self.twoFactorAuthPassword setText:nil];
    
    // Setup frames.
    self.twoFactorAuthPassword.alpha = 0.0;
    self.twoFactorAuthPassword.hidden = NO;
    self.twoFAButton.alpha = 0.0;
    self.twoFAButton.hidden = NO;
    self.cancelButton.alpha = 0.0;
    self.cancelButton.hidden = NO;
    
    // Initialise these two views frames to what they will replace.
    self.twoFAButton.frame = self.loginButton.frame;
    self.twoFactorAuthPassword.frame = self.password.frame;
    self.cancelButton.frame = self.createAccount.frame;
    
    self.explainLabel.text = @"This account uses 2-Factor Authentication, and needs a code";
    CGRect rect = [GIResources boundedRectForFont:self.explainLabel.font andText:self.explainLabel.text width:self.backer.frame.size.width];
    self.explainLabel.frame = CGRectMake(self.backer.frame.size.width/2 - rect.size.width/2, self.explainLabel.frame.origin.y, rect.size.width, rect.size.height);
    self.explainLabel.textColor = [UIColor darkTextColor];
    
    [UIView animateWithDuration:anim ? 0.3 : 0.0 animations:^{
        self.loginButton.alpha = 0.0;
        self.twoFAButton.alpha = 1.0;
        
        self.password.alpha = 0.0;
        self.twoFactorAuthPassword.alpha = 1.0;
        
        self.createAccount.alpha = 0.0;
        self.cancelButton.alpha = 1.0;
        
        self.username.alpha = 0.0;
        
        [self viewDidLayoutSubviews];
    } completion:^(BOOL finished) {
        self.loginButton.hidden = YES;
        self.password.hidden = YES;
        self.username.hidden = YES;
        self.createAccount.hidden = YES;
    }];
}

-(void)didClickLoginWith2FA:(id)sender {
    [self.twoFactorAuthPassword resignFirstResponder];
    
    NSString *pass = self.password.text;
    NSString *twoFA = self.twoFactorAuthPassword.text;
    
    OCTUser *user = [OCTUser userWithRawLogin:self.username.text server:OCTServer.dotComServer];
    
    self.spinny.hidden = NO;
    self.spinny.alpha = 0.0;
    self.spinny.center = self.twoFAButton.center;
    [self.spinny startAnimating];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.spinny.alpha = 1.0;
        self.twoFAButton.alpha = 0.0;
    }];
    
    NSString *fingerprint = [GIResources _generateFingerprint];
    
    [[[OCTClient
       _gi_signInAsUser:user password:pass oneTimePassword:twoFA scopes:OCTClientAuthorizationScopesUser | OCTClientAuthorizationScopesRepository note:@"GitHub Issues App" noteURL:nil fingerprint:fingerprint]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(OCTClient *client) {
         
        // We have success!
        [self _successfulAuth:client];
         
         [UIView animateWithDuration:0.15 animations:^{
             self.spinny.alpha = 0.0;
             self.twoFAButton.alpha = 1.0;
         } completion:^(BOOL finished) {
             [self.spinny stopAnimating];
             self.spinny.hidden = YES;
         }];
         
     } error:^(NSError *error) {
        [self _presentError:error];
         
         [UIView animateWithDuration:0.15 animations:^{
             self.spinny.alpha = 0.0;
             self.twoFAButton.alpha = 1.0;
         } completion:^(BOOL finished) {
             [self.spinny stopAnimating];
             self.spinny.hidden = YES;
         }];
     }];
    
}

-(void)didClickCancel:(id)sender {
    [self.twoFactorAuthPassword resignFirstResponder];
    
    self.state = kGIStateBegin;
    
    // Revert to "begin" state.
    [self.username setText:nil];
    [self.password setText:nil];
    
    self.loginButton.hidden = NO;
    self.password.hidden = NO;
    self.username.hidden = NO;
    self.createAccount.hidden = NO;
    
    self.loginButton.frame = self.twoFAButton.frame;
    self.password.frame = self.twoFactorAuthPassword.frame;
    self.createAccount.frame = self.cancelButton.frame;
    
    self.explainLabel.text = @"GitHub is used to keep track of bugs and features";
    CGRect rect = [GIResources boundedRectForFont:self.explainLabel.font andText:self.explainLabel.text width:self.backer.frame.size.width];
    self.explainLabel.frame = CGRectMake(self.backer.frame.size.width/2 - rect.size.width/2, self.explainLabel.frame.origin.y, rect.size.width, rect.size.height);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.loginButton.alpha = 1.0;
        self.twoFAButton.alpha = 0.0;
        
        self.password.alpha = 1.0;
        self.twoFactorAuthPassword.alpha = 0.0;
        
        self.createAccount.alpha = 1.0;
        self.cancelButton.alpha = 0.0;
        
        self.username.alpha = 1.0;
        
        [self viewDidLayoutSubviews];
    } completion:^(BOOL finished) {
        self.twoFAButton.hidden = YES;
        self.twoFactorAuthPassword.hidden = YES;
        self.cancelButton.hidden = YES;
    }];
    
}


-(void)didClickCreateNewAccount:(id)sender {
    // Open Safari for the user to create an account
    NSURL *url = [NSURL URLWithString:@"https://github.com/join"];
    [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:nil];
}

#pragma mark UITextField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.username]) {
        [self.password becomeFirstResponder];
        return NO;
    } else if ([textField isEqual:self.password]) {
        [self.password resignFirstResponder];
        return NO;
    } else if ([textField isEqual:self.twoFactorAuthPassword]) {
        [self.twoFactorAuthPassword resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)textFieldContentDidChange:(UITextField*)sender {
    // If both the password and username fields have content, enable login button.
    if (self.username.text &&
        ![self.username.text isEqualToString:@""] &&
        self.password.text &&
        ![self.password.text isEqualToString:@""]) {
        self.loginButton.enabled = YES;
    } else if (self.loginButton.enabled) {
        self.loginButton.enabled = NO;
    }
}

-(void)textFieldContentDidChange2FA:(UITextField*)sender {
    // If both the password and username fields have content, enable login button.
    if (self.twoFactorAuthPassword.text &&
        ![self.twoFactorAuthPassword.text isEqualToString:@""]) {
        self.twoFAButton.enabled = YES;
    } else if (self.twoFAButton.enabled) {
        self.twoFAButton.enabled = NO;
    }
}

@end
