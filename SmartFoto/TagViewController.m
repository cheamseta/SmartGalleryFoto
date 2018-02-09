//
//  TagViewController.m
//  Photobook
//
//  Created by seta cheam on 26/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "TagViewController.h"
#import "QueryServices.h"
#import "Tags.h"
#import "TextCollectionViewCell.h"
#import "SoundRecordViewController.h"
#import "PhotoSound.h"

@interface TagViewController ()<UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray * tagNameArray;
@property (strong, nonatomic) NSMutableArray * selectedArray;
@property (strong, nonatomic) Tags * tags;
@property (strong, nonatomic) PhotoSound * sound;

@property (strong, nonatomic) NSString * placeName;

@property (nonatomic) CGFloat longitude;
@property (nonatomic) CGFloat latitude;

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * statusLabel;

@property (strong, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIView *addTagView;
@property (strong, nonatomic) IBOutlet UITextField *tagTextField;
@property (strong, nonatomic) IBOutlet UIView *TagHolderView;

@end

@implementation TagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defaultSetupView];
}

- (void)defaultSetupView {
    
    [self.navigationItem setTitleView:[self titleView]];
    
    self.selectedArray = [[NSMutableArray alloc] init];
    self.tagNameArray = [[NSMutableArray alloc] init];
    
    if (self.type == editTag){
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doneEditAction)];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];
        [self.photoImageView setUserInteractionEnabled:YES];
        [self.photoImageView addGestureRecognizer:tapGesture];
        
        [self.selectedArray addObjectsFromArray:self.savedTags];
        
    }else{
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveAction)];
        [tapGesture setNumberOfTapsRequired:1];
        [tapGesture setNumberOfTouchesRequired:1];
        [self.photoImageView setUserInteractionEnabled:YES];
        [self.photoImageView addGestureRecognizer:tapGesture];
        
    }
    
    [self.TagHolderView.layer setCornerRadius:15];
    [self.TagHolderView setClipsToBounds:YES];
    
    [self.photoImageView setImage:self.photoImage];
    [self setupCollectionView];
    [self retrieveData];
    
}

- (void)setupCollectionView {
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.flowLayout setItemSize:CGSizeMake(([UIScreen mainScreen].bounds.size.width/2) - 1, 49)];
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.flowLayout setMinimumInteritemSpacing: 1.0f];
    [self.flowLayout setMinimumLineSpacing:1.0f];
    
    [self.tagCollectionView setDataSource:self];
    [self.tagCollectionView setDelegate:self];
    [self.tagCollectionView registerNib:[UINib nibWithNibName:@"TextCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [self.tagCollectionView setCollectionViewLayout:self.flowLayout];
    
    [self defaultSetup];
    
}

- (void)defaultSetup {
    [self.tagNameArray addObject:[self tagColorNameDict:@"Family" color:@"ff005c" icon:@"BookIcon"]];
    [self.tagNameArray addObject:[self tagColorNameDict:@"Shop" color:@"d49d11" icon:@"DocIcon"]];
    [self.tagNameArray addObject:[self tagColorNameDict:@"Food" color:@"d49d11" icon:@"HeartDownIcon"]];
    [self.tagNameArray addObject:[self tagColorNameDict:@"Love it" color:@"d49d11" icon:@"HeartDownIcon"]];
    [self.tagNameArray addObject:[self tagColorNameDict:@"Travel" color:@"d49d11" icon:@"DocIcon"]];
}

- (BOOL)isInvalidTag:(NSString *)tagName {
    if ([tagName isEqualToString:@"Family"] ||
        [tagName isEqualToString:@"Shop"] ||
        [tagName isEqualToString:@"Food"] ||
        [tagName isEqualToString:@"Love it"] ||
        [tagName isEqualToString:@"Travel"]) {
        return NO;
    }else{
        return YES;
    }
}

- (UIView *)titleView {
    
    self.placeName = [Services storeGetDefaultSettingByKey:@"stateKey"];
    self.longitude = [Services storeGetFloatDefaultSettingByKey:@"lngKey"];
    self.latitude = [Services storeGetFloatDefaultSettingByKey:@"latKey"];
    
    NSDateFormatter *DateFormatter = [[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"EEEE, MMM d, yyyy"];
    
    UIView * theView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 40)];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 25)];
    [self.titleLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Medium" size:15]];
    [self.titleLabel setText:(self.placeName) ? self.placeName : @"No Location"];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [theView addSubview:self.titleLabel];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 250, 15)];
    [self.statusLabel setFont:[UIFont fontWithName:@"AvenirNextCondensed-Regular" size:9]];
    [self.statusLabel setText:[DateFormatter stringFromDate:[NSDate date]]];
    [self.statusLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    [theView addSubview:self.statusLabel];
    
    return theView;
    
}

