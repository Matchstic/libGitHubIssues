//
//  OCTClient+Fingerprint.m
//  libGitHubIssues
//
//  Created by Matt Clarke on 19/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "OCTClient+Fingerprint.h"
#import <OctoKit/OCTClient.h>
#import <OctoKit/OCTAuthorization.h>

static NSString * const _gi_OCTClientOneTimePasswordHeaderField = @"X-GitHub-OTP";

@interface OCTClient ()
@property (nonatomic, strong, readwrite) OCTUser *user;
@property (nonatomic, copy, readwrite) NSString *token;

// Returns any user agent previously given to +setUserAgent:.
+ (NSString *)userAgent;

// Returns any OAuth client ID previously given to +setClientID:clientSecret:.
+ (NSString *)clientID;

// Returns any OAuth client secret previously given to
// +setClientID:clientSecret:.
+ (NSString *)clientSecret;

// A subject to send callback URLs to after they're received by the app.
+ (RACSubject *)callbackURLs;

// Creates a request.
//
// method - The HTTP method to use in the request (e.g., "GET" or "POST").
// path   - The path to request, relative to the base API endpoint. This path
//          should _not_ begin with a forward slash.
// etag   - An ETag to compare the server data against, previously retrieved
//          from an instance of OCTResponse.
//
// Returns a request which can be modified further before being enqueued.
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters notMatchingEtag:(NSString *)etag;

+ (NSArray *)scopesArrayFromScopes:(OCTClientAuthorizationScopes)scopes;

+ (NSError *)tokenUnsupportedError;
+ (NSError *)unsupportedVersionError;
+ (OCTServer *)HTTPSEnterpriseServerWithServer:(OCTServer *)server;

@end

@implementation OCTClient (GIFingerprint)

// Added since OctoKit on CocoaPods is outdated. :(
+ (RACSignal *)_gi_signInAsUser:(OCTUser *)user password:(NSString *)password oneTimePassword:(NSString *)oneTimePassword scopes:(OCTClientAuthorizationScopes)scopes note:(NSString *)note noteURL:(NSURL *)noteURL fingerprint:(NSString *)fingerprint {
    NSParameterAssert(user != nil);
    NSParameterAssert(password != nil);
    
    NSString *clientID = [OCTClient clientID];
    NSString *clientSecret = [OCTClient clientSecret];
    NSAssert(clientID != nil && clientSecret != nil, @"+setClientID:clientSecret: must be invoked before calling %@", NSStringFromSelector(_cmd));
    
    RACSignal * (^authorizationSignalWithUser)(OCTUser *user) = ^(OCTUser *user) {
        return [RACSignal defer:^{
            OCTClient *client = [self unauthenticatedClientWithUser:user];
            [client setAuthorizationHeaderWithUsername:user.rawLogin password:password];
            
            NSString *path = [NSString stringWithFormat:@"authorizations/clients/%@", clientID];
            NSMutableDictionary *params = [@{
                                             @"scopes": [self scopesArrayFromScopes:scopes],
                                             @"client_secret": clientSecret,
                                             } mutableCopy];
            
            if (note != nil) params[@"note"] = note;
            if (noteURL != nil) params[@"note_url"] = noteURL.absoluteString;
            if (fingerprint != nil) params[@"fingerprint"] = fingerprint;
            
            NSMutableURLRequest *request = [client requestWithMethod:@"PUT" path:path parameters:params];
            request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            if (oneTimePassword != nil) [request setValue:oneTimePassword forHTTPHeaderField:_gi_OCTClientOneTimePasswordHeaderField];
            
            NSString *previewContentType = @"application/vnd.github.v3+json";
            [request setValue:previewContentType forHTTPHeaderField:@"Accept"];
            
            RACSignal *tokenSignal = [client enqueueRequest:request resultClass:OCTAuthorization.class];
            return [RACSignal combineLatest:@[
                                              [RACSignal return:client],
                                              tokenSignal
                                              ]];
        }];
    };
    
    return [[[[[authorizationSignalWithUser(user)
                flattenMap:^(RACTuple *clientAndResponse) {
                    RACTupleUnpack(OCTClient *client, OCTResponse *response) = clientAndResponse;
                    OCTAuthorization *authorization = response.parsedResult;
                    
                    // To increase security, tokens are no longer returned when the authorization
                    // already exists. If that happens, we need to delete the existing
                    // authorization for this app and create a new one, so we end up with a token
                    // of our own.
                    //
                    // The `fingerprint` field provided will be used to ensure uniqueness and
                    // avoid deleting unrelated tokens.
                    if (authorization.token.length == 0/* && response.statusCode == 200*/) {
                        NSString *path = [NSString stringWithFormat:@"authorizations/%@", authorization.objectID];
                        
                        NSMutableURLRequest *request = [client requestWithMethod:@"DELETE" path:path parameters:nil];
                        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                        if (oneTimePassword != nil) [request setValue:oneTimePassword forHTTPHeaderField:_gi_OCTClientOneTimePasswordHeaderField];
                        
                        return [[client
                                 enqueueRequest:request resultClass:nil]
                                then:^{
                                    // Try logging in again.
                                    return authorizationSignalWithUser(user);
                                }];
                    } else {
                        return [RACSignal return:clientAndResponse];
                    }
                }]
               catch:^(NSError *error) {
                   if (error.code == OCTClientErrorUnsupportedServerScheme) {
                       OCTServer *secureServer = [self HTTPSEnterpriseServerWithServer:user.server];
                       OCTUser *secureUser = [OCTUser userWithRawLogin:user.rawLogin server:secureServer];
                       return authorizationSignalWithUser(secureUser);
                   }
                   
                   NSNumber *statusCode = error.userInfo[OCTClientErrorHTTPStatusCodeKey];
                   if (statusCode.integerValue == 404) {
                       if (error.userInfo[OCTClientErrorOAuthScopesStringKey] != nil) {
                           error = self.class.tokenUnsupportedError;
                       } else {
                           error = self.class.unsupportedVersionError;
                       }
                   }
                   
                   return [RACSignal error:error];
               }]
              reduceEach:^(OCTClient *client, OCTResponse *response) {
                  OCTAuthorization *authorization = response.parsedResult;
                  
                  client.token = authorization.token;
                  return client;
              }]
             replayLazily]
            setNameWithFormat:@"+signInAsUser: %@ password:oneTimePassword:scopes:", user];
}

@end
