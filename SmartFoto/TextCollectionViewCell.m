//
//  TextCollectionViewCell.m
//  Photobook
//
//  Created by seta cheam on 23/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "TextCollectionViewCell.h"

@implementation TextCollectionViewCell

- (void)awakeFromNib {
    [self.selectedView.layer setCornerRadius:10];
    [self.selectedView setClipsToBounds:YES];
    [self.iconHolderView.layer setCornerRadius:17];
}

@end
