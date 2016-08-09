//
//  PhonemeCell.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/4/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "DetailsCell.h"
#import "AudioPlayer.h"

@interface DetailsCell () <AVAudioPlayerDelegate>

@end

@implementation DetailsCell

- (IBAction)playSound:(id)sender {
    [self setSelected:YES animated:YES];
    
    [[AudioPlayer shared] playSoundInDocument:self.filePath delegate:self];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self setSelected:NO animated:YES];
}

@end
