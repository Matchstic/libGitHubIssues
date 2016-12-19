//
//  OCTIssueComment.m
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "OCTIssueComment+New.h"
#import "NSValueTransformer+OCTPredefinedTransformerAdditions.h"

@implementation OCTIssueCommentNew

#pragma mark MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
                                                                                          @"HTMLURL": @"html_url",
                                                                                          @"user": @"user",
                                                                                          @"createdAt": @"created_at",
                                                                                          @"updatedAt": @"updated_at",
                                                                                          @"body": @"body",
                                                                                          }];
}

+ (NSValueTransformer *)HTMLURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

+ (NSValueTransformer *)updatedAtJSONTransformer {
    return [NSValueTransformer valueTransformerForName:OCTDateValueTransformerName];
}

@end
