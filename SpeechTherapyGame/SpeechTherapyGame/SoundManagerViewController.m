//
//  SoundManagerViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "SoundManagerViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import "PhonemeCell.h"
#import "DataManager.h"
#import "Word.h"

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
    
    _collectionViewData = [[DataManager shared] getUniquePhoneme];
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
    PhonemeCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"letterCell"
                                                      forIndexPath:indexPath];
    
    cell.background.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
    cell.background.layer.cornerRadius = 15;
    cell.lbText.text = _collectionViewData[indexPath.row];
    
    return cell;
}

@end