- (void)doneEditAction {
    
    if (self.selectedArray.count <= 0){
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Option" message:@"No Selection ! This photo will be removed. Would you like to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alertView show];
        return;
    }else{
        [self editingProcess];
    }
}

- (void)editingProcess {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // reset everything
    NSPredicate *tagsFilter = [NSPredicate predicateWithFormat:@"photoId == %@", self.savedSound.photoId];
    NSArray *tags = [Tags MR_findAllWithPredicate:tagsFilter];
    
    for (Tags * tag in tags){
        [tag MR_deleteEntity];
    }
    
    if (self.selectedArray.count > 0){
        for (NSDictionary * tagDict in self.selectedArray){
            Tags * tag = [Tags MR_createEntity];
            [tag setName:tagDict[@"name"]];
            [tag setColor:tagDict[@"color"]];
            [tag setImgName:tagDict[@"img"]];
            [tag setPhotoId:self.savedSound.photoId];
            [tag setPhotoSound:self.savedSound];
            
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext]
     MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"editRefresh" object:self];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"exploreRefresh" object:self];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
           [self dismissViewControllerAnimated:YES completion:nil];
     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1){
        [self editingProcess];
    }
}

- (void)retrieveData {
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    NSFetchedResultsController * fetchController = [Tags MR_fetchAllGroupedBy:@"name" withPredicate:nil sortedBy:@"name" ascending:YES];
    
    for (int i = 0; i < [[fetchController sections] count]; i++){
        Tags * tag = (Tags *)[fetchController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
        if ([self isInvalidTag:tag.name]){
            [self.tagNameArray addObject:[self tagColorNameDict:tag.name color:tag.color icon:tag.imgName]];
        }
    }
    
    [self.tagCollectionView reloadData];
    
    return fetchController;
}


- (void)saveAction {
    
    if (self.type == uploadTag){
        if (self.selectedArray.count <= 0){
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Option" message:@"No Selection ! This photo will be removed. Would you like to continue?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alertView show];
            return;
        }
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString * imgUrl = [Services saveImageToDisk:self.photoImageView.image];
    NSString * thumbImgUrl = [Services saveImageToDisk:[Services imageWithImage:self.photoImageView.image scaledToWidth:150]];
    NSString * soundUrl = @"";
    
    if (imgUrl){
        [self savePhoto:imgUrl thumbnail:thumbImgUrl sound:soundUrl];
    }else{
        [Services showalertViewInText:@"Problem saving your picture, please try again !!" title:@"Error"];
    }
    
}

- (void)savePhoto:(NSString *)photoUrl thumbnail:(NSString *)thumbnailUrl sound:(NSString *)soundUrl{
    
    if (!self.sound){
        self.sound = [PhotoSound MR_createEntity];
    }
    
    NSDate *date = [NSDate date];
    
    self.sound.photoId = [[NSUUID UUID] UUIDString];
    self.sound.sound = soundUrl;
    self.sound.image = photoUrl;
    self.sound.latitude = (self.latitude) ? @(self.latitude) : @0;
    self.sound.longitude = (self.longitude) ? @(self.longitude) : @0;
    self.sound.placeName = (self.placeName) ? self.placeName : @"";
    self.sound.thumbnail = thumbnailUrl;
    [self.sound setDate:@(floor([date timeIntervalSince1970] * 1000))];
    
    if (self.selectedArray.count > 0){
        for (NSDictionary * tagDict in self.selectedArray){
            Tags * tag = [Tags MR_createEntity];
            [tag setName:tagDict[@"name"]];
            [tag setColor:tagDict[@"color"]];
            [tag setImgName:tagDict[@"img"]];
            [tag setPhotoId:self.sound.photoId];
            [tag setPhotoSound:self.sound];
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext]
     MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"exploreRefresh" object:self];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self dismissViewControllerAnimated:YES completion:nil];
     }];
    
}

#pragma mark - IBAction

