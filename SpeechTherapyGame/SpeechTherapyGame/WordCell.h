//
//  WordCell.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/4/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AEAudioController;
@class AEAudioFilePlayer;
@class Word;


@interface WordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* lbText;
@property (weak, nonatomic) IBOutlet UILabel* lbSubtext;
@property (weak, nonatomic) IBOutlet UIButton* btnPlay;
@property (weak, nonatomic) IBOutlet UIButton* btnActive;

@property (nonatomic, weak) AEAudioController* audioController;
@property (nonatomic, weak) AEAudioFilePlayer *player;
@property (nonatomic, weak) Word *word;

@end
