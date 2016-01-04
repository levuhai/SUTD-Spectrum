//
//  ParentMasterVC.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 11/2/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ParentMasterController.h"
#import "ParentStatsController.h"
#import "ParentSoundController.h"
#import <Masonry/Masonry.h>

@interface ParentMasterController () {
    ParentStatsController* _statsViewController;
    ParentSoundController* _soundViewController;
    UIView* _statsView;
    UIView* _soundView;
}

@end

@implementation ParentMasterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init and add stats vc
    _statsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameStatsViewController"];
    [self addChildViewController:_statsViewController];
    _statsView = _statsViewController.view;
    [self.detailView addSubview:_statsView];
    [_statsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.detailView);
    }];
    [_statsViewController didMoveToParentViewController:self];
    
    // Init and add sound vc
    _soundViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SoundManagerViewController"];
    [self addChildViewController:_soundViewController];
    _soundView = _soundViewController.view;
    [self.detailView addSubview:_soundView];
    [_soundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.detailView);
    }];
    [_soundViewController didMoveToParentViewController:self];
    
    // Show stats by default
    [self showStatsViewController:nil];
}

- (IBAction)showStatsViewController:(id)sender {
    _statsView.hidden = NO;
    _soundView.hidden = YES;
}

- (IBAction)showSoundViewController:(id)sender {
    _statsView.hidden = YES;
    _soundView.hidden = NO;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
