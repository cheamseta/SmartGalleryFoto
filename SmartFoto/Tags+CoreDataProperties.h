//
//  Tags+CoreDataProperties.h
//  Photobook
//
//  Created by seta cheam on 3/6/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Tags.h"

NS_ASSUME_NONNULL_BEGIN

@interface Tags (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *color;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *photoId;
@property (nullable, nonatomic, retain) NSString *imgName;
@property (nullable, nonatomic, retain) PhotoSound *photoSound;

@end

NS_ASSUME_NONNULL_END
