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
#import "ActiveWord.h"

@interface ParentSoundController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _collectionViewData;
    NSMutableArray* _wordData;
    NSArray* _allActiveWords;
    
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
    
    _allActiveWords = [ActiveWord MR_findAll];

}

- (IBAction) activateAll_buttonClicked{
    
    for (Word* word in _wordData) {
        
        NSArray* activeWordArr = [ActiveWord MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(word == %@) AND (phoneme == %@)",word.wText, word.pText]];
        if (activeWordArr.count == 0) {
            ActiveWord* activeWord = [ActiveWord MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
            activeWord.word = word.wText;
            activeWord.phoneme = word.pText;
            activeWord.fileName = word.wFile;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSaveMagicalRecordContext object:nil];
    _allActiveWords = [ActiveWord MR_findAll];
    [subTable reloadData];
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
        Word* word = _wordData[indexPath.row];
        cell.lbText.text = word.wText;
        if ([self isWordActive:word]) {
            cell.lbText.textColor = [UIColor redColor];
        } else {
            cell.lbText.textColor = [UIColor lightGrayColor];
        }
        
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
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
}

#pragma mark - Context menu


- (BOOL) isWordActive:(Word*) word {
    for (ActiveWord* activeWord in _allActiveWords) {
        if ([word.wText isEqualToString:activeWord.word] &&
            [word.pText isEqualToString:activeWord.phoneme]) {
            return YES;
        }
    }
    
    return NO;
}

@end
