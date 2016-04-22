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
#import "SeaFish.h"
#import "SpeechCard.h"
#import "Word.h"
#import "DataManager.h"
#import "AudioPlayer.h"
#import "NSMutableArray+Shuffle.h"

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
    SKSpriteNode* _lpcBg;
    BOOL _lpcHidden;
    int _currentIndex;
}

@end

@implementation FishingGameScene

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = [UIColor flatSkyBlueColor];
    
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;

    _lpcHidden = NO;
    
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
    
    if (_lpcNode && !_lpcHidden)
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
    } else if ([touchNode.name isEqualToString:@"nodeLpcBg"] || touchNode == _lpcNode) {
         _lpcHidden = !_lpcHidden;
        
    } else if (!_aCreatureIsHooked)
        [_fisherman dropHook];
}

- (void)removeCatchCreature {
    _currentIndex ++;
    [_caughtCreature.spawner removeCreature:_caughtCreature];
    _aCreatureIsHooked = NO;
    
    // Check all creatures removed
    __block BOOL removed = YES;
    [_creatureSpawners enumerateObjectsUsingBlock:^(id _spawner, NSUInteger idx, BOOL *stop) {
        Spawner* spawner = (Spawner*)_spawner;
        if (spawner.creatureLimit != 0) {
            removed = NO;
            *stop = YES;
        }
        spawner.isActive = YES;
    }];
    
    if (removed) {
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
            Word* w = _randomWords[_currentIndex];
            [_card enlargeWithWord:[[DataManager shared] getWordGroup:w.sound]];
            
            for (Spawner* spawner in _creatureSpawners) {
                _caughtCreature = [spawner getCreatureByContactNode:contact.bodyB.node];
                if (_caughtCreature) {
                    _aCreatureIsHooked = YES;
                    [_caughtCreature beingCaughtAnimationByHook:[_fisherman getHook]];
                    spawner.isActive = NO;
                    break;
                }
            }
        }
    }
}

#pragma mark - Private Method

- (void) _setupScene {
//    _lpcBg = (SKSpriteNode*)[self childNodeWithName:@"nodeLpcBg"];
//    _lpcBg.zPosition = zCard+1;
    // LPC Graph
    _lpcNode = [LPCNode node];
    _lpcNode.lineWidth = 2;
    _lpcNode.position = CGPointMake((self.view.width-521)*0.5, (self.view.height-660)*0.5);
    _lpcNode.zPosition = zCard+2;
    [_lpcNode setupWithSize:CGSizeMake(521, 160)];
    [self addChild:_lpcNode];
    
    // Fisherman
    _fisherman = (Fisherman*)[self childNodeWithName:@"spriteFisherman"];
    [_fisherman setupRod];
    
    // Speech Card
    _card = [[SpeechCard alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(561, 700)];
    _card.startPosition = [_fisherman hookStartPosition];
    _card.endPosition = CGPointMake((self.view.width-561)*0.5, (self.view.height-700)*0.5);
    _card.anchorPoint = CGPointMake(0, 0);
    _card.position = [_fisherman hookStartPosition];
    _card.zPosition = zCard;
    
    // background
    _lpcBg = (SKSpriteNode*)[self childNodeWithName:@"nodeLpcBg"];
    CGPoint p = _lpcBg.position;
    p.y = _card.endPosition.y;
    _lpcBg.position = p;
    
    [self addChild:_card];
}

- (void)_setupSpawner {
    _currentIndex = 0;
    // Random words
    _randomWords = [[DataManager shared] getWords];
    [_randomWords shuffle];
    
    //Turtle Spawner
    Spawner* turtleCreatureSpawner = [[Spawner alloc] initWithCreatureClass:[SeaTurtle class]
                                                                    inScene:self];
    turtleCreatureSpawner.creatureLimit = 4;
    if (_randomWords.count < 4) {
        turtleCreatureSpawner.creatureLimit = (int)_randomWords.count;
    }
    
    
//    Spawner* fishCreatureSpawner = [[Spawner alloc] initWithCreatureClass:[SeaFish class]
//                                                                    inScene:self];
//    fishCreatureSpawner.creatureLimit = 4;
    
    _creatureSpawners = [NSMutableArray arrayWithObjects:turtleCreatureSpawner,nil];
    
    [_creatureSpawners enumerateObjectsUsingBlock:^(id _spawner, NSUInteger idx, BOOL *stop) {
        Spawner* spawner = (Spawner*)_spawner;
        spawner.isActive = YES;
    }];
}

@end
