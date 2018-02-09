//
//  ViewController.m
//  Photobook
//
//  Created by seta cheam on 16/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "ViewController.h"
#import "PhotoSound.h"
#import "Tags.h"
#import "QueryServices.h"
#import "SoundRecordViewController.h"
#import "CollectionViewCell.h"
#import "SearchViewController.h"
#import "SoundRecordViewController.h"
#import "TitleCollectionReusableView.h"
#import "SoundDetailViewController.h"
#import "ResultViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TagViewController.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, SoundRecordVCDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic) PhotoSound * photoSound;
@property (strong, nonatomic) NSArray * photoArray;

@property (strong, nonatomic) IBOutlet UIView *galleryPlaceholder;
@property (strong, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSMutableArray * tagArray;
@property (strong, nonatomic) NSArray * tagNameArray;

@property (strong, nonatomic) NSFetchedResultsController * fetchController;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveData];
    [self setupDefaultView];
    
        [self performSelector:@selector(defaultStartupCamera) withObject:nil afterDelay:0.1];
}

- (void)setupDefaultView {
    
    [self navigationInViewWithTitle:@"Smart Fotobook"];
    
    [self setupCollectionView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData) name:@"exploreRefresh"
                                               object:nil];
    
    [self defaultStartupCamera];
    [self requestCurrentLocation];
    
}

- (void)requestCurrentLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)defaultStartupCamera {
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController * imgPicker = [[UIImagePickerController alloc] init];
        [imgPicker setDelegate:self];
        [imgPicker setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
}


- (void)setupCollectionView {
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setItemSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width/3), ([UIScreen mainScreen].bounds.size.width/3))];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.flowLayout.minimumInteritemSpacing = 0.0f;
    self.flowLayout.minimumLineSpacing = 0.0f;
    
    [self.photoCollectionView registerNib:[UINib nibWithNibName:@"TitleCollectionReusableView" bundle:nil]
               forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
                      withReuseIdentifier:@"headerView"];
    
    [self.photoCollectionView setDelegate:self];
    [self.photoCollectionView setDataSource:self];
    [self.photoCollectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self.photoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:UICollectionElementKindSectionHeader];
    [self.photoCollectionView setCollectionViewLayout:self.flowLayout];
    
}

- (void)refreshData{
    [self retrieveData];
    [self.photoCollectionView reloadData];
}

- (void)mainPlaceholder {
    if ([[self.fetchController sections] count] > 0){
        [self.galleryPlaceholder setHidden:YES];
    }else{
        [self.galleryPlaceholder setHidden:NO];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {    
    _fetchController = [Tags MR_fetchAllGroupedBy:@"name" withPredicate:nil sortedBy:@"name" ascending:YES];
    return _fetchController;
}


- (void)retrieveData {

    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
 
    [self mainPlaceholder];
}


#pragma mark - collect delegate and datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchController sections] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        
        TitleCollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];

        Tags * tag = [self.fetchController objectAtIndexPath:indexPath];
        id  sectionInfo = [[self.fetchController sections] objectAtIndex:indexPath.section];
        [reusableview.headerTitleLabel setText:[NSString stringWithFormat:@"%@ (%lu)", tag.name, [sectionInfo numberOfObjects]]];
        [reusableview.iconImageView setImage:[UIImage imageNamed:tag.imgName]];
        [reusableview.holderView setBackgroundColor:[UIColor colorWithHexString:tag.color]];

        return reusableview;
        
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize headerSize = CGSizeMake(self.view.frame.size.width, 50);
    return headerSize;
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
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    Tags * tag  = [self.fetchController objectAtIndexPath:indexPath];
    
    NSPredicate * prdicate = [NSPredicate predicateWithFormat:@"name == %@", tag.name];
    
    NSFetchedResultsController * categoryFetchController = [Tags MR_fetchAllGroupedBy:@"name" withPredicate:prdicate sortedBy:@"name" ascending:YES];
    
    SoundDetailViewController * sound = [[SoundDetailViewController alloc] init];
    [sound setFetchController:categoryFetchController];
    [sound setCurrentTag:tag];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:sound];
    [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:nav animated:YES completion:nil];
    CFRunLoopWakeUp(CFRunLoopGetCurrent());
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IB Action

- (IBAction)showSearchViewAction:(id)sender {
    
    SearchViewController * search = [[SearchViewController alloc] init];
    [search.view setFrame:self.navigationController.view.frame];
    [self.navigationController addChildViewController:search];
    [self.navigationController.view addSubview:search.view];
    [search.view setAlpha:0];
    
    [UIView animateWithDuration:0.5 animations:^{
        [search.view setAlpha:1];
    }];
    
}

#pragma mark - sound record delegate

- (void)didCompleteDeletedPhoto {
    [self retrieveData];
}

- (IBAction)galleryAction:(id)sender {
    
    UIImagePickerController * imgPicker = [[UIImagePickerController alloc] init];
    [imgPicker setDelegate:self];
    [imgPicker setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imgPicker animated:YES completion:nil];
    
}

- (IBAction)cameraAction:(id)sender {

    UIImagePickerController * imgPicker = [[UIImagePickerController alloc] init];
    [imgPicker setDelegate:self];
    [imgPicker setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imgPicker animated:YES completion:nil];
    
}

#pragma mark - pickerImage

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage * theImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        TagViewController * sound = [[TagViewController alloc] init];
        [sound setPhotoImage:theImg];
        [sound setType:uploadTag];
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:sound];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    
}

#pragma mark - location

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [Services storeSetFloatDefaultSetting:newLocation.coordinate.latitude withKey:@"latKey"];
        [Services storeSetFloatDefaultSetting:newLocation.coordinate.longitude withKey:@"lngKey"];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           if (placemarks && placemarks.count > 0) {
                               CLPlacemark *placemark = placemarks[0];
                               NSDictionary *addressDictionary = placemark.addressDictionary;
                               if (addressDictionary[@"State"]){
                                   [Services storeSetDefaultSetting:addressDictionary[@"State"] withKey:@"stateKey"];
                               }
                           }
                       }];
    });
    
    [self.locationManager stopUpdatingLocation];
    
}



@end
