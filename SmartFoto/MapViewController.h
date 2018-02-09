//
//  MapViewController.h
//  Photobook
//
//  Created by seta cheam on 7/8/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "BasedViewController.h"

@interface MapViewController : BasedViewController

@property (strong, nonatomic) NSArray * locationArray;

@property (nonatomic) CGFloat currentLatitude;
@property (nonatomic) CGFloat currentLongitude;

@end
