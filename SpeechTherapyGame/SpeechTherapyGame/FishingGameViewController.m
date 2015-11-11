//
//  FishingGameViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 10/15/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "FishingGameViewController.h"
#import "FishingGameScene.h"

@interface FishingGameViewController ()
{

}
@end

@implementation FishingGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
//    skView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    FishingGameScene *scene = [[FishingGameScene alloc] initWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.fishingGameVC = self;
    // Present the scene.
    [skView presentScene:scene];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
