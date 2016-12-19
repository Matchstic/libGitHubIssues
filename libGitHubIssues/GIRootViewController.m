//
//  GIRootViewController.m
//  Github Issues
//
//  Created by Matt Clarke on 16/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIRootViewController.h"
#import "GILoginController.h"
#import "GIIssuesViewController.h"
#import "GIResources.h"
#import <OctoKit.h>

@interface GIRootViewController ()

@end

@implementation GIRootViewController

+(void)registerClientID:(NSString*)clientId andSecret:(NSString*)clientSecret {
    [GIResources _registerClientID:clientId andSecret:clientSecret];
}

+(void)registerCurrentRepositoryName:(NSString*)name andOwner:(NSString*)owner {
    [GIResources _setCurrentRepositoryName:name andOwner:owner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationBar setBarStyle:UIBarStyleDefault];
    
    // If no pre-existing OAuth session in Keychain, use an unathenticated user.
    // Else, make use of the current session.
    
    OCTClient *client = [GIResources _getCurrentClient];
    [self _loadFromExistingLogin:client];
}

-(void)loadFromNewLogin:(OCTClient*)client {    
    [self _loadFromExistingLogin:client];
}

-(void)_loadLoginControllerWith2FA:(BOOL)with2FA {
    GILoginController *table = [[GILoginController alloc] init];
    if (with2FA) [table _show2FAWithAnimation:NO];
    
    [self setViewControllers:@[table] animated:YES];
}

-(void)_loadFromExistingLogin:(OCTClient*)client {
    NSLog(@"Loading from existing login...");
    
    GIIssuesViewController *table = [[GIIssuesViewController alloc] initWithClient:nil];
    [self setViewControllers:@[table] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
