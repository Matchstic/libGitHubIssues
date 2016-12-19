//
//  GIIssuesCommentTableCell.h
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIIssuesCommentTableCell : UITableViewCell {
    id _comment;
}

@property (nonatomic, readwrite) CGFloat _viewHeight;

@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UILabel *commentDateLabel;

-(void)setupWithComment:(id)comment;

@end
