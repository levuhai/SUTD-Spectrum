//
//  GameViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 8/31/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "HomeSceneViewController.h"
#import "HomeScene.h"
#import "ScheduleViewController.h"
#import "GameManagerMasterView.h"
#import "FishingGameViewController.h"
#import "ParentSecurityController.h"
#import "MZFormSheetController.h"
#import "ParentMasterController.h"
#import "SKScene+ES.h"

@implementation HomeSceneViewController {
    BOOL _showingParent;
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_showParentsSecurity)
                                                 name:kNotificationShowParentsMode
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_showSchedule)
                                                 name:kNotificationShowSchedule
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _showingParent = NO;
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    //skView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    HomeScene *scene = [HomeScene unarchiveFromFile:@"HomeScene"];
    scene.scaleMode = SKSceneScaleModeResizeFill;
//  scene.parentController = self;
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action methods

- (void)_showSchedule {
    ScheduleViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduleViewController"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    float padding = 120;
    formSheet.presentedFormSheetSize = CGSizeMake(self.view.width-padding, self.view.height-padding);
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.cornerRadius = 0.0;
    vc.container = formSheet;
    vc.homeSceneVC = self;
    formSheet.didDismissCompletionHandler = ^(UIViewController *vc){};
    
    [self mz_presentFormSheetController:formSheet
                               animated:YES
                      completionHandler:nil];
}

- (void)_showParentsSecurity {
    if (_showingParent == YES) {
        return;
    }
    _showingParent = YES;
    ParentSecurityController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SecurityController"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.presentedFormSheetSize = CGSizeMake(550, 630);
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.cornerRadius = 70.0;
    vc.container = formSheet;
    vc.homeSceneVC = self;
    formSheet.didDismissCompletionHandler = ^(UIViewController *vc){
        _showingParent = NO;
    };
    
    [self mz_presentFormSheetController:formSheet
                               animated:YES
                      completionHandler:nil];
}

- (void)showParentsMode {
    ParentMasterController* gmm = [self.storyboard instantiateViewControllerWithIdentifier:@"ParentMasterController"];
    [self presentViewController:gmm animated:YES completion:nil];
}

@end
