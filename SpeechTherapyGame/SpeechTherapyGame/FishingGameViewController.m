//
//  FishingGameViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 10/15/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "FishingGameViewController.h"
#import "FishingGameScene.h"
#import <AVFoundation/AVFoundation.h>

@interface FishingGameViewController ()
{
    FishingGameScene *_gameScene;
}
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation FishingGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    skView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    _gameScene = [FishingGameScene unarchiveFromFile:@"FishingGameScene"];
    _gameScene.scaleMode = SKSceneScaleModeAspectFill;
    //_gameScene.fishingGameVC = self;
    // Present the scene.
    [skView presentScene:_gameScene];
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/sand_castles.m4a", [[NSBundle mainBundle] resourcePath]]];
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops = -1;
    [self.audioPlayer play];
}

- (void)dealloc {
    SKView * skView = (SKView *)self.view;
    [skView presentScene:nil];
    [_gameScene removeFromParent];
    _gameScene = nil;
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (IBAction) homeBtn_clicked {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kSaveMagicalRecordContext object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
