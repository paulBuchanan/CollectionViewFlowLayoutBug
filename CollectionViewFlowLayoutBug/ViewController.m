//
//  ViewController.m
//  CollectionViewFlowLayoutBug
//
//  Created by u0032428 on 6/1/17.
//  Copyright © 2017 TRGR. All rights reserved.
//

#import "ViewController.h"
#import "HeaderView.h"

#define StatusBarOrientation ([UIApplication sharedApplication].statusBarOrientation)

#define CELL_ID @"EventCell"
#define CELL_CODE @"EntryCell"
#define SECTION_HEADER @"SectionHeader"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, assign) BOOL showWideCell;

@property (nonatomic, strong) NSArray *cells;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // just some simple sample data indicating the number of items in each section
    self.cells = @[ @2, @3, @4, @5, @6, @7];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventChooserCell" bundle: nil] forCellWithReuseIdentifier:CELL_ID];
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventCodeCell" bundle: nil] forCellWithReuseIdentifier:CELL_CODE];
    [self.collectionView registerNib:[UINib nibWithNibName:@"EventChooserSectionHeaderView" bundle: nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:SECTION_HEADER];
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.flowLayout.headerReferenceSize = CGSizeMake(0, 60);
    self.flowLayout.minimumLineSpacing = 12;
    self.flowLayout.minimumInteritemSpacing = 10;
    
    [self setupContentInsetForOrientation:StatusBarOrientation];
    
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self setupContentInsetForOrientation:StatusBarOrientation];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}


- (void)setupContentInsetForOrientation:(UIInterfaceOrientation)orientation {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 59, 0, 59);
    } else {
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 21, 0, 21);
    }

    [self.flowLayout invalidateLayout];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    
    NSInteger numItemsInSection = [self.cells[section] integerValue];

    // All sections get 17 pt top offset, except for last section which gets 17pt top and bottom
    if (numItemsInSection - 1 == section) {
        return UIEdgeInsetsMake(17, 0, 17, 0);
    } else {
        return UIEdgeInsetsMake(17, 0, 9, 0);
    }

}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.cells.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = [self.cells[section] integerValue];
    if (self.showWideCell) {
        return count;
    } else {
        return count - 1;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    HeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                  withReuseIdentifier:SECTION_HEADER
                                                                                         forIndexPath:indexPath];
    //header.layer.borderWidth = 1;
    //header.layer.borderColor = [UIColor blackColor].CGColor;
    headerView.headerLabel.text = [NSString stringWithFormat:@"Section header %ld", (long)indexPath.section ];
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numItemsInSection = [self.cells[indexPath.section] integerValue];
    
    if(indexPath.row == numItemsInSection - 1 && self.showWideCell) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_CODE
                                                                               forIndexPath:indexPath];
        //cell.layer.borderWidth = 1;
        //cell.layer.borderColor = [UIColor blackColor].CGColor;
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID
                                                                               forIndexPath:indexPath];
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = [UIColor blackColor].CGColor;
                return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize newSize = CGSizeMake(0.0, 0.0);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    NSInteger numItemsInSection = [self.cells[indexPath.section] integerValue];
    
    if(indexPath.row == numItemsInSection - 1 && self.showWideCell) {
        CGFloat iPadWidth = screenWidth - (self.collectionView.contentInset.left * 2);
        CGFloat iPadHeight = 80;
        newSize = CGSizeMake(iPadWidth, iPadHeight);
    } else {
        newSize = CGSizeMake(320, 253);
    }
    
    return newSize;
}

- (IBAction)toggleWideCell:(id)sender {
    self.showWideCell = !self.showWideCell;
    [self.flowLayout invalidateLayout];
    [self.collectionView reloadData];
}



@end
