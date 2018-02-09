//
//  SoundDetailViewController.m
//  Photobook
//
//  Created by seta cheam on 6/9/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "SoundDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SYWaveformPlayerView.h"
#import "QueryServices.h"
#import "Tags.h"
#import "PhotoSound.h"
#import "TagViewController.h"
#import "MapViewController.h"
#import "SoundRecordViewController.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"

@interface SoundDetailViewController ()<UIActionSheetDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *photoScrollView;

@property (strong, nonatomic) NSArray * imageArray;

@property (strong, nonatomic) UIImage * currentImage;
@property (strong, nonatomic) NSString * currentSoundFilePath;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * statusLabel;

@end

@implementation SoundDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defaultView];
}

- (void)defaultView {
    
    [self.navigationItem setTitleView:[self titleView]];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloseButton"]
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(closeAction)]];
    
    if (!self.photoScrollView)
        self.photoScrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.photoScrollView setClipsToBounds:YES];
    [self.photoScrollView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self.photoScrollView setBounces:NO];
    [self.photoScrollView setDelegate:self];
    [self.photoScrollView setShowsVerticalScrollIndicator:NO];
    [self.photoScrollView setShowsHorizontalScrollIndicator:NO];
    [self.photoScrollView setPagingEnabled:YES];
    [self.view addSubview:self.photoScrollView];
    
    [self retrieveData];

    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self retrieveData];
}

- (void)retrieveData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.fetchController || self.currentTag){
            [self setupImageScrollView];
        }
    });
}

- (UIView *)titleView {
    
    UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 25)];
    [self.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:15]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [theView addSubview:self.titleLabel];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 250, 15)];
    [self.statusLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:9]];
    [self.statusLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    [theView addSubview:self.statusLabel];
    
    return theView;
    
}

- (void)setupImageScrollView{
    
    self.imageArray = @[];
    [self.photoScrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    if (self.fetchController){
        self.imageArray = [self.fetchController fetchedObjects];
    }else{
        self.imageArray = @[self.currentTag];
    }
    
    NSInteger currentOne = [self.imageArray indexOfObject:self.currentTag];
    
    for (int i = 0; i < self.imageArray.count; i ++){
        
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        rect.origin.x = self.view.frame.size.width * i;
        rect.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - 120);
        
        Tags * tag = [self.imageArray objectAtIndex:i];
        PhotoSound * sound = tag.photoSound;
        
        CGFloat latituteFloat = [sound.latitude floatValue];
        CGFloat longituteFloat = [sound.longitude floatValue];
        
        if (i == currentOne){
            NSDateFormatter *DateFormatter = [[NSDateFormatter alloc] init];
            [DateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
            [self.titleLabel setText:(![sound.placeName isEqualToString:@""] ? sound.placeName : @"...")];
            [self.statusLabel setText:[DateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[sound.date floatValue]/1000]]];
        }
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:rect];
        [img setContentMode:UIViewContentModeScaleAspectFit];
        [img setClipsToBounds:YES];
        [img setUserInteractionEnabled:YES];
        [img setTag:i];
        NSData *imgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:sound.image]];
        [img setImage:[UIImage imageWithData:imgData]];
        
        UITapGestureRecognizer * tapGueture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapZoom:)];
        [tapGueture setNumberOfTapsRequired:1];
        [tapGueture setNumberOfTouchesRequired:1];
        [img addGestureRecognizer:tapGueture];
        
        CGRect playerRect = self.view.frame;
        playerRect.origin.y = self.view.frame.size.height - 55;
        playerRect.origin.x = self.view.frame.size.width * i;
        playerRect.size = CGSizeMake(self.view.frame.size.width, 55);
        
        UIView * playerView = [[UIView alloc] initWithFrame:playerRect];
        [playerView setBackgroundColor:[UIColor whiteColor]];
        
        CGRect soundRect = CGRectMake(0, 5, 100, 45);
        CGRect recordRect = CGRectMake((playerView.frame.size.width/2) - 22, 5, 45 , 45);
        CGRect locationRect = CGRectMake(playerView.frame.size.width - 50, 5, 45 , 45);
        
        if (![sound.sound isEqualToString:@""]){
            NSURL * fileLocationUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:sound.sound]];
            
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileLocationUrl options:nil];
            SYWaveformPlayerView *soundPlayView = [[SYWaveformPlayerView alloc] initWithFrame:soundRect
                                                                                        asset:asset
                                                                                        color:[UIColor lightGrayColor]
                                                                                progressColor:[UIColor greenColor]];
            [playerView addSubview:soundPlayView];
            
        }
        
        UIButton * recordButton = [[UIButton alloc] initWithFrame:recordRect];
        [recordButton setImage:[UIImage imageNamed:@"SoundRecordMic"] forState:UIControlStateNormal];
        [recordButton setTag:i];
        [recordButton addTarget:self action:@selector(showRecordView:) forControlEvents:UIControlEventTouchUpInside];
        [playerView addSubview:recordButton];
        
        if (longituteFloat != 0 || latituteFloat != 0){
            UIButton * locationButton = [[UIButton alloc] initWithFrame:locationRect];
            [locationButton setImage:[UIImage imageNamed:@"Pin"] forState:UIControlStateNormal];
            [locationButton setTag:i];
            [locationButton addTarget:self action:@selector(showImageOnMap:) forControlEvents:UIControlEventTouchUpInside];
            [playerView addSubview:locationButton];
        }
        
        CGRect tagRect = self.view.frame;
        tagRect.origin.y = self.view.frame.size.height - 115;
        tagRect.origin.x = self.view.frame.size.width * i + 5;
        tagRect.size = CGSizeMake(50, 50);
        
        UIButton * tagButton = [[UIButton alloc] initWithFrame:tagRect];
        [tagButton setImage:[UIImage imageNamed:@"Tag"] forState:UIControlStateNormal];
        [tagButton setTag:i];
        [tagButton addTarget:self action:@selector(editTagAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self.photoScrollView addSubview:img];
        [self.photoScrollView addSubview:playerView];
        [self.photoScrollView addSubview:tagButton];
    }
    
    [self.photoScrollView setContentSize:CGSizeMake(self.photoScrollView.frame.size.width * self.imageArray.count,
                                                    self.photoScrollView.frame.size.height)];
    [self.photoScrollView scrollRectToVisible:CGRectMake(0, 0, self.photoScrollView.frame.size.width * (currentOne + 1),
                                                         self.photoScrollView.frame.size.height) animated:NO];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)editTagAction:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(retrieveData) name:@"editRefresh"
                                               object:nil];
    
    Tags * tag = [[self.fetchController fetchedObjects] objectAtIndex:sender.tag];
    PhotoSound * sound = tag.photoSound;
    
    NSFetchedResultsController * tagResultController = [Tags MR_fetchAllGroupedBy:@"name"
                                                                    withPredicate:[NSPredicate predicateWithFormat:@"photoId == %@", tag.photoId]
                                                                         sortedBy:@"name" ascending:YES];
    
    NSMutableArray * currentTags = [NSMutableArray new];
    for (int i = 0; i < [[tagResultController sections] count]; i++){
        Tags * tag = (Tags *)[tagResultController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
        [currentTags addObject:[self tagColorNameDict:tag.name color:tag.color tagIcon:tag.imgName]];
    }
    
    TagViewController * tagVC = [[TagViewController alloc] init];
    NSData *imgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:sound.image]];
    [tagVC setPhotoImage:[UIImage imageWithData:imgData]];
    [tagVC setType:editTag];
    [tagVC setSavedTags:currentTags];
    [tagVC setSavedSound:sound];
    [self.navigationController pushViewController:tagVC animated:YES];
}

