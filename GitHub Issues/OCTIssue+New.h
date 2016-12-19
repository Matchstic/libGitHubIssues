//
//  OCTIssue+New.h
//  Github Issues
//
//  Created by Matt Clarke on 17/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OctoKit/OctoKit.h>

typedef NS_ENUM(NSInteger, OCTIssueState) {
    OCTIssueStateOpen,
    OCTIssueStateClosed,
};

@class OCTPullRequest;

// An issue on a repository.
@interface OCTIssueNew : OCTObject

// The URL for this issue.
@property (nonatomic, copy, readonly) NSURL *URL;

// The comments URL for this issue.
@property (nonatomic, copy, readonly) NSURL *commentsURL;

// The webpage URL for this issue.
@property (nonatomic, copy, readonly) NSURL *HTMLURL;

// The title of this issue.
@property (nonatomic, copy, readonly) NSString *title;

// The body text of this issue.
@property (nonatomic, copy, readonly) NSString *body;

// The labels for this issue.
// Is an array of dictionaries.
@property (nonatomic, copy, readonly) NSArray *labels;

// The user who submitted this issue.
// Note is in dictionary form.
@property (nonatomic, copy, readonly) NSDictionary *user;

// The comments count.
@property (nonatomic, copy, readonly) NSString *comments;

// The time the issue was created.
@property (nonatomic, copy, readonly) NSDate *createdAt;

// The time the issue was updated.
@property (nonatomic, copy, readonly) NSDate *updatedAt;

// The time the issue was closed at, or nil.
@property (nonatomic, copy, readonly) NSDate *closedAt;

@property (nonatomic, copy, readonly) NSDictionary *closedBy;

// The pull request that is attached to (i.e., the same as) this issue, or nil
// if this issue does not have code attached.
@property (nonatomic, copy, readonly) OCTPullRequest *pullRequest;

// The state of the issue.
@property (nonatomic, assign, readonly) OCTIssueState state;

// The issue number.
@property (nonatomic, copy, readonly) NSString *number;

@end
