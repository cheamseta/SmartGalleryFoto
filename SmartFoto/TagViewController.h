//
//  TagViewController.h
//  Photobook
//
//  Created by seta cheam on 26/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "BasedViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoSound.h"

typedef enum {
    editTag,
    uploadTag
} tagType;

@interface TagViewController : BasedViewController

@property (strong, nonatomic) UIImage * photoImage;
@property (strong, nonatomic) NSString * soundFile;

@property (nonatomic) tagType type;

@property (strong, nonatomic) PhotoSound * savedSound;
@property (strong, nonatomic) NSArray * savedTags;

@end
