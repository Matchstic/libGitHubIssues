//
//  OCTClient+Issues.m
//  OctoKit
//
//  Created by leichunfeng on 15/3/7.
//  Copyright (c) 2015年 GitHub. All rights reserved.
//

#import "OCTClient_OCTClient_Issues.h"
#import "OCTIssue+New.h"
#import "OCTIssueComment+New.h"
#import "NSDateFormatter+OCTFormattingAdditions.h"

@implementation OCTClient (Issues)

- (RACSignal *)createIssueCommentWithBody:(NSString *)body forIssue:(OCTIssueNew*)issue inRepository:(OCTRepository *)repository {
    NSParameterAssert(body != nil);
    NSParameterAssert(repository != nil);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"body"] = body;
    
    NSString *path = [NSString stringWithFormat:@"repos/%@/%@/issues/%@/comments", repository.ownerLogin, repository.name, issue.number];
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters notMatchingEtag:nil];
    
    return [[self enqueueRequest:request resultClass:OCTIssueNew.class] oct_parsedResults];
}

- (RACSignal *)createIssueWithTitle:(NSString *)title body:(NSString *)body assignee:(NSString *)assignee milestone:(NSNumber *)milestone labels:(NSArray *)labels inRepository:(OCTRepository *)repository {
    NSParameterAssert(title != nil);
    NSParameterAssert(repository != nil);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"title"] = title;
    
    if (milestone != nil) parameters[@"milestone"] = milestone;
    if (body != nil) parameters[@"body"] = body;
    if (assignee != nil) parameters[@"assignee"] = assignee;
    if (labels != nil) parameters[@"labels"] = labels;
    
    NSString *path = [NSString stringWithFormat:@"repos/%@/%@/issues", repository.ownerLogin, repository.name];
    NSURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:parameters notMatchingEtag:nil];
    
    return [[self enqueueRequest:request resultClass:OCTIssueNew.class] oct_parsedResults];
}

- (RACSignal *)fetchIssuesForRepository:(OCTRepository *)repository state:(OCTClientIssueState)state notMatchingEtag:(NSString *)etag since:(NSDate *)since {
    NSParameterAssert(repository != nil);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSDictionary *stateToStateString = @{
                                         @(OCTClientIssueStateOpen): @"open",
                                         @(OCTClientIssueStateClosed): @"closed",
                                         @(OCTClientIssueStateAll): @"all",
                                         };
    NSString *stateString = stateToStateString[@(state)];
    NSAssert(stateString != nil, @"Unknown state: %@", @(state));
    
    parameters[@"state"] = stateString;
    if (since != nil) parameters[@"since"] = [NSDateFormatter oct_stringFromDate:since];
    
    NSString *path = [NSString stringWithFormat:@"repos/%@/%@/issues", repository.ownerLogin, repository.name];
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:etag];
    return [self enqueueRequest:request resultClass:OCTIssueNew.class];
}

- (RACSignal *)fetchIssueCommentsForIssue:(OCTIssueNew *)issue since:(NSDate*)since {
    NSParameterAssert(issue != nil);
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (since != nil) parameters[@"since"] = [NSDateFormatter oct_stringFromDate:since];
    
    NSString *path = [[issue.commentsURL absoluteString] copy];
    path = [path stringByReplacingOccurrencesOfString:@"https://api.github.com/" withString:@""];
    
    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters notMatchingEtag:nil];
    return [self enqueueRequest:request resultClass:OCTIssueCommentNew.class];
}

@end
