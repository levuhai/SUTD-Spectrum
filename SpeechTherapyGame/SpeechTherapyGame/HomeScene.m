//
//  GameScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 8/31/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "HomeScene.h"
#import "HomeSceneViewController.h"
#import "FishingGameScene.h"

@interface HomeScene ()
{
    SKSpriteNode* _cloud1;
    SKSpriteNode* _cloud2;
    SKSpriteNode* _cloud3;
}

@end

#define starButtonName  @"StarButton"

@implementation HomeScene

-(void)didMoveToView:(SKView *)view {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SKScene *scene = [FishingGameScene unarchiveFromFile:@"FishingGameScene"];
    //scene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:scene];
}

@end
