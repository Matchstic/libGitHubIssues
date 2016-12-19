//
//  GIIssueDetailTableController.h
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GILoginController.h"
#import "GICommentComposeController.h"

@interface GIIssueDetailTableController : UITableViewController <GILoginControllerDelegate, GICommentComposeDelegate> {
    NSArray *_dataSource;
}

@property (nonatomic, strong) id issue;

-(instancetype)initWithIssue:(id)issue;

@end
