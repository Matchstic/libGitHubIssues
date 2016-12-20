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
#import <OctoKit/OctoKit.h>

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
    
    GIIssuesViewController *table = [[GIIssuesViewController alloc] init];
    [self setViewControllers:@[table] animated:NO];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(didClickCancel:)];
    table.navigationItem.leftBarButtonItem = cancel;
}

-(void)didClickCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
