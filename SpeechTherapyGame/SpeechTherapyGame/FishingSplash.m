//
//  FishingSplash.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/23/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "FishingSplash.h"
#import "FishingGameScene.h"

@implementation FishingSplash

- (void)didMoveToView:(SKView *)view {
    SKAction *eff = [SKAction playSoundFileNamed:@"slide.m4a" waitForCompletion:NO];
    SKAction *voice = [SKAction playSoundFileNamed:@"go fishing.mp3" waitForCompletion:YES];
    SKAction* wait = [SKAction waitForDuration:0.5f];
    [self runAction:[SKAction sequence:@[eff, wait, voice, wait, eff]] completion:^{
        SKScene *scene = [FishingGameScene unarchiveFromFile:@"FishingGameScene"];
        //scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:[SKTransition moveInWithDirection:SKTransitionDirectionRight duration:1]];
    }];
}

@end
