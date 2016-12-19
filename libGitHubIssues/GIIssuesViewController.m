//
//  GIIssuesViewController.m
//  Github Issues
//
//  Created by Matt Clarke on 17/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIIssuesViewController.h"
#import "GIResources.h"
#import "OCTClient_OCTClient_Issues.h"
#import "OCTIssue+New.h"
#import "GIIssuesTableViewCell.h"
#import "GIIssueDetailTableController.h"
#import "GIUserViewController.h"

#define REUSE @"com.matchstic.issues"
#define REUSE_TOP @"com.matchstic.create"

static GIIssuesTableViewCell *heightCheckerCell;

@interface GIIssuesViewController ()

@end

@implementation GIIssuesViewController

-(instancetype)initWithClient:(OCTClient*)client {
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {        
        _dataSource = [NSArray array];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[GIIssuesTableViewCell class] forCellReuseIdentifier:REUSE];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:REUSE_TOP];
    
    [self reloadWithMode:0];
    
    // Add segmented view as title.
    _segmented = [[UISegmentedControl alloc] initWithItems:@[@"Open", @"Closed"]];
    [_segmented addTarget:self action:@selector(_segmentedChanged:) forControlEvents:UIControlEventValueChanged];
    _segmented.selectedSegmentIndex = 0;
    
    self.navigationItem.titleView = _segmented;
    
    // Add the right item for profile.
    UIImage *icon = [GIResources imageWithName:@"libGitHubIssues_Profile"];
    UIBarButtonItem *profileItem = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStylePlain target:self action:@selector(didTapProfileButton:)];
    self.navigationItem.rightBarButtonItem = profileItem;
}

-(void)_segmentedChanged:(UISegmentedControl*)sender {
    [self reloadWithMode:(int)sender.selectedSegmentIndex];
}

-(void)reloadWithMode:(int)mode {
    self.navigationItem.titleView = nil;
    
    [self.navigationItem setTitle:@"Loading..."];
    [self setTitle:@"Loading..."];
    
    // Pull down issues. We ideally should split them up so it's not a huge download.
    RACSignal *request = (RACSignal*)[GIResources _getCurrentRepository];
    [[request collect] subscribeNext:^(NSArray *repositories) {
        OCTRepository *repo = [repositories firstObject];
        RACSignal *sigTwo = [(OCTClient*)[GIResources _getCurrentClient] fetchIssuesForRepository:repo state:mode == 0 ? OCTClientIssueStateOpen : OCTClientIssueStateClosed notMatchingEtag:nil since:nil];
        
        [[sigTwo collect] subscribeNext:^(NSArray *issues) {
            
            NSMutableArray *newData = [NSMutableArray array];
            
            // Array of OCTResponse.
            for (OCTResponse *response in issues) {
                OCTIssueNew *parsed = response.parsedResult;
                
                [newData addObject:parsed];
            }
            
            _dataSource = newData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationItem setTitle:@"Back"];
                [self setTitle:@"Back"];
                
                self.navigationItem.titleView = _segmented;
                
                [self.tableView reloadData];
            });
            
        } error:^(NSError *error) {
            // Invoked when an error occurs. You won't receive any results if this
            // happens.
            [self _presentError:error];
            
            [self.navigationItem setTitle:@"Error"];
            [self setTitle:@"Error"];
        }];
    } error:^(NSError *error) {
        // Invoked when an error occurs. You won't receive any results if this
        // happens.
        [self _presentError:error];
        
        [self.navigationItem setTitle:@"Error"];
        [self setTitle:@"Error"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        GIIssuesTableViewCell *cell = (GIIssuesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:REUSE forIndexPath:indexPath];
        if (!cell) {
            cell = [[GIIssuesTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:REUSE];
        }
    
        // Configure the cell...
        OCTIssueNew *issue = [_dataSource objectAtIndex:indexPath.row];
        [cell setupWithIssue:issue withExtras:NO];

        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_TOP forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:REUSE_TOP];
        }
        
        cell.textLabel.text = @"Create New Issue...";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        OCTIssueNew *issue = [_dataSource objectAtIndex:indexPath.row];
    
        if (!heightCheckerCell) {
            heightCheckerCell = [[GIIssuesTableViewCell alloc] initWithFrame:CGRectZero];
        }
    
        // Set width correctly to the cell.
        [heightCheckerCell setupWithIssue:issue withExtras:NO];
        heightCheckerCell.frame = CGRectMake(0, 0, self.tableView.frame.size.width-20, 0);
        [heightCheckerCell layoutSubviews];
    
        return heightCheckerCell._viewHeight;
    } else {
        return 40;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        OCTIssueNew *issue = [_dataSource objectAtIndex:indexPath.row];
    
        // Move to this issue's detail view.
        GIIssueDetailTableController *detail = [[GIIssueDetailTableController alloc] initWithIssue:issue];
        [self.navigationController pushViewController:detail animated:YES];
    } else {
        // Display create new issue UI!
        OCTClient *client = [GIResources _getCurrentClient];
        
        if (!client.token || [client.token isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign In Required" message:@"You need to be signed in to create a new issue.\n\nSign in now?" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Sign In" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                  
                                                                      // Go to login UI.
                                                                      _showNewIssueAfterAuthentication = YES;
                                                                      [self openLoginController];
                                                                      
                                                                  }];
            
            [alert addAction:defaultAction];
            
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * action) {
                                                                      
                                                                  }];
            [alert addAction:cancelAction];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            // TODO: Push into compose UI
            GIIssueComposeController *compose = [[GIIssueComposeController alloc] init];
            compose.delegate = self;
            [self.navigationController pushViewController:compose animated:YES];
        }
    }
}

-(void)openLoginController {
    GILoginController *login = [[GILoginController alloc] init];
    login.delegate = self;
    
    [self.navigationController pushViewController:login animated:YES];
}

-(void)didFinishAuthenticationWithClient:(id)client {
    [self.navigationController popToViewController:self animated:YES];
    
    // Now push into compose UI.
    if (_showNewIssueAfterAuthentication) {
        
    } else {
        GIUserViewController *user = [[GIUserViewController alloc] init];
        [self.navigationController pushViewController:user animated:YES];
    }
}

-(void)didSendIssue {
    // Reload UI and pop back here.
    [self.navigationController popToViewController:self animated:YES];
    
    [self reloadWithMode:(int)_segmented.selectedSegmentIndex];
}

-(void)didTapProfileButton:(id)sender {
    OCTClient *client = [GIResources _getCurrentClient];
    
    if (!client.token || [client.token isEqualToString:@""]) {
        _showNewIssueAfterAuthentication = NO;
        [self openLoginController];
    } else {
        GIUserViewController *user = [[GIUserViewController alloc] init];
        [self.navigationController pushViewController:user animated:YES];
    }
}

@end
