//
//  TitleCollectionReusableView.h
//  Photobook
//
//  Created by seta cheam on 6/6/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleCollectionReusableView : UICollectionReusableView
@property (strong, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (strong, nonatomic) IBOutlet UIView *holderView;
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;

@end
