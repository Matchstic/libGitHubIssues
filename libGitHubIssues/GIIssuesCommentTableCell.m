//
//  GIIssuesCommentTableCell.m
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIIssuesCommentTableCell.h"
#import "OCTIssueComment+New.h"
#import "GIResources.h"
#import <AFNetworking/AFNetworking.h>

@implementation GIIssuesCommentTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)_configureViewsIfNeeded {
    if (!self.bodyLabel) {
        self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bodyLabel.text = @"";
        self.bodyLabel.textColor = [UIColor grayColor];
        self.bodyLabel.font = [UIFont systemFontOfSize:16];
        self.bodyLabel.textAlignment = NSTextAlignmentLeft;
        self.bodyLabel.numberOfLines = 0;
        
        [self.contentView addSubview:self.bodyLabel];
    }
    
    if (!self.avatarView) {
        self.avatarView = [[UIImageView alloc] initWithImage:nil];
        self.avatarView.backgroundColor = [UIColor lightGrayColor];
        
        [self.contentView addSubview:self.avatarView];
    }
    
    if (!self.userLabel) {
        self.userLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.userLabel.text = @"USER";
        self.userLabel.textColor = [UIColor darkTextColor];
        self.userLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        self.userLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.contentView addSubview:self.userLabel];
    }
    
    if (!self.commentDateLabel) {
        self.commentDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentDateLabel.text = @"0mins ago";
        self.commentDateLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1.0];
        self.commentDateLabel.font = [UIFont systemFontOfSize:12];
        self.commentDateLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.contentView addSubview:self.commentDateLabel];
    }
}

-(void)setupWithComment:(OCTIssueCommentNew*)comment {
    _comment = comment;
    self.accessoryType = UITableViewCellAccessoryNone;
    
    [self _configureViewsIfNeeded];
    
    // Probably shouldn;t be doing this here...
    NSString *actual = comment.body;
    NSRange range = [actual rangeOfString:@"\n> "];
    
    if (range.location != NSNotFound) {
        // We have email data to strip out from here-on-in!
        actual = [actual substringToIndex:range.location-1];
        
        // Walk backwards to last \n and remove. Also, if another \n before that too without text, delete.
        NSUInteger len = [actual length];
        unichar buffer[len+1];
        
        // Iterate over string, and break on first non-newline.
        [actual getCharacters:buffer range:NSMakeRange(0, len)];
        
        int i = (int)len;
        for(; i > 0; i--) {
            char character = buffer[i];
            if (character == '\n') {
                break;
            }
        }
        
        actual = [actual substringToIndex:i-1];
    }
    
    self.bodyLabel.text = actual;
    
    // Avatar and user stuff.
    NSString *avatarURL = [comment.user objectForKey:@"avatar_url"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL]];
    
    GIIssuesCommentTableCell * __weak weakself = self;
    
    [self.avatarView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [weakself setUserImage:image];
    } failure:nil];
    
    self.userLabel.text = [comment.user objectForKey:@"login"];
    
    // Format date label.
    self.commentDateLabel.text = [GIResources formatDate:comment.createdAt];
}

-(void)setUserImage:(UIImage*)img {
    self.avatarView.image = img;
    self.avatarView.frame = CGRectMake(self.avatarView.frame.origin.x, self.avatarView.frame.origin.y, 18, 18);
    self.avatarView.layer.cornerRadius = 9;
    self.avatarView.layer.masksToBounds = YES;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat y = 10;
    CGFloat xOrigin = 10;
    
    CGRect rect = [GIResources boundedRectForFont:self.bodyLabel.font andText:self.bodyLabel.text width:self.contentView.frame.size.width - xOrigin*2];
    
    self.bodyLabel.frame = CGRectMake(xOrigin, y, rect.size.width, rect.size.height);
    
    y += self.bodyLabel.frame.size.height + 10;
    
    self.avatarView.frame = CGRectMake(xOrigin, y, 18, 18);
    self.avatarView.layer.cornerRadius = 9;
    
    [self.userLabel sizeToFit];
    self.userLabel.frame = CGRectMake(xOrigin + self.avatarView.frame.size.width + 5, y, self.userLabel.frame.size.width, self.userLabel.frame.size.height);
    
    y += self.userLabel.frame.size.height + 10;
    
    // Updated label.
    [self.commentDateLabel sizeToFit];
    self.commentDateLabel.frame = CGRectMake(xOrigin, y, self.commentDateLabel.frame.size.width, self.commentDateLabel.frame.size.height);
    
    y += self.commentDateLabel.frame.size.height + 10;
    
    self._viewHeight = y;
}

@end
