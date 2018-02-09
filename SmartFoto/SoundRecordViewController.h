
//  SoundRecordViewController.h
//  Photobook

//  Created by seta cheam on 17/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.


#import "BasedViewController.h"
#import "PhotoSound.h"

typedef enum {
    editSound,
    uploadSound
} soundType;

@protocol SoundRecordVCDelegate <NSObject>

@end

@interface SoundRecordViewController : BasedViewController

@property (strong, nonatomic) UIImage * galleryImage;
@property (strong, nonatomic) NSArray * selectedArray;

@property (strong, nonatomic) PhotoSound * editedSound;
@property (nonatomic) soundType type;


@end
