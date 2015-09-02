//
//  ScheduleScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/3/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "ScheduleScene.h"
#import "HomeScene.h"

@implementation ScheduleScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.backgroundColor = [UIColor whiteColor];
    [self setupScene];
    
}

-(void)setupScene {
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"homeBackground"] size:self.frame.size];
    bg.position = CGPointMake(CGRectGetMidX(self.frame),
                              CGRectGetMidY(self.frame));
    bg.alpha = 0.5;
    [self addChild:bg];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    HomeScene *scene = [HomeScene unarchiveFromFile:@"HomeScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    SKTransition* transition = [SKTransition moveInWithDirection:SKTransitionDirectionRight duration:0.5];
    [self.view presentScene:scene transition:transition];
}

-(void)update:(CFTimeInterval)currentTime {

    
}

@end
