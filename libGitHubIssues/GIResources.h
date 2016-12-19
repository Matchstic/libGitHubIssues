//
//  GIResources.h
//  Github Issues
//
//  Created by Matt Clarke on 16/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GIResources : NSObject

+(CGRect)boundedRectForFont:(UIFont*)font andText:(id)text width:(CGFloat)width;
+(UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;
+(NSString*)formatDate:(NSDate*)date;
+(UIImage*)imageWithName:(NSString*)name;

+(void)_setSuccessfulClient:(id)client;
+(void)_registerClientID:(NSString*)clientid andSecret:(NSString*)secret;
+(void)_setCurrentRepositoryName:(NSString*)name andOwner:(NSString*)owner;
+(id)_getCurrentClient;
+(id)_getCurrentRepository;
+(NSString*)_generateFingerprint;

@end
