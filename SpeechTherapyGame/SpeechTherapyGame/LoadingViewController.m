//
//  LoadingViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/7/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "LoadingViewController.h"
#import "LoadingScene.h"

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    //    skView.showsPhysics = YES;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    LoadingScene *scene = [LoadingScene sceneWithSize:self.view.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.loadingViewController = self;
    // Present the scene.
    [skView presentScene:scene];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self didLoadData];
}

- (void) didLoadData {
    [self performSegueWithIdentifier:@"gotoHomeScene" sender:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
