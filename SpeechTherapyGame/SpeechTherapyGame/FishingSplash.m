//
//  FishingSplash.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/23/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "FishingSplash.h"
#import "FishingGameScene.h"
#import "AudioPlayer.h"

@implementation FishingSplash

- (void)didMoveToView:(SKView *)view {
    [[AudioPlayer shared] stopBgm];
    SKScene *scene = [FishingGameScene unarchiveFromFile:@"FishingGameScene"];
    SKAction *eff = [SKAction playSoundFileNamed:@"slide.m4a" waitForCompletion:NO];
    SKAction *voice = [SKAction playSoundFileNamed:@"go fishing.mp3" waitForCompletion:YES];
    SKAction* wait = [SKAction waitForDuration:0.75f];
    [self runAction:[SKAction sequence:@[eff, wait, voice, wait, eff]] completion:^{
        
        //scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:[SKTransition moveInWithDirection:SKTransitionDirectionRight duration:1]];
    }];
}

@end
