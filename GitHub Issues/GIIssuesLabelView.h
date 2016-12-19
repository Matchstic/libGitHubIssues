//
//  GIIssuesLabelView.h
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIIssuesLabelView : UIView

@property (nonatomic, strong) UILabel *label;

-(void)setupWithDictionary:(NSDictionary*)dict;

@end
