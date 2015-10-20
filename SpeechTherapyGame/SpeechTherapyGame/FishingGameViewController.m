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
    
    _countDownCircleContainer.alpha = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void) shouldShowCountDown:(BOOL) value {
    [UIView animateWithDuration:0.3 animations:^{
        
        _countDownCircleContainer.y = value ? _countDownCircleContainer.y - 20 : _countDownCircleContainer.y + 20;
        
        _countDownCircleContainer.alpha = value ? 1 : 0;
    } completion:^(BOOL finished) {
        if (!value)
            [self updateProgressValue:100 duration:0];
    }];
}

- (void) updateProgressValue: (GLfloat) value duration:(GLfloat) duration {
    if (duration == 0)
        [_countDownCircleView setValue:value];
    else
        [_countDownCircleView setValue:value animateWithDuration:duration];
}

@end
