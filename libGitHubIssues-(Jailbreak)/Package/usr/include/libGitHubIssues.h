//
//  GIRootViewController.h
//  Github Issues
//
//  Created by Matt Clarke on 16/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

/*
  Usage:
  
  #import <libGitHubIssues.h>

  ...

  GIRootViewController *rootModal = [[GIRootViewController alloc] init];

  [GIRootViewController registerClientID:@"<client_id>" andSecret:@"<client_secret>"];
  [GIRootViewController registerCurrentRepositoryName:@"<repo_name>" andOwner:@"<repo_owner>"];

  [self presentViewController:rootModal animated:YES completion:nil];
*/

#import <UIKit/UIKit.h>

@interface GIRootViewController : UINavigationController

/**
 Configure libGitHubIssues with an identifier with the client ID and secret for your application on GitHub.\n\n
 
 The client ID and secret can be found at: https://github.com/settings/developers
 
 @param clientId Cient ID from your GitHub application.
 @param clientSecret Client secret from your GitHub application.
 */
+(void)registerClientID:(NSString*)clientId andSecret:(NSString*)clientSecret;

/**
 Configure which repository libGitHubIssues should access Issues from.\n\n
 
 Parameters are in the form: https://github.com/<owner>/<name>
 
 @param name Name of repository
 @param owner Owner of repository
 */
+(void)registerCurrentRepositoryName:(NSString*)name andOwner:(NSString*)owner;

@end

