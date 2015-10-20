//
//  ManagerGateViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 10/16/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ManagerGateViewController.h"
#import "GameManagerMasterView.h"

@interface ManagerGateViewController ()
{
    NSTimer* _timer;
}
@end

@implementation ManagerGateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton* targetedButton = (UIButton*)[[self.view viewWithTag:10] viewWithTag:6];
    [targetedButton addTarget:self action:@selector(targetButton_pressed) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction) targetButton_pressed {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(progress) userInfo:nil repeats:YES];
}

- (IBAction) targetButton_released {
    [_timer invalidate];
    _timer = nil;
    [_progressBar setValue:0 animateWithDuration:0.1];

}

- (void) progress {
    [_progressBar setValue:_progressBar.value+1 animateWithDuration:0.1];
    if (_progressBar.value == 100) {
        [_container dismissAnimated:NO completionHandler:^(UIViewController * _Nonnull presentedFSViewController) {
            [_homeSceneVC showGameManager];
        }];
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
