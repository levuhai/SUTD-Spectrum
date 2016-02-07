//
//  ParentMasterVC.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 11/2/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ParentMasterController.h"
#import <Masonry/Masonry.h>

@interface ParentMasterController () {
    UIViewController* _currentVC;
    NSArray* _viewNames;
    UIButton* _currentButton;
}

@end

@implementation ParentMasterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _viewNames = @[@"GameStatsViewController", @"SoundManagerViewController",@"parentSettings"];
    
    // Init and add stats vc
    [self showStatsViewController:nil];
}

- (IBAction)showStatsViewController:(UIButton*)sender {
    [self displayViewController:0];
}

- (IBAction)showSoundViewController:(UIButton*)sender {
    [self displayViewController:1];
}

- (IBAction)showSettingsViewController:(UIButton*)sender {
    [self displayViewController:2];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)displayViewController:(int)idx {
    NSString* name = _viewNames[idx];
    [UIView animateWithDuration:0.35f animations:^{
        [self.detailView setAlpha:0.0];
        self.detailView.x = self.view.width;
    } completion:^(BOOL finished) {
        [_currentVC.view removeFromSuperview];
        [_currentVC removeFromParentViewController];
        _currentVC = nil;
        
        UIViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:name];
        _currentVC = vc;
        [self addChildViewController:_currentVC];
        
        
        UIView* view = _currentVC.view;
        [self.detailView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.detailView);
        }];
        [_currentVC didMoveToParentViewController:self];
        
        //fade in
        [UIView animateWithDuration:0.35f animations:^{
            self.detailView.x = 150;
            [self.detailView setAlpha:1.0];
        } completion:^(BOOL finished) {
            _currentButton.enabled = YES;
            if (idx == 0) _currentButton = self.btnDashboard;
            else if (idx == 2) _currentButton = self.btnSettings;
            else _currentButton = self.btnSounds;
            _currentButton.enabled = NO;
        }];
    }];
    
}


@end
