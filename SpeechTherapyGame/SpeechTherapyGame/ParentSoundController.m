//
//  SoundManagerViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ParentSoundController.h"
#import <ChameleonFramework/Chameleon.h>
#import "PhonemeCell.h"
#import "DataManager.h"
#import "Word.h"

@interface ParentSoundController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _collectionViewData;
    IBOutlet UITableView* mainTable;
}
@end

@implementation ParentSoundController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[_letterCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"letterCell"];

    // Do any additional setup after loading the view.
    
    _collectionViewData = [[DataManager shared] getUniquePhoneme];
    self.view.backgroundColor = RGB(47,139,193);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource

//static NSString* cellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhonemeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                        forIndexPath:indexPath];
    cell.lbText.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
    cell.lbText.layer.cornerRadius = 15;
    cell.lbText.text = _collectionViewData[indexPath.row];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _collectionViewData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* selectedPhoneme = _collectionViewData[indexPath.row];
    NSLog(@"%@",selectedPhoneme);
    
    NSArray* arr = [[DataManager shared] getWordsFromPhoneme:selectedPhoneme];
    NSLog(@"%@",arr);
}

@end
