//
//  LoadingScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/7/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "LoadingScene.h"
#import "LoadingViewController.h"
@implementation LoadingScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.backgroundColor = [UIColor whiteColor];
    SKLabelNode* loading = [SKLabelNode labelNodeWithText:@"Loading..."];
    loading.fontColor = [UIColor darkGrayColor];
    loading.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:loading];
    
}

@end
