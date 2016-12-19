//
//  GIIssuesTableViewCell.m
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIIssuesTableViewCell.h"
#import "OCTIssue+New.h"
#import "GIIssuesLabelView.h"
#import "GIResources.h"
#import <AFNetworking/AFNetworking.h>

@implementation GIIssuesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)_configureViewsIfNeeded {
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.text = @"TITLE";
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.numberOfLines = 0;
        
        [self.contentView addSubview:self.titleLabel];
    }
    
    if (!self.bodyLabel) {
        self.bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.bodyLabel.text = @"";
        self.bodyLabel.textColor = [UIColor grayColor];
        self.bodyLabel.font = [UIFont systemFontOfSize:16];
        self.bodyLabel.textAlignment = NSTextAlignmentLeft;
        self.bodyLabel.numberOfLines = 0;
        
        [self.contentView addSubview:self.bodyLabel];
    }
    
    if (!self.commentsLabel) {
        self.commentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.commentsLabel.text = @"0 comments";
        self.commentsLabel.textColor = [UIColor grayColor];
        self.commentsLabel.font = [UIFont systemFontOfSize:14];
        self.commentsLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.contentView addSubview:self.commentsLabel];
    }
    
    if (!self.userImageView) {
        self.userImageView = [[UIImageView alloc] initWithImage:nil];
        self.userImageView.backgroundColor = [UIColor lightGrayColor];
        
        [self.contentView addSubview:self.userImageView];
    }
    
    if (!self.userLabel) {
        self.userLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.userLabel.text = @"USER";
        self.userLabel.textColor = [UIColor darkTextColor];
        self.userLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
        self.userLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.contentView addSubview:self.userLabel];
    }
    
    if (!self.labelRegionView) {
        self.labelRegionView = [[UIView alloc] initWithFrame:CGRectZero];
        self.labelRegionView.backgroundColor = [UIColor clearColor];
        self.labelRegionView.userInteractionEnabled = NO;
        
        [self.contentView addSubview:self.labelRegionView];
    }
    
    if (!self.updatedAtLabel) {
        self.updatedAtLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.updatedAtLabel.text = @"0mins ago";
        self.updatedAtLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1.0];
        self.updatedAtLabel.font = [UIFont systemFontOfSize:12];
        self.updatedAtLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.contentView addSubview:self.updatedAtLabel];
    }
    
    if (!self.closeOpenIndicator) {
        self.closeOpenIndicator = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self.contentView addSubview:self.closeOpenIndicator];
    }
    
    self.textLabel.numberOfLines = 0;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    [self.userImageView cancelImageRequestOperation];
}

-(void)setupWithIssue:(OCTIssueNew*)issue withExtras:(BOOL)extras {
    self.issue = issue;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    _usingExtras = extras;
    
    [self _configureViewsIfNeeded];
    
    NSString *title = [NSString stringWithFormat:@"#%@ %@", issue.number, issue.title];
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont systemFontOfSize:16], NSFontAttributeName,
                                          [UIColor darkTextColor], NSForegroundColorAttributeName,
                                          nil];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:title attributes:attributesDictionary];
    [attr addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:14.0]
                  range:NSMakeRange(0, 1 + issue.number.length)];
    [attr addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithWhite:0.5 alpha:1.0]
                 range:NSMakeRange(0, 1 + issue.number.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attr length])];
    
    self.titleLabel.attributedText = attr;
    
    if (_usingExtras) {
        self.bodyLabel.text = issue.body;
    }
    
    int count = [issue.comments intValue];
    self.commentsLabel.text = [NSString stringWithFormat:count != 1 ? @"%d comments" : @"%d comment", count];
    
    self.userLabel.text = [issue.user objectForKey:@"login"];
    
    // Labels.
    for (UIView *view in self.labelRegionView.subviews) {
        [view removeFromSuperview];
    }
    
    for (NSDictionary *labelDict in issue.labels) {
        // Add each label to the region view.
        GIIssuesLabelView *view = [[GIIssuesLabelView alloc] initWithFrame:CGRectZero];
        [view setupWithDictionary:labelDict];
        
        [self.labelRegionView addSubview:view];
    }
    
    self.closeOpenIndicator.backgroundColor = issue.state == OCTIssueStateOpen ?
                                            [UIColor colorWithRed:0.35 green:0.80 blue:0.22 alpha:1.0] :
                                            [UIColor colorWithRed:0.80 green:0.22 blue:0.22 alpha:1.0];
    
    // Format the updated label.
    self.updatedAtLabel.text = [GIResources formatDate:issue.createdAt];
    
    NSString *avatarURL = [issue.user objectForKey:@"avatar_url"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:avatarURL]];
    
    GIIssuesTableViewCell * __weak weakself = self;
    
    [self.userImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [weakself setUserImage:image];
    } failure:nil];
}

