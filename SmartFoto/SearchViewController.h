//
//  SearchViewController.h
//  Photobook
//
//  Created by seta cheam on 21/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "BasedViewController.h"
#import "Tags.h"

@protocol searchDelegate <NSObject>

- (void)searchDidSelectOnTag:(Tags *)tag;

@end

@interface SearchViewController : BasedViewController

@property (weak, nonatomic) id<searchDelegate> delegate;

@end
