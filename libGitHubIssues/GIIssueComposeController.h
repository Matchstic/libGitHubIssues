//
//  GIIssueComposeController.h
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GIIssueComposeDelegate <NSObject>

-(void)didSendIssue;

@end

@interface GIIssueComposeController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) id<GIIssueComposeDelegate> delegate;
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UITextView *textView;

@end
