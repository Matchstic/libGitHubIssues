//
//  ViewController.m
//  libGitHubIssues Demo
//
//  Created by Matt Clarke on 19/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "ViewController.h"
#import "GIRootViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view, typically from a nib.
    
    GIRootViewController *rootModal = [[GIRootViewController alloc] init];
    
    /*
     * For your own implementation, you would specify the client ID and secret as explained in the README.
     * However, I have omitted them here as it is *strongly* advised not to make these public.
     *
     * Not providing them here just prevents users from being able to login.
     */
    [GIRootViewController registerIdentifier:@"com.matchstic.libGitHubIssues-Demo" clientID:@"" andSecret:@""];
    [GIRootViewController registerCurrentRepositoryName:@"octokit.objc" andOwner:@"octokit"];
    
    [self presentViewController:rootModal animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
