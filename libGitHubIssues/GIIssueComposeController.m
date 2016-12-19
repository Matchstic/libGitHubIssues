//
//  GIIssueComposeController.m
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIIssueComposeController.h"
#import "RFKeyboardToolbar/RFKeyboardToolbar.h"
#import "UITextView+Placeholder/UITextView+Placeholder.h"
#import "OctoKit/OctoKit.h"
#import "GIResources.h"
#import "OCTClient_OCTClient_Issues.h"

@interface GIIssueComposeController ()

@end

@implementation GIIssueComposeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setTitle:@"Compose"];
    [self setTitle:@"Compose"];
    
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStylePlain target:self action:@selector(didTapSendButton:)];
    item.enabled = NO;
    self.navigationItem.rightBarButtonItem = item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *leftBlock = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
    leftBlock.backgroundColor = [UIColor clearColor];
    
    self.titleField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.titleField.textAlignment = NSTextAlignmentNatural;
    self.titleField.textColor = [UIColor grayColor];
    self.titleField.placeholder = @"Title...";
    self.titleField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.titleField.autocorrectionType = UITextAutocorrectionTypeYes;
    self.titleField.returnKeyType = UIReturnKeyDone;
    self.titleField.delegate = self;
    [self.titleField addTarget:self action:@selector(textFieldContentDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.titleField.leftView = leftBlock;
    self.titleField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:self.titleField];
    
    self.separator = [[UIView alloc] initWithFrame:CGRectZero];
    self.separator.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:self.separator];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textView.textColor = [UIColor darkTextColor];
    self.textView.textAlignment = NSTextAlignmentNatural;
    self.textView.restorationIdentifier = @"com.matchstic.issuecompose";
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.placeholder = @"Details...";
    
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
        [_textView insertText:@"![Alt text](http://...)"];
    } forControlEvents:UIControlEventTouchUpInside];
    
    RFKeyboardToolbar *toolbar = [RFKeyboardToolbar toolbarWithButtons:@[ hashButton, starButton, linkButton, imageButton ]];
    
    self.textView.inputAccessoryView = toolbar;
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.titleField.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    self.separator.frame = CGRectMake(10, 39, self.view.frame.size.width-20, 1);
    self.textView.frame = CGRectMake(5, 40, self.view.frame.size.width-10, self.view.frame.size.height-40);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.titleField resignFirstResponder];
    
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (![self.textView hasText]) {
        self.textView.text = @"";
        self.textView.attributedText = nil;
    }
}

-(void)textFieldContentDidChange:(UITextField*)sender {
    // If both the password and username fields have content, enable login button.
    if (self.titleField.text &&
        ![self.titleField.text isEqualToString:@""]) {
        // Enable right button!
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

-(void)didTapSendButton:(id)sender {
    [self.textView resignFirstResponder];
    [self.titleField resignFirstResponder];
    
    // TODO: Add animation to show in-progress of this task.
    
    // Send to GitHub and pop back.
    OCTClient *client = (OCTClient*)[GIResources _getCurrentClient];
    
    RACSignal *request = (RACSignal*)[GIResources _getCurrentRepository];
    [[request collect] subscribeNext:^(NSArray *repositories) {
        OCTRepository *repo = [repositories firstObject];
        
        RACSignal *sigTwo = [client createIssueWithTitle:self.titleField.text body:self.textView.text assignee:nil milestone:nil labels:nil inRepository:repo];
        [sigTwo subscribeNext:^(id thing){
        
        } error:^(NSError *error) {
            [self _presentError:error];
            
            [self.navigationItem setTitle:@"Error"];
            [self setTitle:@"Error"];
        } completed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didSendIssue];
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

@end
