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
    HomeScene *scene = [HomeScene unarchiveFromFile:@"HomeScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.homeSceneViewController = self;
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{

    return UIInterfaceOrientationMaskAll;
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

- (void)showScheduleScene {
    ScheduleViewController* svc = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduleViewController"];
    [self presentViewController:svc animated:YES completion:nil];
}

@end
