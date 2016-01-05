//
//  WordCell.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/4/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "WordCell.h"
#import "Word.h"
#import "UIFont+ES.h"
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

@interface WordCell ()

@end

@implementation WordCell

- (void)awakeFromNib {
    NSString* checkIcon = @"\uf121";
    NSString* playIcon = @"\uF215";
    NSString* stopIcon = @"\uf24f";
    [self.btnPlay setTitle:playIcon forState:UIControlStateNormal];
    [self.btnPlay setTitle:stopIcon forState:UIControlStateSelected];
    self.btnPlay.titleLabel.font = [UIFont ioniconsOfSize:30];
    
    [self.btnActive setTitle:checkIcon forState:UIControlStateNormal];
    self.btnActive.titleLabel.font = [UIFont ioniconsOfSize:30];
    
    self.lbSubtext.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)playClicked {
    if ( _player ) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
        self.btnPlay.selected = NO;
    }
    
    NSString* path = [[NSBundle mainBundle] pathForResource:[self.word.wFile stringByDeletingPathExtension] ofType:@"wav" inDirectory:@"sounds"];
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) return;
    
    NSError *error = nil;
    self.player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:path]
                                                      error:&error];
    
    if ( !_player ) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    
    
    _player.removeUponFinish = YES;
    _player.completionBlock = ^{
        [_audioController removeChannels:@[_player]];
        self.btnPlay.selected = NO;
        _player = nil;
    };
    [_audioController addChannels:@[_player]];
    _btnPlay.selected = YES;
    
}

@end
