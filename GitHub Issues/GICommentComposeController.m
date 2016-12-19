//
//  GICommentComposeController.m
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GICommentComposeController.h"
#import <RFKeyboardToolbar/RFKeyboardToolbar.h>
#import <UITextView+Placeholder.h>
#import <OctoKit.h>
#import "GIResources.h"
#import "OCTClient_OCTClient_Issues.h"

@interface GICommentComposeController ()

@end

@implementation GICommentComposeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:@"Compose"];
    [self setTitle:@"Compose"];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCommentButton:)];
    item.enabled = NO;
    self.navigationItem.rightBarButtonItem = item;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textView.textColor = [UIColor darkTextColor];
    self.textView.textAlignment = NSTextAlignmentNatural;
    self.textView.restorationIdentifier = @"com.matchstic.commentcompose";
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.placeholder = @"Comment...";
    self.textView.delegate = self;
    
    [self.view addSubview:self.textView];
    
    // Create a new RFToolbarButton
    RFToolbarButton *hashButton = [RFToolbarButton buttonWithTitle:@"#"];
    
    // Add a button target to the exampleButton
    [hashButton addEventHandler:^{
        // Do anything in this block here
        [_textView insertText:@"#"];
    } forControlEvents:UIControlEventTouchUpInside];
    
    RFToolbarButton *starButton = [RFToolbarButton buttonWithTitle:@"*"];
    
    // Add a button target to the exampleButton
    [starButton addEventHandler:^{
        // Do anything in this block here
        [_textView insertText:@"*"];
    } forControlEvents:UIControlEventTouchUpInside];
    
    RFToolbarButton *linkButton = [RFToolbarButton buttonWithTitle:@"Link"];
    
    // Add a button target to the exampleButton
    [linkButton addEventHandler:^{
        // Do anything in this block here
        [_textView insertText:@"[Link Title](http://...)"];
    } forControlEvents:UIControlEventTouchUpInside];
    
    RFToolbarButton *imageButton = [RFToolbarButton buttonWithTitle:@"Image"];
    
    // Add a button target to the exampleButton
    [imageButton addEventHandler:^{
        // Do anything in this block here
        [_textView insertText:@"![Image Title](http://...)"];
    } forControlEvents:UIControlEventTouchUpInside];

    
    RFKeyboardToolbar *toolbar = [RFKeyboardToolbar toolbarWithButtons:@[ hashButton, starButton, linkButton, imageButton ]];
    
    self.textView.inputAccessoryView = toolbar;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(void)didTapCommentButton:(id)sender {
    // Send off to GitHub, and tell delegate to reload+pop.
    
    // TODO: Add animation to show in-progress of this task.
    
    OCTClient *client = (OCTClient*)[GIResources _getCurrentClient];

    RACSignal *request = (RACSignal*)[GIResources _getCurrentRepository];
    [[request collect] subscribeNext:^(NSArray *repositories) {
        OCTRepository *repo = [repositories firstObject];
    
        RACSignal *sigTwo = [client createIssueCommentWithBody:self.textView.text forIssue:self.issue inRepository:repo];
        [sigTwo subscribeNext:^(id thing){
        
        } error:^(NSError *error) {
            [self _presentError:error];
        
            [self.navigationItem setTitle:@"Error"];
            [self setTitle:@"Error"];
        } completed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didSendComment];
            });
        }];
    
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

- (void)textViewDidChange:(UITextView *)textView {
    // If both the password and username fields have content, enable login button.
    if (self.textView.text &&
        ![self.textView.text isEqualToString:@""]) {
        // Enable right button!
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

@end