- (IBAction)cancelTagAction:(id)sender {
    [self dismissAddTagView];
}

- (IBAction)addTagAction:(id)sender {
    
    NSString *trimmedString = [self.tagTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedString isEqualToString:@""]){
        [Services showalertViewInText:@"Please fill out your tag properly" title:@"Error"];
        return;
    }
    
    NSDictionary * dict = [self tagColorNameDict:[trimmedString lowercaseString]
                                           color:[UIColor hexValuesFromUIColor:[Services randomColor]]
                                            icon:[Services randomImage]];
    
    for (NSDictionary * tagDict in self.tagNameArray){
        if ([tagDict[@"name"] isEqualToString:[trimmedString lowercaseString]]){
            dict = [self tagColorNameDict:tagDict[@"name"]
                                    color:tagDict[@"color"]
                                     icon:tagDict[@"img"]];
            break;
        }
    }
    
    
    if (![self.tagNameArray containsObject:dict] && ![self.selectedArray containsObject:dict]){
        [self.tagNameArray addObject:dict];
        [self.selectedArray addObject:dict];
        [self.tagCollectionView reloadData];
        
    }else{
        
        [self.selectedArray addObject:dict];
        [self.tagCollectionView reloadData];
        
    }
    
    [self.tagTextField setText:@""];
    [self dismissAddTagView];
}

#pragma mark - collectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tagNameArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TextCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.row == 0){
        [cell.TheLabel setText:@"ADD TAGS"];
        [cell.TheLabel setTextColor:[UIColor darkGrayColor]];
        [cell.theImageView setImage:[UIImage imageNamed:@"Tags"]];
        [cell.selectedView setBackgroundColor:[UIColor clearColor]];
        [cell.iconHolderView setBackgroundColor:[UIColor clearColor]];
    }else{
        NSDictionary * tagDict = [self.tagNameArray objectAtIndex:indexPath.row - 1];
        [cell.TheLabel setText:tagDict[@"name"]];
        
        if ([self.selectedArray containsObject:tagDict]){
            [cell.TheLabel setTextColor:[UIColor whiteColor]];
            [cell.theImageView setImage:[UIImage imageNamed:@"Check"]];
            [cell.selectedView setBackgroundColor:[UIColor colorWithHexString:tagDict[@"color"]]];
            [cell.iconHolderView setBackgroundColor:[UIColor clearColor]];
        }else{
            [cell.TheLabel setTextColor:[UIColor darkGrayColor]];
            [cell.theImageView setImage:[UIImage imageNamed:tagDict[@"img"]]];
            [cell.selectedView setBackgroundColor:[UIColor clearColor]];
            [cell.iconHolderView setBackgroundColor:[UIColor colorWithHexString:tagDict[@"color"]]];
        }
        
    }
    
    return cell;
    
}

- (NSDictionary *)tagColorNameDict:(NSString *)tagName color:(NSString *)tagColor icon:(NSString *)tagImgName {
    return @{
             @"name" : tagName,
             @"color" : tagColor,
             @"img" : tagImgName
             };
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0){
        
        [self.addTagView setFrame:self.navigationController.view.frame];
        [self.view addSubview:self.addTagView];
        [self.addTagView setAlpha:0];
        
        UITapGestureRecognizer * dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAddTagView:)];
        [self.addTagView addGestureRecognizer:dismissTap];
        
        [UIView animateWithDuration:0.5 animations:^{
            [self.addTagView setAlpha:1];
        }];
        
        [self.tagTextField becomeFirstResponder];
        
    }else{
        
        if (self.type == editTag){
            if (self.selectedArray.count <= 0){
                [Services showalertViewInText:@"Remove the last tag will remove the photo, Would you like to remove it?" title:@"Error"];
                return;
            }
        }
        
        NSString * tag = [self.tagNameArray objectAtIndex:indexPath.row - 1];
        
        if ([self.selectedArray containsObject:tag]){
            [self.selectedArray removeObject:tag];
        }else{
            [self.selectedArray addObject:tag];
        }
        
        [self.tagCollectionView reloadData];
        
    }
    
}

#pragma mark - selector - method

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissAddTagView {
    [UIView animateWithDuration:0.5 animations:^{
        [self.addTagView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.addTagView removeFromSuperview];
    }];
}

- (void)dismissAddTagView:(UITapGestureRecognizer *)sender {
    [self dismissAddTagView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
