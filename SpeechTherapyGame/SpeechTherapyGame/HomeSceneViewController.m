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



@implementation HomeSceneViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
//    skView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    HomeScene *scene = [[HomeScene alloc] initWithSize:self.view.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.homeSceneViewController = self;
    // Present the scene.
    [skView presentScene:scene];
    
    UIButton* gameButton = (UIButton*)[self.view viewWithTag:1];
    gameButton.layer.cornerRadius = 30;
    gameButton.layer.borderWidth = 8;
    gameButton.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark - Action methods

- (IBAction)showScheduleScene {
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

-(IBAction) managerButton_pressed {
    
    
    // Show menu
    ParentSecurityController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SecurityController"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheet.presentedFormSheetSize = CGSizeMake(550, 630);
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.cornerRadius = 70.0;
    vc.container = formSheet;
    vc.homeSceneVC = self;
    formSheet.didDismissCompletionHandler = ^(UIViewController *vc){};
    
    [self mz_presentFormSheetController:formSheet
                               animated:YES
                      completionHandler:nil];
}

- (void) showGameManager {
    ParentMasterController* gmm = [self.storyboard instantiateViewControllerWithIdentifier:@"ParentMasterController"];
    [self presentViewController:gmm animated:YES completion:nil];
}

- (IBAction) fishingGamebuton_pressed {
    GameManagerMasterView* fishingGame = [self.storyboard instantiateViewControllerWithIdentifier:@"FishingGameViewController"];
    [self presentViewController:fishingGame animated:YES completion:nil];
}
@end
