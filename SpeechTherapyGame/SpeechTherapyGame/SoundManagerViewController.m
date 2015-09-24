//
//  SoundManagerViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "SoundManagerViewController.h"

@interface SoundManagerViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray* _collectionViewData;
    IBOutlet UICollectionView* _letterCollectionView;
}
@end

@implementation SoundManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[_letterCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"letterCell"];

    // Do any additional setup after loading the view.
    
    _collectionViewData = [NSMutableArray array];
    for (int i = 0; i<10; i++) {
        [_collectionViewData addObject:@"a"];
    }
    self.view.backgroundColor = RGB(47,139,193);
    _letterCollectionView.backgroundColor = [UIColor whiteColor];

    [self.view viewWithTag:1].layer.cornerRadius = 20;
    [self.view viewWithTag:2].layer.cornerRadius = 20;
    [self.view viewWithTag:3].layer.cornerRadius = 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

    return [_collectionViewData count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"letterCell" forIndexPath:indexPath];
    
    UIView* backgroundView = [cell viewWithTag:1];
    backgroundView.layer.cornerRadius = 15;
    
    return cell;
}

@end
