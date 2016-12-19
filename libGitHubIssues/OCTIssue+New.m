//
//  OCTIssue+New.m
//  Github Issues
//
//  Created by Matt Clarke on 17/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "OCTIssue+New.h"
#import <OctoKit/OCTPullRequest.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>
#import "NSDateFormatter+OCTFormattingAdditions.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@interface OCTIssueNew ()

// The webpage URL for any attached pull request.
@property (nonatomic, copy, readonly) NSURL *pullRequestHTMLURL;

@end

@implementation OCTIssueNew

#pragma mark Properties

- (OCTPullRequest *)pullRequest {
    if (self.pullRequestHTMLURL == nil) return nil;
    
    // We don't have a "real" pull request model within the issue data, but we
    // have enough information to construct one.
    return [OCTPullRequest modelWithDictionary:@{
                                                 @keypath(OCTPullRequest.new, objectID): self.objectID,
                                                  @keypath(OCTPullRequest.new, HTMLURL): self.pullRequestHTMLURL,
                                                  @keypath(OCTPullRequest.new, title): self.title,
                                                  } error:NULL];
}

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:
  @{
    @"URL": @"url",
    @"HTMLURL": @"html_url",
    @"pullRequestHTMLURL": @"pull_request.html_url",
    @"commentsURL": @"comments_url",
    @"user": @"user",
    @"labels": @"labels",
    @"comments": @"comments",
    @"createdAt": @"created_at",
    @"updatedAt": @"updated_at",
    @"closedAt": @"closed_at",
    @"body": @"body",
    @"closedBy": @"closed_by",
    }];
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)commentsURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)pullRequestHTMLURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)closedAtJSONTransformer {
    return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)numberJSONTransformer {
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(NSNumber *num) {
                return num.stringValue;
            } reverseBlock:^ id (NSString *str) {
                if (str == nil) return nil;
                
                return [NSDecimalNumber decimalNumberWithString:str];
            }];
}

+ (NSValueTransformer *)commentsJSONTransformer {
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(NSNumber *num) {
                return num.stringValue;
            } reverseBlock:^ id (NSString *str) {
                if (str == nil) return nil;
                
                return [NSDecimalNumber decimalNumberWithString:str];
            }];
}

+ (NSValueTransformer *)stateJSONTransformer {
    NSDictionary *statesByName = @{
                                   @"open": @(OCTIssueStateOpen),
                                   @"closed": @(OCTIssueStateClosed),
                                   };
    
    return [MTLValueTransformer
            reversibleTransformerWithForwardBlock:^(NSString *stateName) {
                return statesByName[stateName];
            }
            reverseBlock:^(NSNumber *state) {
                return [statesByName allKeysForObject:state].lastObject;
            }];
}

@end
