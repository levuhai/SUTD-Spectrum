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
#import "PhonemeCell.h"
#import "WordCell.h"
#import "DataManager.h"
#import "Word.h"
#import "ActiveWord.h"

@interface ParentSoundController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _wordData;
    NSMutableDictionary* _groupedWordData;
    NSArray* _sortedWordGroup;
    
    IBOutlet UITableView* mainTable;
}

// Audio Controller
@property (nonatomic, strong) AEAudioController* audioController;
@property (nonatomic, strong) AEAudioFilePlayer *player;

@end

@implementation ParentSoundController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Database
    _wordData = [[DataManager shared] getWordLevel];
    
    // Group data
    _groupedWordData = [NSMutableDictionary dictionary];
    
    // Here `customObjects` is an `NSArray` of your custom objects from the XML
    for (Word * object in _wordData) {
        NSMutableArray * theMutableArray = [_groupedWordData objectForKey:object.pText];
        if ( theMutableArray == nil ) {
            theMutableArray = [NSMutableArray array];
            [_groupedWordData setObject:theMutableArray forKey:object.pText];
        }
        
        [theMutableArray addObject:object];
    }
    
    /* `sortedCountries` is an instance variable */
    _sortedWordGroup = [[_groupedWordData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
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
    
    // Amazing audio
//    self.audioController = [[AEAudioController alloc] initWithAudioDescription:AEAudioStreamBasicDescriptionNonInterleavedFloatStereo inputEnabled:YES];
//    _audioController.preferredBufferDuration = 0.005;
//    _audioController.useMeasurementMode = YES;
//    [_audioController start:NULL];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    cell.lbText.text = w.wText;
    
    // Subtext
    cell.lbSubtext.text = w.pText;
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
    NSString * countryName = [_sortedWordGroup objectAtIndex:indexPath.section];
    NSArray * objectsForCountry = [_groupedWordData objectForKey:countryName];
    Word * w = [objectsForCountry objectAtIndex:indexPath.row];
    
    
}

@end
