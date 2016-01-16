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
    NSMutableArray* _phonemeData;
    
    IBOutlet UITableView* mainTable;
    IBOutlet UITableView* subTable;
    
    IBOutlet UILabel* lbCurrentPhoneme;
    IBOutlet UIButton* btnActive;
}

// Audio Controller
@property (nonatomic, strong) AEAudioController* audioController;
@property (nonatomic, strong) AEAudioFilePlayer *player;

@end

@implementation ParentSoundController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[_letterCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"letterCell"];

    // Do any additional setup after loading the view.
    
    _wordData = [[DataManager shared] getWordLevel];
    
    self.view.backgroundColor = [UIColor clearColor];
    
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
    
    Word* w = _wordData[indexPath.row];
    
    // Text
    cell.lbText.text = w.wText;
    
    // Subtext
    cell.lbSubtext.text = w.pText;
    cell.lbSubtext.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight];
    cell.lbSubtext.layer.cornerRadius = 15;
    
    // Selected Background
    UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
    myBackView.backgroundColor = cell.lbText.backgroundColor;
    cell.selectedBackgroundView = myBackView;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _wordData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Word* w = _wordData[indexPath.row];
}

@end
