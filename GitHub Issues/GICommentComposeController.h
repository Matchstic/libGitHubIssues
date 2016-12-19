//
//  GICommentComposeController.h
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GICommentComposeDelegate <NSObject>

-(void)didSendComment;

@end

@interface GICommentComposeController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) id<GICommentComposeDelegate> delegate;
@property (nonatomic, strong) id issue;

@end
