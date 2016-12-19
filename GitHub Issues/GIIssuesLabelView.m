//
//  GIIssuesLabelView.m
//  Github Issues
//
//  Created by Matt Clarke on 18/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIIssuesLabelView.h"

@implementation GIIssuesLabelView

// Assumes input like "00FF00" (RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(void)setupWithDictionary:(NSDictionary*)dict {
    self.label = [[UILabel alloc] initWithFrame:CGRectZero];
    self.label.text = [dict objectForKey:@"name"];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:14];
    self.label.textColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    
    [self addSubview:self.label];
    
    // Configure own params.
    self.layer.cornerRadius = 1.5;
    self.layer.masksToBounds = YES;
    
    // And background color!
    self.backgroundColor = [GIIssuesLabelView colorFromHexString:[dict objectForKey:@"color"]];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.label.frame = self.bounds;
}

@end
