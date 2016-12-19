//
//  OCTClient+Fingerprint.h
//  libGitHubIssues
//
//  Created by Matt Clarke on 19/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OctoKit/OctoKit.h>

@interface OCTClient (GIFingerprint)

+ (RACSignal *)_gi_signInAsUser:(OCTUser *)user password:(NSString *)password oneTimePassword:(NSString *)oneTimePassword scopes:(OCTClientAuthorizationScopes)scopes note:(NSString *)note noteURL:(NSURL *)noteURL fingerprint:(NSString *)fingerprint;

@end
