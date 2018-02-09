//
//  TagTableViewCell.m
//  Photobook
//
//  Created by seta cheam on 7/12/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "TagTableViewCell.h"

@implementation TagTableViewCell

- (void)awakeFromNib {
    [self.iconHolderView.layer setCornerRadius:17];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
