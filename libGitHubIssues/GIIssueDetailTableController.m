//
//  GIIssueDetailTableController.m
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIIssueDetailTableController.h"
#import "GIIssuesTableViewCell.h"
#import "GIIssuesCommentTableCell.h"
#import "GIResources.h"
#import "OCTClient_OCTClient_Issues.h"
#import "OCTIssueComment+New.h"
#import "OCTIssue+New.h"

#define REUSE_TOP @"com.matchstic.issues"
#define REUSE_COMMENTS @"com.matchstic.comments"
#define REUSE_CLOSED @"com.matchstic.closed"

@interface GIIssueDetailTableController ()

@end

static GIIssuesTableViewCell *heightCheckerCell2;
static GIIssuesCommentTableCell *heightCheckerCell3;

@implementation GIIssueDetailTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add the right item for profile.
    UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(didTapComposeButton:)];
    self.navigationItem.rightBarButtonItem = composeItem;
    
    [self.tableView registerClass:[GIIssuesTableViewCell class] forCellReuseIdentifier:REUSE_TOP];
    [self.tableView registerClass:[GIIssuesCommentTableCell class] forCellReuseIdentifier:REUSE_COMMENTS];
    self.tableView.allowsSelection = NO;
    
    [self loadComments];
}

-(void)loadComments {
    [self.navigationItem setTitle:@"Loading..."];
    [self setTitle:@"Loading..."];
    
    // Now, we download the comments!
    RACSignal *sig = [(OCTClient*)[GIResources _getCurrentClient] fetchIssueCommentsForIssue:self.issue since:nil];
    
    [[sig collect] subscribeNext:^(NSArray *issues) {
        
        NSMutableArray *newData = [NSMutableArray array];
        
        // Array of OCTResponse.
        for (OCTResponse *response in issues) {
            OCTIssueCommentNew *parsed = response.parsedResult;
            
            // If needed, add the "issue closed" tab in.
            
            [newData addObject:parsed];
        }
        
        _dataSource = newData;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = [NSString stringWithFormat:@"#%@", [(OCTIssueNew*)self.issue number]];
            
            [self.navigationItem setTitle:title];
            [self setTitle:title];
            
            [self.tableView reloadData];
            NSLog(@"Should be reloaded now...");
        });
        
    } error:^(NSError *error) {
        // Invoked when an error occurs. You won't receive any results if this
        // happens.
        [self _presentError:error];
        
        [self.navigationItem setTitle:@"Error"];
        [self setTitle:@"Error"];
    }];
}

-(void)_presentError:(NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error.localizedFailureReason] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithIssue:(id)issue {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.issue = issue;
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return _dataSource.count;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GIIssuesTableViewCell *cell = (GIIssuesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:REUSE_TOP forIndexPath:indexPath];
        if (!cell) {
            cell = [[GIIssuesTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:REUSE_TOP];
        }
        
        // Configure the cell...
        [cell setupWithIssue:self.issue withExtras:YES];
        cell.accessoryType = UITableViewCellAccessoryNone;
    
        return cell;
    } else {
        GIIssuesCommentTableCell *cell = (GIIssuesCommentTableCell*)[tableView dequeueReusableCellWithIdentifier:REUSE_COMMENTS forIndexPath:indexPath];
        if (!cell) {
            cell = [[GIIssuesCommentTableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:REUSE_COMMENTS];
        }
        
        // Configure the cell...
        OCTIssueCommentNew *comment = _dataSource[indexPath.row];
        [cell setupWithComment:comment];
        
        return cell;

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (!heightCheckerCell2) {
            heightCheckerCell2 = [[GIIssuesTableViewCell alloc] initWithFrame:CGRectZero];
        }
    
        // Set width correctly to the cell.
        [heightCheckerCell2 setupWithIssue:self.issue withExtras:YES];
        heightCheckerCell2.accessoryType = UITableViewCellAccessoryNone;
        heightCheckerCell2.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0);
        [heightCheckerCell2 layoutSubviews];
    
        return heightCheckerCell2._viewHeight;
    } else {
        if (!heightCheckerCell3) {
            heightCheckerCell3 = [[GIIssuesCommentTableCell alloc] initWithFrame:CGRectZero];
        }
        
        OCTIssueCommentNew *comment = _dataSource[indexPath.row];
        
        // Set width correctly to the cell.
        [heightCheckerCell3 setupWithComment:comment];
        heightCheckerCell3.accessoryType = UITableViewCellAccessoryNone;
        heightCheckerCell3.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0);
        [heightCheckerCell3 layoutSubviews];
        
        return heightCheckerCell3._viewHeight;
    }
}

-(void)didTapComposeButton:(id)sender {
    OCTClient *client = [GIResources _getCurrentClient];
    
    if (!client.token || [client.token isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign In Required" message:@"You need to be signed in to create a new comment.\n\nSign in now?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Sign In" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  // Go to login UI.
                                                                  GILoginController *login = [[GILoginController alloc] init];
                                                                  login.delegate = self;
                                                                  
                                                                  [self.navigationController pushViewController:login animated:YES];
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * action) {
                                                                 
                                                             }];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        GICommentComposeController *compose = [[GICommentComposeController alloc] init];
        compose.delegate = self;
        compose.issue = self.issue;
        [self.navigationController pushViewController:compose animated:YES];
    }
}

-(void)didFinishAuthenticationWithClient:(id)client {
    [self.navigationController popToViewController:self animated:YES];
    
    GICommentComposeController *compose = [[GICommentComposeController alloc] init];
    compose.delegate = self;
    compose.issue = self.issue;
    [self.navigationController pushViewController:compose animated:YES];
}

-(void)didSendComment {
    // Reload UI and pop back here.
    [self.navigationController popToViewController:self animated:YES];
    
    [self loadComments];
}

@end
