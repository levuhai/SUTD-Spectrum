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
    
    _viewNames = @[@"GameStatsViewController", @"SoundManagerViewController"];
    
    // Init and add stats vc
    [self showStatsViewController:nil];
}

- (IBAction)showStatsViewController:(UIButton*)sender {
    [self displayViewController:_viewNames[0]];
    _currentButton.enabled = YES;
    _currentButton = self.btnDashboard;
    _currentButton.enabled = NO;
}

- (IBAction)showSoundViewController:(UIButton*)sender {
    [self displayViewController:_viewNames[1]];
    _currentButton.enabled = YES;
    _currentButton = self.btnSounds;
    _currentButton.enabled = NO;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)displayViewController:(NSString*)name {
    

    [UIView animateWithDuration:0.25f animations:^{
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
        
        //fade out
        [UIView animateWithDuration:0.25f animations:^{
            
            [self.detailView setAlpha:1.0];
            self.detailView.x = 150;
            
        } completion:nil];
    }];
    
}


@end