-(void)setUserImage:(UIImage*)img {
    self.userImageView.image = img;
    self.userImageView.frame = CGRectMake(self.userImageView.frame.origin.x, self.userImageView.frame.origin.y, 18, 18);
    self.userImageView.layer.cornerRadius = 9;
    self.userImageView.layer.masksToBounds = YES;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.closeOpenIndicator.frame = CGRectMake(1, 5, 1.5, self.contentView.frame.size.height-10);
    
    CGFloat y = 10;
    CGFloat xOrigin = 10;
    
    // Alright, let's lay this damn thing out!
    CGRect rect = [GIResources boundedRectForFont:self.titleLabel.font andText:self.titleLabel.attributedText width:self.contentView.frame.size.width - xOrigin];
    self.titleLabel.frame = CGRectMake(xOrigin, y, rect.size.width, rect.size.height);
    
    y += self.titleLabel.frame.size.height + 10;
    
    if (_usingExtras) {
        // When using extras, the accessory indicator will be "none".
        rect = [GIResources boundedRectForFont:self.bodyLabel.font andText:self.bodyLabel.text width:self.contentView.frame.size.width - xOrigin*2];
        
        self.bodyLabel.frame = CGRectMake(xOrigin, y, rect.size.width, rect.size.height);
        
        y += self.bodyLabel.frame.size.height + 10;
    }
    
    // We will assume a label will be 20px high, and its inner text + 20 margin for width.
    
    int i = 0;
    CGFloat widthLeftInRow = self.contentView.frame.size.width - xOrigin;
    CGFloat xOnRow = 0;
    for (GIIssuesLabelView *view in self.labelRegionView.subviews) {
        rect = [GIResources boundedRectForFont:view.label.font andText:view.label.text width:self.contentView.frame.size.width - xOrigin];
        
        if (rect.size.width + 25 < widthLeftInRow) {
            view.frame = CGRectMake(xOnRow, i*5 + i*20, rect.size.width + 20, 20);
            xOnRow += view.frame.size.width + 5;
            widthLeftInRow -= xOnRow;
        } else {
            i++;
            widthLeftInRow = self.contentView.frame.size.width - xOrigin;
            xOnRow = 0;
            
            view.frame = CGRectMake(0, i*5 + i*20, rect.size.width + 20, 20);
            xOnRow += view.frame.size.width + 5;
            widthLeftInRow -= xOnRow;
        }
    }
    
    UIView *bottomView = [self.labelRegionView.subviews lastObject];
    self.labelRegionView.frame = CGRectMake(xOrigin, y, self.contentView.frame.size.width - xOrigin, bottomView.frame.origin.y + bottomView.frame.size.height);
    
    y += self.labelRegionView.frame.size.height + 10;
    
    self.userImageView.frame = CGRectMake(xOrigin, y, 18, 18);
    self.userImageView.layer.cornerRadius = 9;
    
    [self.userLabel sizeToFit];
    self.userLabel.frame = CGRectMake(xOrigin + self.userImageView.frame.size.width + 5, y, self.userLabel.frame.size.width, self.userLabel.frame.size.height);
    
    [self.commentsLabel sizeToFit];
    self.commentsLabel.frame = CGRectMake(self.userLabel.frame.origin.x + 5 + self.userLabel.frame.size.width, y, self.commentsLabel.frame.size.width, self.commentsLabel.frame.size.height);
    
    y += self.userLabel.frame.size.height + 10;
    
    // Updated label.
    [self.updatedAtLabel sizeToFit];
    self.updatedAtLabel.frame = CGRectMake(xOrigin, y, self.updatedAtLabel.frame.size.width, self.updatedAtLabel.frame.size.height);
    
    y += self.updatedAtLabel.frame.size.height + 10;
    
    self._viewHeight = y;
}

@end
