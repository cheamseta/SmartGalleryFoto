//
//  Services.h
//  Photobook
//
//  Created by seta cheam on 16/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Services : NSObject

+ (NSString *)randomImage;

+ (UIColor *)color;

+ (void)storeSetFloatDefaultSetting:(float)floatValue withKey:(NSString *)key;
+ (float)storeGetFloatDefaultSettingByKey:(NSString *)key;

+ (void)storeSetDefaultSetting:(id)object withKey:(NSString *)key;
+ (id)storeGetDefaultSettingByKey:(NSString *)key;

+ (NSString *)saveImageToDisk:(UIImage*)image;
+ (void)deleteAtPath:(NSString *)path;
+ (UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width;

+ (UIColor *)randomColor;

+ (void)showalertViewInText:(NSString *)text title:(NSString *)title;

@end
