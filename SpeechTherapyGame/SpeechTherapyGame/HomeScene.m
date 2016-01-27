//
//  GameScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 8/31/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

@import AVFoundation;
#import "HomeScene.h"
#import "HomeSceneViewController.h"
#import "FishingGameScene.h"

@interface HomeScene ()
{
    BOOL _isSoundOn;
    BOOL _isBgmOn;
    SKSpriteNode *_btnSound;
    SKSpriteNode *_btnBgm;
}

@property (strong, nonatomic) AVAudioPlayer *musicPlayer;

@end

#define starButtonName  @"StarButton"

@implementation HomeScene

-(void)didMoveToView:(SKView *)view {
    
    
    // BGM
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bgm" ofType:@"m4a"];
    NSURL *musicFile = [[NSURL alloc] initFileURLWithPath:path];
    NSError *error = nil;
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile  error:&error];
    _musicPlayer.numberOfLoops = -1; // negative value repeats indefinitely
    [_musicPlayer prepareToPlay];
    
    // Buttons
    _btnSound = (SKSpriteNode*)[self childNodeWithName:@"btnSound"];
    [self _soundOn:[NSStandardUserDefaults boolForKey:kKeySound]];
    
    _btnBgm = (SKSpriteNode*)[self childNodeWithName:@"btnBgm"];
    [self _bgmOn:[NSStandardUserDefaults boolForKey:kKeyBgm]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:location];
    
    SKAction *pushDown = [SKAction scaleTo:0.85 duration:0.15];
    SKAction *click = [SKAction playSoundFileNamed:@"click.wav" waitForCompletion:YES];
    SKAction *pushUp = [SKAction scaleTo:1.0 duration:0.1];
    
    SKAction *clickAndUp;
    if (_isSoundOn) {
        clickAndUp = [SKAction group:@[click, pushUp]];
    } else {
        clickAndUp = [SKAction group:@[pushUp]];
    }
    SKAction *push = [SKAction sequence:@[pushDown, clickAndUp]];
    
    if ([touchNode.name isEqualToString:@"btnSound"]) {
        [touchNode runAction:push completion:^{
            [self _soundOn:!_isSoundOn];
        }];
    }
    else if ([touchNode.name isEqualToString:@"btnBgm"]) {
        [touchNode runAction:push completion:^{
            [self _bgmOn:!_isBgmOn];
        }];
    } else if ([touchNode.name isEqualToString:@"btnParentsMode"]) {
        [touchNode runAction:push completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowParentsMode
                                                                object:self
                                                              userInfo:nil];
        }];
    } else if ([touchNode.name isEqualToString:@"btnStar"]) {
        [touchNode runAction:push completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowSchedule
                                                                object:self
                                                              userInfo:nil];
        }];
    }
    else {
        SKScene *scene = [FishingGameScene unarchiveFromFile:@"FishingGameScene"];
        //scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene];
    }
}

#pragma mark - Private
- (void)_soundOn:(BOOL)boo {
    _isSoundOn = boo;
    [NSStandardUserDefaults setBool:boo forKey:kKeySound];
    
    if (boo) {
        _btnSound.texture = [SKTexture textureWithImageNamed:@"btnSoundOn"];
    } else {
        
        _btnSound.texture = [SKTexture textureWithImageNamed:@"btnSoundOff"];
    }
}

- (void)_bgmOn:(BOOL)boo {
    _isBgmOn = boo;
    [NSStandardUserDefaults setBool:boo forKey:kKeyBgm];
    
    if (boo) {
        [_musicPlayer play];
        _btnBgm.texture = [SKTexture textureWithImageNamed:@"btnBgmOn"];
    } else {
        [_musicPlayer stop];
        _btnBgm.texture = [SKTexture textureWithImageNamed:@"btnBgmOff"];
    }
}

@end
