//
//  SoundDetailViewController.h
//  Photobook
//
//  Created by seta cheam on 6/9/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "BasedViewController.h"
#import "PhotoSound.h"

@protocol soundDetailVCDelegate <NSObject>

@optional
- (void)didCompleteDeletedPhoto;

@end

@interface SoundDetailViewController : BasedViewController

@property (strong, nonatomic) Tags * currentTag;
@property (strong, nonatomic) PhotoSound * sound;
@property (strong, nonatomic) NSFetchedResultsController * fetchController;
@property (weak, nonatomic) id<soundDetailVCDelegate> delegate;

@end
