//
//  BasedViewController.m
//  Photobook
//
//  Created by seta cheam on 17/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "BasedViewController.h"

@interface BasedViewController ()

@end

@implementation BasedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)navigationInViewWithTitle:(NSString *)title {
    UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 50, 50)];
    titleLable.textColor = [UIColor darkGrayColor];
    [titleLable setFont:[UIFont fontWithName:@"Avenir-Black" size:16]];
    [titleLable setText:title];
    [self.navigationItem setTitleView:titleLable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
