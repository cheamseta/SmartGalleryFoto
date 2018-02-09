//
//  SearchViewController.m
//  Photobook
//
//  Created by seta cheam on 21/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "SearchViewController.h"
#import "Tags.h"
#import "TagTableViewCell.h"
#import "QueryServices.h"
#import "ResultViewController.h"

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tagTableView;

@property (strong, nonatomic) Tags * tags;

@property (strong, nonatomic) NSMutableArray * tagArray;
@property (strong, nonatomic) NSFetchedResultsController * fetchController;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self retrieveDataFromDatabase];
    [self defaultView];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [self.searchBar becomeFirstResponder];
    [self.searchBar setDelegate:self];
}

- (void)retrieveDataFromDatabase{
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    NSFetchedResultsController * fetchController = [Tags MR_fetchAllGroupedBy:@"name" withPredicate:nil sortedBy:@"name" ascending:YES];
    
    self.tagArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [[fetchController sections] count]; i++){
        Tags * tag = [fetchController objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
        [self.tagArray addObject:tag];
    }
    
    
    return fetchController;
}

- (void)defaultView {
    
    [self navigationInViewWithTitle:@"Search Tags"];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CloseButton"]
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(closeAction)]];
    
    [self.tagTableView setDataSource:self];
    [self.tagTableView setDelegate:self];
    [self.tagTableView registerNib:[UINib nibWithNibName:@"TagTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
    [self.searchBar becomeFirstResponder];
    [self.searchBar setDelegate:self];
    
}

- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collectionView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tagArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TagTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    Tags * tag = [self.tagArray objectAtIndex:indexPath.row];
    
    [cell.tagNameLabel setText:tag.name];
    [cell.iconHolderView setBackgroundColor:[UIColor colorWithHexString:tag.color]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tags * tag = [self.tagArray objectAtIndex:indexPath.row];
    
    ResultViewController * result = [[ResultViewController alloc] init];
    [result setSearchedTag:tag.name];
    
    UINavigationController * nav =  [[UINavigationController alloc] initWithRootViewController:result];
    [nav setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - search bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText isEqualToString:@""]){
        [self retrieveDataFromDatabase];
    }else{
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        self.tagArray = [[NSMutableArray alloc] initWithArray:[self.tagArray filteredArrayUsingPredicate:pred]];
    }
    
    [self.tagTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setAlpha:0];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

@end
