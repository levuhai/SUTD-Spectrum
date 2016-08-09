//
//  GameScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 8/31/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

@import AVFoundation;
#import "HomeScene.h"
#import "HomeSceneViewController.h"
#import "FishingGameScene.h"
#import "FishingSplash.h"

@interface HomeScene ()
{

}

@end

#define starButtonName  @"StarButton"

@implementation HomeScene

-(void)didMoveToView:(SKView *)view {
    [[AudioPlayer shared] playBgm];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:location];
    
    SKAction *push = [NodeUtility buttonPushActionWithSound];
    
    if ([touchNode.name isEqualToString:@"btnParentsMode"]) {
        [touchNode runAction:push completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowParentsMode
                                                                object:self
                                                              userInfo:nil];
        }];
    } else if ([touchNode.name isEqualToString:@"btnStar"]) {
        [touchNode runAction:push completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowSchedule
                                                                object:self
                                                              userInfo:nil];
        }];
    }
    else {
        SKScene *scene = [FishingSplash unarchiveFromFile:@"FishingSplash"];
        //scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition:[SKTransition moveInWithDirection:SKTransitionDirectionRight duration:1]];
    }
}

@end
