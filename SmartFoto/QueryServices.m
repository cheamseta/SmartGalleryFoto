//
//  QueryServices.m
//  Photobook
//
//  Created by seta cheam on 16/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "QueryServices.h"
#import "PhotoSound.h"
#import "Tags.h"

@implementation QueryServices

#pragma mark - photo

+ (NSArray *)retrieveAllPhotos {
    NSArray *photoArray = [PhotoSound MR_findAll];
    return photoArray;
}

+ (NSArray *)retrievePhotosByQuery:(NSString *)queryString ascending:(NSString *)isAscending {
    NSArray * photoArray = [PhotoSound MR_findAllSortedBy:queryString ascending:isAscending];
    return photoArray;
}

+ (NSArray *)retrievePhotosBySearchKeyword:(NSString *)keywordString{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"image IN %@", keywordString];
    NSArray * photoArray = [PhotoSound MR_findAllWithPredicate:filter];
    return photoArray;
}

+ (NSArray *)retrievePhotosByTags:(NSString *)tag{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"tags CONTAINS[c] %@", tag];
    NSArray * photoArray = [PhotoSound MR_findAllWithPredicate:filter];
    return photoArray;
}

+ (NSArray *)retrievePhotosByLocation:(NSString *)locationString{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"location IN %@", locationString];
    NSArray * photoArray = [PhotoSound MR_findAllWithPredicate:filter];
    return photoArray;
}

#pragma mark - tags

+ (NSArray *)retrieveAllTags {
    return [Tags MR_findAll];
}

+ (void)removeTagByPhotoId:(NSString *)photoId{
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"photoId ==[c] %@", photoId];
    NSArray * tagArray = [Tags MR_findAllWithPredicate:filter];
    
    for (Tags * tag in tagArray){
        [tag MR_deleteEntity];
    }
    
}

@end
