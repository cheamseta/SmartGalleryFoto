//
//  TextCollectionViewCell.h
//  Photobook
//
//  Created by seta cheam on 23/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIView *iconHolderView;
@property (strong, nonatomic) IBOutlet UILabel *TheLabel;
@property (strong, nonatomic) IBOutlet UIImageView *theImageView;
@property (strong, nonatomic) IBOutlet UIView *selectedView;

@end
