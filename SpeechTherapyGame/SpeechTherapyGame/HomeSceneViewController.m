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
#import "ManagerGateViewController.h"
#import "MZFormSheetController.h"



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
    ScheduleViewController* svc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduleViewController"];
    [self presentViewController:svc animated:YES completion:nil];
}

-(IBAction) managerButton_pressed {
    
    
    // Show menu
    ManagerGateViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ManagerGateViewController"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
    formSheet.presentedFormSheetSize = CGSizeMake(460, 280);
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    formSheet.shouldCenterVertically = YES;
    formSheet.cornerRadius = 8.0;
    vc.container = formSheet;
    vc.homeSceneVC = self;
    formSheet.didDismissCompletionHandler = ^(UIViewController *vc){};
    
    [self mz_presentFormSheetController:formSheet
                               animated:YES
                      completionHandler:nil];
}

- (void) showGameManager {
    GameManagerMasterView* gmm = [self.storyboard instantiateViewControllerWithIdentifier:@"GameManagerMasterView"];
    [self presentViewController:gmm animated:YES completion:nil];
}

- (IBAction) fishingGamebuton_pressed {
    GameManagerMasterView* fishingGame = [self.storyboard instantiateViewControllerWithIdentifier:@"FishingGameViewController"];
    [self presentViewController:fishingGame animated:YES completion:nil];
}
@end
