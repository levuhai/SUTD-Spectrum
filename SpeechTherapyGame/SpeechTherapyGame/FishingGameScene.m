//
//  FishingGameScene.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/17/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "FishingGameScene.h"
#import "UIColor+Chameleon.h"

const uint32_t HOOK_BIT_MASK = 0x1 << 0;
const uint32_t FISH_BIT_MASK = 0x1 << 1;
const uint32_t BOUND_BIT_MASK = 0x1 << 2;

#define HookStartPosition 480

@interface FishingGameScene() {
    SKSpriteNode* _rod;
    SKSpriteNode* _hook;
    SKSpriteNode* _hookLine;
}

@end

@implementation FishingGameScene

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = [UIColor flatSkyBlueColor];
    
    [self _setupScene];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _dropHook];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self _raiseHook];
}

#pragma mark - Private Method
- (void) _setupScene {
    // Build scene physics
    SKNode *edge = [SKNode new];
    edge.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [self addChild:edge];
    
    // Rod
    _rod = (SKSpriteNode*)[self childNodeWithName:@"rod"];
    
    // Hook    
    _hook = [SKSpriteNode spriteNodeWithImageNamed:@"hook"];
    _hook.position = CGPointMake(_rod.position.x, HookStartPosition);
    _hook.anchorPoint = CGPointMake(0.8, 0.0);
    [self addChild:_hook];
    
    SKPhysicsBody *hookPhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
    hookPhysicsBody.categoryBitMask = HOOK_BIT_MASK;
    hookPhysicsBody.collisionBitMask = 0;
    hookPhysicsBody.contactTestBitMask = FISH_BIT_MASK;
    hookPhysicsBody.usesPreciseCollisionDetection = YES;
    hookPhysicsBody.dynamic = NO;
    _hook.physicsBody = hookPhysicsBody;
    
    // Rope Line
    CGSize lineSize = CGSizeMake(1,(_rod.position.y) - (_hook.position.y + _hook.size.height) + 10);
    _hookLine = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:lineSize];
    _hookLine.anchorPoint = CGPointMake(0.5, 1.0);
    _hookLine.position = CGPointMake(_rod.position.x, _rod.position.y);
    [self addChild:_hookLine];
}

- (void)_dropHook {
    [_hook removeActionForKey:@"hook"];
    [_hookLine removeActionForKey:@"hookline"];
    CGFloat hookMovementDeltaY = 1;
    SKAction *hookGoingDownOnceAction = [SKAction moveByX:0
                                                        y:-hookMovementDeltaY
                                                 duration:1.0/(float)120.0f];
    SKAction *hookGoingDownAction = [SKAction repeatActionForever:hookGoingDownOnceAction];
    [_hook runAction:hookGoingDownAction withKey:@"hook"];
    
    SKAction *hookLineOnceAction = [SKAction resizeByWidth:0
                                                    height:hookMovementDeltaY
                                                  duration:1.0/(float)120.0f];
    SKAction *hookLineAction = [SKAction repeatActionForever:hookLineOnceAction];
    [_hookLine runAction:hookLineAction withKey:@"hookline"];
}

- (void)_raiseHook {
    [_hook removeActionForKey:@"hook"];
    [_hookLine removeActionForKey:@"hookline"];
    if (_hook.position.y > HookStartPosition) {
        return;
    }
    CGFloat hookMovementDeltaY = 1.0f;
    SKAction *hookGoingUpOnceAction = [SKAction moveByX:0
                                                      y:hookMovementDeltaY
                                               duration:1/120.0f];
    int count = ceilf((HookStartPosition - _hook.position.y)/hookMovementDeltaY);
    
    SKAction *hookGoingUpAction = [SKAction repeatAction:hookGoingUpOnceAction count:(int)count];
    [_hook runAction:hookGoingUpAction withKey:@"hook"];
    SKAction *hookLineOnceAction = [SKAction resizeByWidth:0
                                                    height:-hookMovementDeltaY
                                                  duration:1/120.0f];
    SKAction *hookLineAction = [SKAction repeatAction:hookLineOnceAction count:(int)count];
    [_hookLine runAction:hookLineAction withKey:@"hookline"];
}


@end
