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
#import "WordCell.h"
#import "DataManager.h"
#import "Word.h"

@interface ParentSoundController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _collectionViewData;
    NSMutableArray* _wordData;
    IBOutlet UITableView* mainTable;
    IBOutlet UITableView* subTable;
}
@end

@implementation ParentSoundController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[_letterCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"letterCell"];

    // Do any additional setup after loading the view.
    
    _collectionViewData = [[DataManager shared] getUniquePhoneme];
    _wordData = [NSMutableArray new];
    
    self.view.backgroundColor = RGB(47,139,193);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource

//static NSString* cellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == mainTable) {
        PhonemeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
        cell.lbText.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
        cell.lbText.layer.cornerRadius = 15;
        cell.lbText.text = _collectionViewData[indexPath.row];
        return cell;
    } else {
        WordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SubCell"
                                                            forIndexPath:indexPath];
        cell.lbText.text = ((Word*)_wordData[indexPath.row]).wText;
        return cell;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == mainTable) {
        return _collectionViewData.count;
    } else {
        return _wordData.count;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == mainTable) {
        NSString* selectedPhoneme = _collectionViewData[indexPath.row];
        NSLog(@"%@",selectedPhoneme);
        
        _wordData = [[DataManager shared] getUniqueWordsFromPhoneme:selectedPhoneme];
        [subTable reloadData];
    }
}

@end
