//
//  TagTableViewCell.h
//  Photobook
//
//  Created by seta cheam on 7/12/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (strong, nonatomic) IBOutlet UIView *iconHolderView;

@end
