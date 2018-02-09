//
//  ResultViewController.m
//  Photobook
//
//  Created by seta cheam on 7/8/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "ResultViewController.h"
#import "CollectionViewCell.h"
#import "PhotoSound.h"
#import "Tags.h"
#import "TitleCollectionReusableView.h"
#import "SoundDetailViewController.h"
#import "MapViewController.h"

@interface ResultViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) PhotoSound * photoSound;

@property (strong, nonatomic) NSArray * tagNameArray;
@property (strong, nonatomic) NSArray * photoArray;

@property (strong, nonatomic) NSMutableArray * selectedArray;

@property (strong, nonatomic) IBOutlet UIView *locationViewHolder;
@property (strong, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) NSMutableArray * tagArray;
@property (strong, nonatomic) NSFetchedResultsController * fetchController;

@property (nonatomic) BOOL isSelected;

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Select"
                                                                                style:UIBarButtonItemStyleDone
                                                                               target:self
                                                                               action:@selector(selectedAction:)]];
    
    [self retrieveData];
    [self setupDefaultView];
    
}

- (void)setupDefaultView {
    
    [self navigationInViewWithTitle:self.searchedTag];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloseButton"]
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(closeAction)]];
    
    self.selectedArray = [[NSMutableArray alloc] init];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setItemSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width/3) - 1,
                                            ([UIScreen mainScreen].bounds.size.width/3) - 1)];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.flowLayout.minimumInteritemSpacing = 1.0f;
    self.flowLayout.minimumLineSpacing = 1.0f;
    
    [self.photoCollectionView setDelegate:self];
    [self.photoCollectionView setDataSource:self];
    [self.photoCollectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil]
               forCellWithReuseIdentifier:@"cell"];
    [self.photoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UICollectionElementKindSectionHeader];
    [self.photoCollectionView setCollectionViewLayout:self.flowLayout];
    
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchController != nil) {
        return _fetchController;
    }
    
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"name == %@", self.searchedTag];
    _fetchController = [Tags MR_fetchAllGroupedBy:@"name" withPredicate:sPredicate sortedBy:@"name" ascending:YES];
    return _fetchController;
}


- (void)retrieveData {
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
}

- (void)selectedAction:(UIBarButtonItem *)sender {
    
    if (sender.tag == 0){
        [sender setTag:1];
        [sender setTitle:@"Cancel"];
        self.isSelected = YES;
    }else{
        [sender setTag:0];
        [sender setTitle:@"Select"];
        self.isSelected = NO;
    }
    
    
}

#pragma mark - collect delegate and datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id  sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    Tags * tag  = [self.fetchController objectAtIndexPath:indexPath];
    
    PhotoSound * photo = tag.photoSound;
    
    NSData *imgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:photo.thumbnail]];
    [cell.theImageView setImage:[UIImage imageWithData:imgData]];
    
    if ([self.selectedArray containsObject:tag]){
        [cell.checkCellImgeView setHidden:NO];
    }else{
        [cell.checkCellImgeView setHidden:YES];
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Tags * tag  = [self.fetchController objectAtIndexPath:indexPath];
    PhotoSound * sound = tag.photoSound;
    
    if (self.isSelected){
        
        if ([self.selectedArray containsObject:tag]){
            [self.selectedArray removeObject:tag];
        }else{
            
            NSInteger latituteFloat = [sound.latitude integerValue];

            if (latituteFloat == 0){
                [Services showalertViewInText:@"This photo has no location" title:@"Error"];
                return;
            }
            
            [self.selectedArray addObject:tag];
        }
        
        [self.photoCollectionView reloadData];
        
        if (self.selectedArray.count > 0){
            [self.locationViewHolder setHidden:NO];
        }else{
            [self.locationViewHolder setHidden:YES];
        }
        
    }else{
        SoundDetailViewController * sound = [[SoundDetailViewController alloc] init];
        [sound setFetchController:self.fetchController];
        [sound setCurrentTag:tag];
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:sound];
        [self presentViewController:nav animated:YES completion:nil];
    }
    
}

- (IBAction)locationAction:(id)sender {
    MapViewController * map = [[MapViewController alloc] init];
    [map setLocationArray:self.selectedArray];
    [self.navigationController pushViewController:map animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
