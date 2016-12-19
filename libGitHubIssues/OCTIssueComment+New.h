//
//  OCTIssueComment.h
//  OctoKit
//
//  Created by Justin Spahr-Summers on 2012-10-02.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OctoKit/OctoKit.h>

// A single comment on an issue.
@interface OCTIssueCommentNew : OCTObject

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSDictionary *user;

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSDate *createdAt;

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSDate *updatedAt;

// The webpage URL for this comment.
@property (nonatomic, copy, readonly) NSString *body;


@end
