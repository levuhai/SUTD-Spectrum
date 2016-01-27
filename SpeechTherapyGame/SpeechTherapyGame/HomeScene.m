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
    BOOL _isSoundOn;
    BOOL _isBgmOn;
}

@end

#define starButtonName  @"StarButton"

@implementation HomeScene

-(void)didMoveToView:(SKView *)view {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:location];
    
    SKAction *pushDown = [SKAction scaleTo:0.85 duration:0.2];
    SKAction *click = [SKAction playSoundFileNamed:@"click.wav" waitForCompletion:YES];
    SKAction *pushUp = [SKAction scaleTo:1.0 duration:0.1];
    
    SKAction *clickAndUp = [SKAction group:@[click, pushUp]];
    SKAction *push = [SKAction sequence:@[pushDown, clickAndUp]];
    
    if ([touchNode.name isEqualToString:@"btnSound"]) {
        [touchNode runAction:push completion:^{
            //((SKSpriteNode*)touchNode).texture = [SKTexture textureWithImageNamed:@""];
        }];
    }
    else if ([touchNode.name isEqualToString:@"btnBgm"]) {
        [touchNode runAction:push completion:^{
            
        }];
    } else if ([touchNode.name isEqualToString:@"btnParentsMode"]) {
        [touchNode runAction:push completion:^{
            
        }];
    } else if ([touchNode.name isEqualToString:@"btnStar"]) {
        [touchNode runAction:push completion:^{
            
        }];
    }
    else {
        SKScene *scene = [FishingGameScene unarchiveFromFile:@"FishingGameScene"];
        //scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene];
    }
}

@end
