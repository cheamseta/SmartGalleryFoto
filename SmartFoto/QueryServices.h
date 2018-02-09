//
//  QueryServices.h
//  Photobook
//
//  Created by seta cheam on 16/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryServices : NSObject

+ (NSArray *)retrieveAllPhotos;
+ (NSArray *)retrievePhotosByQuery:(NSString *)queryString ascending:(NSString *)isAscending;
+ (NSArray *)retrievePhotosBySearchKeyword:(NSString *)keywordString;
+ (NSArray *)retrievePhotosByTags:(NSString *)tag;
+ (NSArray *)retrievePhotosByLocation:(NSString *)locationString;

+ (NSArray *)retrieveAllTags;
+ (void)removeTagByPhotoId:(NSString *)photoId;

@end
