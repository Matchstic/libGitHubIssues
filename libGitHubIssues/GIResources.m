//
//  GIResources.m
//  Github Issues
//
//  Created by Matt Clarke on 16/12/2016.
//  Copyright © 2016 Matt Clarke. All rights reserved.
//

#import "GIResources.h"
#import "GIKeychainWrapper.h"
#import <OctoKit.h>

static OCTClient *sharedClient;
static OCTClient *sharedUnauthenticatedClient;
static RACSignal *sharedRepository;
static GIKeychainWrapper *sharedKeychain;

@implementation GIResources

+(CGRect)boundedRectForFont:(UIFont*)font andText:(id)text width:(CGFloat)width {
    if (!text || !font) {
        return CGRectZero;
    }
    
    if (![text isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:font}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        return rect;
    } else {
        return [(NSAttributedString*)text boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                                       options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                       context:nil];
    }
}

+(UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

+(NSString*)formatDate:(NSDate*)date {
    // Format will output time:
    // - within 24 hours "9:35"
    // - within 1 week "2d ago"
    // - within 1 month "1w go"
    // - within 1 year "5m ago"
    // - else, "5y ago"
    
    NSCalendarUnit units = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ldy ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ldm ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ldw ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        return [NSString stringWithFormat:@"%ldd ago", (long)components.day];
    } else if (components.hour > 0) {
        return [NSString stringWithFormat:@"%ldhr ago", (long)components.hour];
    } else {
        return [NSString stringWithFormat:@"%ldmins ago", (long)components.minute];
    }
}

+(UIImage*)imageWithName:(NSString*)name {
#if BUILD_FOR_CYDIA==0
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"libGitHubIssues" withExtension:@"bundle"];
    NSString *path = [[NSBundle bundleWithURL:bundleURL] pathForResource:name ofType:@"png"];
#else
    NSString *suffix = @"";
    switch ((int)[UIScreen mainScreen].scale) {
        case 2:
            suffix = @"@2x";
            break;
        case 3:
            suffix = @"@3x";
            break;
            
        default:
            break;
    }
    
    NSString *path = [NSString stringWithFormat:@"/Library/Application Support/libGitHubIssues/%@%@.png", name, suffix];
#endif
    
    return [UIImage imageWithContentsOfFile:path];
}

+(void)_setSuccessfulClient:(OCTClient*)client {
    // Force an unauthenticated login if OAuth2 token failed.
    if (!client.token || [client.token isEqualToString:@""]) {
        client = nil;
    }
    
    sharedClient = client;
    
    if (client) {
        [sharedKeychain mySetObject:client.user.rawLogin forKey:(__bridge NSString*)kSecAttrAccount];
        [sharedKeychain mySetObject:client.token forKey:(__bridge NSString*)kSecValueData];
    } else {
        [sharedKeychain mySetObject:@"" forKey:(__bridge NSString*)kSecAttrAccount];
        [sharedKeychain mySetObject:@"" forKey:(__bridge NSString*)kSecValueData];
    }
    
    [sharedKeychain writeToKeychain];
}

+(OCTClient*)_getCurrentClient {
    
    NSString *username = [sharedKeychain myObjectForKey:(__bridge NSString*)kSecAttrAccount];
    NSString *token = [sharedKeychain myObjectForKey:(__bridge NSString*)kSecValueData];
    
    if (username && ![username isEqualToString:@""] && token && ![token isEqualToString:@""]) {
        OCTUser *user = [OCTUser userWithRawLogin:username server:OCTServer.dotComServer];
        sharedClient = [OCTClient authenticatedClientWithUser:user token:token];
        
        return sharedClient;
    }
    
    if (sharedUnauthenticatedClient) {
        return sharedUnauthenticatedClient;
    }
    
    sharedUnauthenticatedClient = [[OCTClient alloc] initWithServer:OCTServer.dotComServer];
    return sharedUnauthenticatedClient;
}

// Must be called first!
+(void)_registerAppIdentifier:(NSString*)identifier clientID:(NSString*)clientid andSecret:(NSString*)secret {
    [OCTClient setClientID:clientid clientSecret:secret];
    
    sharedKeychain = [[GIKeychainWrapper alloc] initWithKeychainID:[identifier UTF8String]];
}

+(void)_setCurrentRepositoryName:(NSString*)name andOwner:(NSString*)owner {
    sharedRepository = [(OCTClient*)[GIResources _getCurrentClient] fetchRepositoryWithName:name owner:owner];
}

+(id)_getCurrentRepository {
    return sharedRepository;
}

@end
