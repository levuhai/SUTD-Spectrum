//
//  FishingGameScene.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/17/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "FishingGameScene.h"
#import "UIColor+Chameleon.h"
#import "Fisherman.h"
#import "Spawner.h"
#import "SeaTurtle.h"

const uint32_t HOOK_BIT_MASK = 0x1 << 0;
const uint32_t FISH_BIT_MASK = 0x1 << 1;
const uint32_t BOUND_BIT_MASK = 0x1 << 2;

@interface FishingGameScene() <SKPhysicsContactDelegate> {
    Fisherman* _fisherman;
    
    NSMutableArray* _creatureSpawners;
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

#pragma mark - Timer

-(void)update:(CFTimeInterval)currentTime {
    [_creatureSpawners enumerateObjectsUsingBlock:^(id _spawner, NSUInteger idx, BOOL *stop) {
        Spawner* spawner = (Spawner*)_spawner;
        [spawner spawnCreaturesContinuously];
    }];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_fisherman dropHook];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_fisherman raiseHook];

}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    NSLog(@"Gotcha!");
    // TODO: _fisherman checkFishHooked
}

#pragma mark - Private Method

- (void) _setupScene {
    // Build scene physics
    
    // Fisherman
    _fisherman = (Fisherman*)[self childNodeWithName:@"spriteFisherman"];
    [_fisherman setupRod];
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
