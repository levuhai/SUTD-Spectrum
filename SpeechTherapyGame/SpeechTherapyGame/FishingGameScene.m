//
//  FishingGameScene.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/17/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "FishingGameScene.h"
#import "LPCNode.h"
#import "HomeScene.h"
#import "Fisherman.h"
#import "Spawner.h"
#import "SeaTurtle.h"
#import "SpeechCard.h"
#import "Word.h"
#import "DataManager.h"

const uint32_t HOOK_BIT_MASK = 0x1 << 0;
const uint32_t FISH_BIT_MASK = 0x1 << 1;
const uint32_t BOUND_BIT_MASK = 0x1 << 2;

@interface FishingGameScene() <SKPhysicsContactDelegate> {
    BOOL _aCreatureIsHooked;
    Fisherman* _fisherman;
    SpeechCard* _card;
    NSMutableArray* _creatureSpawners;
    LPCNode* _lpcNode;
    NSMutableArray* _randomWords;
    SeaCreature* _caughtCreature;
}

@end

@implementation FishingGameScene

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = [UIColor flatSkyBlueColor];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    [self _setupScene];
    [self _setupSpawner];
}

-(void) willMoveFromView:(SKView *)view
{
    [self.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKNode* child = obj;
        [child removeAllActions];
        [child removeFromParent];
    }];
    
    [self removeAllChildren];
}

#pragma mark - Timer

-(void)update:(CFTimeInterval)currentTime {
    [_creatureSpawners enumerateObjectsUsingBlock:^(id _spawner, NSUInteger idx, BOOL *stop) {
        Spawner* spawner = (Spawner*)_spawner;
        [spawner spawnCreaturesContinuously];
    }];
    
    if (_lpcNode)
        [_lpcNode draw];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:location];
    
    SKAction *push = [NodeUtility buttonPushActionWithSound];
    
    // Button Home clicked
    if ([touchNode.name isEqualToString:@"btnHome"]) {
        [touchNode runAction:push completion:^{
            // Present home scene
            HomeScene *scene = [HomeScene unarchiveFromFile:@"HomeScene"];
            scene.scaleMode = SKSceneScaleModeAspectFill;
            [self.view presentScene:scene];
        }];
    }
    
    if (!_aCreatureIsHooked)
        [_fisherman dropHook];
}

- (void)removeCatchCreature {
    [_caughtCreature.spawner removeCreature:_caughtCreature];
    _aCreatureIsHooked = NO;
    if (_caughtCreature.spawner.creatureLimit == 0) {
        HomeScene *scene = [HomeScene unarchiveFromFile:@"HomeScene"];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_fisherman raiseHook];
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    // TODO: _fisherman checkFishHooked
    
    if (!_aCreatureIsHooked) {
        if (contact.bodyA.categoryBitMask == bitmaskCategoryHook &&
            contact.bodyB.categoryBitMask == bitmaskCategoryCreature) {
            NSLog(@"Gotcha!");
            _randomWords = [[DataManager shared] getRandomWords];
            [_card enlargeWithWord:_randomWords];
            
            for (Spawner* spawner in _creatureSpawners) {
                _caughtCreature = [spawner getCreatureByContactNode:contact.bodyB.node];
                if (_caughtCreature) {
                    _aCreatureIsHooked = YES;
                    [_caughtCreature beingCaughtAnimationByHook:[_fisherman getHook]];
                    break;
                }
            }
        }
    }
}

#pragma mark - Private Method

- (void) _setupScene {
    SKSpriteNode* lpcBg = (SKSpriteNode*)[self childNodeWithName:@"nodeLpcBg"];
    // LPC Graph
    _lpcNode = [LPCNode node];
    _lpcNode.lineWidth = 2;
    _lpcNode.position = CGPointMake(lpcBg.position.x+5, lpcBg.position.y+15);
    _lpcNode.zPosition = lpcBg.zPosition+1;
    [_lpcNode setupWithSize:CGSizeMake(lpcBg.size.width-10, lpcBg.size.height-30)];
    [self addChild:_lpcNode];
    
    // Fisherman
    _fisherman = (Fisherman*)[self childNodeWithName:@"spriteFisherman"];
    [_fisherman setupRod];
    
    // Speech Card
    _card = [[SpeechCard alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(429, 600)];
    _card.startPosition = [_fisherman hookStartPosition];
    _card.endPosition = CGPointMake(80, 50);
    _card.anchorPoint = CGPointMake(0, 0);
    _card.position = [_fisherman hookStartPosition];
    _card.zPosition = zCard;
    
    [self addChild:_card];
}

- (void)_setupSpawner {
    //Turtle Spawner
    Spawner* turtleCreatureSpawner = [[Spawner alloc] initWithCreatureClass:[SeaTurtle class]
                                                                    inScene:self];
    turtleCreatureSpawner.creatureLimit = 3;
    
    _creatureSpawners = [NSMutableArray arrayWithObjects:turtleCreatureSpawner, nil];
    
    [_creatureSpawners enumerateObjectsUsingBlock:^(id _spawner, NSUInteger idx, BOOL *stop) {
        Spawner* spawner = (Spawner*)_spawner;
        spawner.isActive = YES;
    }];
}

@end
