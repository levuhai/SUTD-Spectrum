//
//  GameManagerDetailViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/21/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "GameManagerDetailViewController.h"
#import "GameStatsViewController.h"
#import "SoundManagerViewController.h"

@interface GameManagerDetailViewController ()
{
    GameStatsViewController* _gameStatsViewController;
    SoundManagerViewController* _gameSoundViewController;
}
@end

@implementation GameManagerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGB(47,139,193);
    
    _gameStatsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameStatsViewController"];
    [self addChildViewController:_gameStatsViewController];
    [self.view addSubview:_gameStatsViewController.view];
    [_gameStatsViewController didMoveToParentViewController:self];
    
    _gameSoundViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SoundManagerViewController"];
    [self addChildViewController:_gameSoundViewController];
    [self.view addSubview:_gameSoundViewController.view];
    [_gameSoundViewController didMoveToParentViewController:self];
    
    [self showGameStatsViewController];
}

- (void) showGameStatsViewController {
    _gameStatsViewController.view.hidden = NO;
    _gameSoundViewController.view.hidden = YES;
}

- (void) showSoundMngViewController {
    _gameStatsViewController.view.hidden = YES;
    _gameSoundViewController.view.hidden = NO;
}

- (void) removeChildViewController {
    if (_gameSoundViewController.parentViewController) {
        [_gameSoundViewController.view removeFromSuperview];
        [_gameSoundViewController removeFromParentViewController];
    }
    
    if (_gameStatsViewController.parentViewController) {
        [_gameStatsViewController.view removeFromSuperview];
        [_gameStatsViewController removeFromParentViewController];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
