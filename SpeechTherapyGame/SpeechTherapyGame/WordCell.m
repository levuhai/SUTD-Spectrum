//
//  WordCell.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/4/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "WordCell.h"
#import "UIFont+ES.h"

@implementation WordCell

- (void)awakeFromNib {
    NSString* checkIcon = @"\uf121";
    NSString* playIcon = @"\uF215";
    [self.btnPlay setTitle:playIcon forState:UIControlStateNormal];
    self.btnPlay.titleLabel.font = [UIFont ioniconsOfSize:30];
    
    [self.btnActive setTitle:checkIcon forState:UIControlStateNormal];
    self.btnActive.titleLabel.font = [UIFont ioniconsOfSize:30];
    
    self.lbSubtext.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
