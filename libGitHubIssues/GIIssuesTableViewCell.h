//
//  GIIssuesTableViewCell.h
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIIssuesTableViewCell : UITableViewCell {
    BOOL _usingExtras;
}

@property (nonatomic, strong) id issue;
@property (nonatomic, readwrite) CGFloat _viewHeight;

// UI.
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *commentsLabel;
@property (nonatomic, strong) UILabel *userLabel;
@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UIView *labelRegionView;
@property (nonatomic, strong) UILabel *updatedAtLabel;
@property (nonatomic, strong) UIView *closeOpenIndicator;

-(void)setupWithIssue:(id)issue withExtras:(BOOL)extras;

@end
