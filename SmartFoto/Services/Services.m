//
//  Services.m
//  Photobook
//
//  Created by seta cheam on 16/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "Services.h"
#import <Google/Analytics.h>

@implementation Services

+ (UIColor *)color {
    return [UIColor colorWithRed:0.52 green:0.83 blue:0.11 alpha:1.0];
}

#pragma mark - random icon

+ (NSString *)randomImage {
    NSArray * icons = @[
                        @"BookIcon",
                        @"DocIcon"
                        ];
    
    int i = arc4random() % icons.count;
    
    return icons[i];
    
}

#pragma mark - setting store

+ (void)storeSetFloatDefaultSetting:(float)floatValue withKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setFloat:floatValue forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (float)storeGetFloatDefaultSettingByKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] floatForKey:key];
}

+ (void)storeSetDefaultSetting:(id)object withKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)storeGetDefaultSettingByKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

#pragma mark - image

+ (NSString *)saveImageToDisk:(UIImage*)image {
    NSData *imgData   = UIImageJPEGRepresentation(image, 1);
    NSString *name    = [[NSUUID UUID] UUIDString];
    NSString *path	  = [NSString stringWithFormat:@"Documents/%@.jpg", name];
    NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    
    if ([imgData writeToFile:jpgPath atomically:YES]) {
        return path;
    } else {
        [self showalertViewInText:@"There was an error saving your photo. Try again." title:@""];
        return nil;
    }
    
}

+ (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width {
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)deleteAtPath:(NSString *)path {
    NSError *error;
    NSString *imgToRemove = [NSHomeDirectory() stringByAppendingPathComponent:path];
    [[NSFileManager defaultManager] removeItemAtPath:imgToRemove error:&error];
}

#pragma mark - analytic

+ (void)analyticScreenName:(NSString *)name {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (void)analyticEventInCategory:(NSString *)categoryString action:(NSString *)action label:(NSString *)label {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:categoryString    // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:label         // Event label
                                                           value:nil] build]];
}

#pragma mark - color

+ (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

+ (void)showalertViewInText:(NSString *)text title:(NSString *)title {
    [[[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
