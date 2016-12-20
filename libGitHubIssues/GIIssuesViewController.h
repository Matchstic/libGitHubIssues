//
//  GIIssuesViewController.h
//  Github Issues
//
//  Created by Matt Clarke on 17/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GILoginController.h"
#import "GIIssueComposeController.h"

@interface GIIssuesViewController : UITableViewController<GILoginControllerDelegate, GIIssueComposeDelegate> {
    NSArray *_dataSource;
    UISegmentedControl *_segmented;
    BOOL _showNewIssueAfterAuthentication;
}

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end
