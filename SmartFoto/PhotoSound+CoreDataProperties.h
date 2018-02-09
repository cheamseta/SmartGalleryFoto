//
//  PhotoSound+CoreDataProperties.h
//  Photobook
//
//  Created by seta cheam on 3/6/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PhotoSound.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoSound (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *photoId;
@property (nullable, nonatomic, retain) NSNumber *date;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSString *placeName;
@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSString *sound;
@property (nullable, nonatomic, retain) NSString *thumbnail;

@end

@interface PhotoSound (CoreDataGeneratedAccessors)


@end

NS_ASSUME_NONNULL_END
