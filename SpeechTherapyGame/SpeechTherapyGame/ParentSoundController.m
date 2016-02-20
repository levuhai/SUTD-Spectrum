//
//  SoundManagerViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ParentSoundController.h"
#import <ChameleonFramework/Chameleon.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "WordCell.h"
#import "DataManager.h"
#import "AudioPlayer.h"
#import "Word.h"
#import "ActiveWord.h"

@interface ParentSoundController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _wordData;
    NSMutableDictionary* _groupedWordData;
    NSArray* _sortedWordGroup;
    Word *_selectedWord;
    IBOutlet UITableView* mainTable;
}

// Audio Controller
@property (nonatomic, strong) AEAudioController* audioController;
@property (nonatomic, strong) AEAudioFilePlayer *player;

@end

@implementation ParentSoundController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // UI
    self.view.backgroundColor = [UIColor clearColor];
    self.leftContainer.backgroundColor = [UIColor whiteColor];
    self.leftContainer.layer.borderColor = [UIColor flatSkyBlueColorDark].CGColor;
    self.leftContainer.layer.borderWidth = 5;
    self.leftContainer.layer.cornerRadius = 30;
    
    self.rightContainer.backgroundColor = [UIColor whiteColor];
    self.rightContainer.layer.borderColor = [UIColor flatSkyBlueColorDark].CGColor;
    self.rightContainer.layer.borderWidth = 5;
    self.rightContainer.layer.cornerRadius = 30;
    
    self.btWordLv.selected = [[DataManager shared] practisingWordLv];
    self.btnSyllableLv.selected = [[DataManager shared] practisingSyllableLv];
    
    // reload db
    [self _reloadDatabase];
}

- (void)_reloadDatabase {
    // Database
    _wordData = [[DataManager shared] getWords];
    
    // Group data
    _groupedWordData = [NSMutableDictionary dictionary];
    
    // Here `customObjects` is an `NSArray` of your custom objects from the XML
    for (Word * object in _wordData) {
        NSMutableArray * theMutableArray = [_groupedWordData objectForKey:object.phoneme];
        if ( theMutableArray == nil ) {
            theMutableArray = [NSMutableArray array];
            [_groupedWordData setObject:theMutableArray forKey:object.phoneme];
        }
        
        [theMutableArray addObject:object];
    }
    
    /* `sortedCountries` is an instance variable */
    _sortedWordGroup = [[_groupedWordData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    // reload table
    [self.tableView reloadData];
    
    if (_wordData.count > 0) {
        NSIndexPath* index = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.tableView selectRowAtIndexPath:index animated:YES scrollPosition:(UITableViewScrollPositionTop)];
        [self tableView:self.tableView didSelectRowAtIndexPath:index];
    }
}

#pragma mark - UITableView Datasource

//static NSString* cellIdentifier = @"Cell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                     forIndexPath:indexPath];
    
    NSString * countryName = [_sortedWordGroup objectAtIndex:indexPath.section];
    NSArray * objectsForCountry = [_groupedWordData objectForKey:countryName];
    Word * w = [objectsForCountry objectAtIndex:indexPath.row];
    
    // Text
    cell.lbText.text = w.sound;
    
    // Subtext
    cell.lbSubtext.text = w.phonetic;
    cell.lbSubtext.backgroundColor = [UIColor clearColor];
    cell.lbSubtext.layer.borderWidth = 2;
    cell.lbSubtext.layer.borderColor = [UIColor flatOrangeColor].CGColor;
    cell.lbSubtext.layer.cornerRadius = 15;
    cell.lbSubtext.clipsToBounds = YES;
    
    // Selected Background
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = [[UIColor flatLimeColor] colorWithAlphaComponent:0.4];
    cell.selectedBackgroundView = myBackView;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sortedWordGroup.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_groupedWordData objectForKey:[_sortedWordGroup objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _sortedWordGroup[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 50)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    // Color
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 50)];
    [headerView setBackgroundColor:[[UIColor flatWatermelonColor] colorWithAlphaComponent:0.4f]];
    
    
    // Text
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, tableView.width-30, 50)];
    label.text = _sortedWordGroup[section];
    label.textColor = [UIColor flatRedColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"Arial-BoldItalicMT" size:25];
    [headerView addSubview:label];
    
    [bgView addSubview:headerView];
    return bgView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * phonemeGroup = [_sortedWordGroup objectAtIndex:indexPath.section];
    NSArray * sounds = [_groupedWordData objectForKey:phonemeGroup];
    Word * w = [sounds objectAtIndex:indexPath.row];
    self.lbSoundPreview.text = w.sound;
    self.lbPhoneticPreview.text = [NSString stringWithFormat:@"/%@/",w.phonetic];
    
    self.imgPreview.image = [UIImage imageNamed:w.imgFilePath];
    _selectedWord = w;
}
- (IBAction)wordTouched:(id)sender {
    self.btWordLv.selected = !self.btWordLv.selected;
    [[DataManager shared] setPractisingWordLv:self.btWordLv.selected];
    [self _reloadDatabase];
}
- (IBAction)syllableToched:(id)sender {
    self.btnSyllableLv.selected = !self.btnSyllableLv.selected;
    [[DataManager shared] setPractisingSyllableLv:self.btnSyllableLv.selected];
    [self _reloadDatabase];
}
- (IBAction)playSoundTouched:(id)sender {
    [[AudioPlayer shared] playSoundInDocument:[_selectedWord sampleFilePath]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