- (NSDictionary *)tagColorNameDict:(NSString *)tagName color:(NSString *)tagColor tagIcon:(NSString *)icon {
    return @{
             @"name" : tagName,
             @"color" : tagColor,
             @"img" : icon
             };
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showRecordView:(UIButton *)sender {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(retrieveData) name:@"editRefresh"
                                               object:nil];
    
    Tags * tag = [[self.fetchController fetchedObjects] objectAtIndex:sender.tag];
    PhotoSound * sound = tag.photoSound;
    
    NSData *imgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:sound.image]];
    
    SoundRecordViewController * soundRecord = [[SoundRecordViewController alloc] init];
    [soundRecord setEditedSound:sound];
    [soundRecord setType:editSound];
    [soundRecord setGalleryImage:[UIImage imageWithData:imgData]];
    [self.navigationController pushViewController:soundRecord animated:YES];
}

- (void)showImageOnMap:(UIButton *)sender {
    
    Tags * tag = [[self.fetchController fetchedObjects] objectAtIndex:sender.tag];
    PhotoSound * photo = tag.photoSound;
    
    CGFloat latituteFloat = [photo.latitude floatValue];
    CGFloat longituteFloat = [photo.longitude floatValue];
    
    if (longituteFloat != 0 || latituteFloat != 0){
        MapViewController * map = [[MapViewController alloc] init];
        [map setLocationArray:@[tag]];
        [self.navigationController pushViewController:map animated:YES];
    }
    
}

- (void)tapZoom:(UITapGestureRecognizer *)sender {
    
    UIView * view = sender.view;
    
    Tags * tag = [self.imageArray objectAtIndex:view.tag];
    PhotoSound * sound = tag.photoSound;
    
    NSData *imgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:sound.image]];
    
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = [UIImage imageWithData:imgData];
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    [imageViewer showFromViewController:self
                             transition:JTSImageViewControllerTransition_FromOffscreen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
