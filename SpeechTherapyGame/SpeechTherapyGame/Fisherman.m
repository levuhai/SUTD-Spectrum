//
//  Fisherman.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/21/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "Fisherman.h"

#define cReelUp @"reelUp"
#define cReelDown @"reelDown"

@implementation Fisherman {
    SKSpriteNode* _rod;
    SKSpriteNode* _hook;
    SKSpriteNode* _hookLine;
    float _y;
}

-(SKSpriteNode*) getHook {
    return _hook;
}

- (void)dropHook {
    [_hook removeActionForKey:@"hook"];
    [_hookLine removeAllActions];
    float delta = hookMovementDeltaY;
    int count = ceilf((_hook.position.y - 50)/hookMovementDeltaY);
    
    SKAction *hookGoingDownOnceAction = [SKAction moveByX:0
                                                        y:-delta
                                                 duration:1.0/hookDropSpeed];
    SKAction *hookGoingDownAction = [SKAction repeatAction:hookGoingDownOnceAction count:count];
    [_hook runAction:hookGoingDownAction withKey:@"hook"];
    
    SKAction *hookLineOnceAction = [SKAction resizeByWidth:0
                                                    height:delta
                                                  duration:1.0/hookDropSpeed];
    SKAction *hookLineAction = [SKAction repeatAction:hookLineOnceAction count:count];
    [_hookLine runAction:hookLineAction withKey:@"hookline"];
    //[self _animateReelDown];
}

- (void)raiseHook {
    [_hook removeActionForKey:@"hook"];
    [_hookLine removeAllActions];
    if (_hook.position.y > yHookStart) {
        return;
    }
    SKAction *hookGoingUpOnceAction = [SKAction moveByX:0
                                                      y:hookMovementDeltaY
                                               duration:1/hookRaiseSpeed];
    int count = ceilf((yHookStart - _hook.position.y)/hookMovementDeltaY);
    
    SKAction *hookGoingUpAction = [SKAction repeatAction:hookGoingUpOnceAction count:(int)count];
    [_hook runAction:hookGoingUpAction withKey:@"hook"];
    SKAction *hookLineOnceAction = [SKAction resizeByWidth:0
                                                    height:-hookMovementDeltaY
                                                  duration:1/hookRaiseSpeed];
    SKAction *hookLineAction = [SKAction repeatAction:hookLineOnceAction count:(int)count];
    [_hookLine runAction:hookLineAction completion:^{
        [self removeAllActions];
    }];
    //[self _animateReelUp];
}

- (CGPoint)hookStartPosition {
    CGPoint rodPos = [self convertPoint:_rod.position toNode:self.scene];
    return CGPointMake(rodPos.x, yHookStart);
}

- (void)setupRod {
    _rod = (SKSpriteNode*)[self childNodeWithName:@"rod"];
    _y = _rod.position.y;
    
    // Hook
    CGPoint rodPos = [self convertPoint:_rod.position toNode:self.scene];
    
    _hook = [SKSpriteNode spriteNodeWithImageNamed:@"hook"];
    _hook.position = CGPointMake(rodPos.x, yHookStart);
    _hook.anchorPoint = CGPointMake(0.8, 0.0);
    [self.scene addChild:_hook];
    
    SKPhysicsBody *hookPhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
    hookPhysicsBody.categoryBitMask = bitmaskCategoryHook;
    hookPhysicsBody.collisionBitMask = bitmaskCategoryNeutral;
    hookPhysicsBody.contactTestBitMask = bitmaskCategoryCreature;
    hookPhysicsBody.usesPreciseCollisionDetection = YES;
    hookPhysicsBody.dynamic = NO;
    _hook.physicsBody = hookPhysicsBody;
    
    // Rope Line
    CGSize lineSize = CGSizeMake(1,rodPos.y - (_hook.position.y + _hook.size.height) + 10);
    _hookLine = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:lineSize];
    _hookLine.anchorPoint = CGPointMake(0.5, 1.0);
    _hookLine.position = CGPointMake(rodPos.x, rodPos.y);
    [self.scene addChild:_hookLine];
}

- (void)_animateReelUp
{
    [self removeActionForKey:cReelDown];
    if ([self actionForKey:cReelUp])
        return;
    
    SKTextureAtlas *finishReelingAtlas = [SKTextureAtlas atlasNamed:@"fisherman"];
    
    NSArray *finishReelingFrames = @[[finishReelingAtlas textureNamed:@"charTurtlenBoat5"],
                                     [finishReelingAtlas textureNamed:@"charTurtlenBoat4"],
                                     [finishReelingAtlas textureNamed:@"charTurtlenBoat3"],
                                     [finishReelingAtlas textureNamed:@"charTurtlenBoat2"],
                                     [finishReelingAtlas textureNamed:@"charTurtlenBoat1"]];
    
    
    [self runAction:[SKAction repeatActionForever:
                           [SKAction animateWithTextures:finishReelingFrames
                                            timePerFrame:0.1f
                                                  resize:NO
                                                 restore:NO]] withKey:cReelDown];
    //return;
}


- (void)_animateReelDown
{
    [self removeActionForKey:cReelUp];
    if ([self actionForKey:cReelDown])
        return;
    
    SKTextureAtlas *startReelingAtlas = [SKTextureAtlas atlasNamed:@"fisherman"];
    
    NSArray *startReelingFrames = @[[startReelingAtlas textureNamed:@"charTurtlenBoat1"],
                                    [startReelingAtlas textureNamed:@"charTurtlenBoat2"],
                                    [startReelingAtlas textureNamed:@"charTurtlenBoat3"],
                                    [startReelingAtlas textureNamed:@"charTurtlenBoat4"],
                                    [startReelingAtlas textureNamed:@"charTurtlenBoat5"]];
    
    [self runAction:[SKAction repeatActionForever:
                           [SKAction animateWithTextures:startReelingFrames
                                            timePerFrame:0.1f
                                                  resize:NO
                                                 restore:NO]] withKey:cReelDown];
    //return;
}

@end
