//
//  Spawner.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/21/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "Spawner.h"
#import "SeaCreature.h"

@implementation Spawner

@synthesize minimumSpawnTime, maximumSpawnTime, creatureLimit;

-(id) initWithCreatureClass:(Class)creatureClass
                    inScene:(SKScene*)scene
{
    self = [super init];
    
    if (self)
    {
        _isActive = false;
        
        minimumSpawnTime = 1.0;
        maximumSpawnTime = 6.0;
        
        _creatureClass = creatureClass;
        _scene = scene;
        
        creatureLimit = 1;
        _creatures = [[NSMutableArray alloc] init];
        _nextCreatureSpawnTime = 3;
    }
    
    return self;
}

- (float)randomBetween:(float)low and:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(CGPoint) pointAtGridX:(int)x andGridY:(int)y {
    
    float positionX = x*kTileWidth;
    float positionY = y*kTileWidth;
    
    return CGPointMake(positionX,positionY);
}

-(void)_spawnCreatureWithDirection:(int)direction
                               atX:(int)x
                              andY:(int)y {
    
    CGPoint newCreaureOrigin = [self pointAtGridX:x
                                         andGridY:y];
    
    SeaCreature* creature = [[_creatureClass alloc] init];
    creature.position = newCreaureOrigin;
    [creature setup];
    
    [_scene addChild:creature];
    [_creatures addObject:creature];
    
    creature.spawner = self;

    if (direction!=0) {
        [creature startSwimmingInDirection:direction];
    }
    
}

-(void) spawnCreaturesContinuously {
    
    if (!_isActive) {
        return;
    }
    
    [_creatures enumerateObjectsUsingBlock:^(id _creature, NSUInteger idx, BOOL *stop) {
        SeaCreature* creature = (SeaCreature*)_creature;
        [creature wrapMovement];
        // TODO checks according to creature species
        //[ocean checkChumLuredFish:creature];
        //[ocean checkChumWillBeEatenByFish:creature];
    }];
    
    double currentTime = CACurrentMediaTime();
    
    if ( currentTime > _nextCreatureSpawnTime) {
    
        NSLog(@"creature count: %lu",(unsigned long)[_creatures count]);
        
        float timeToNextSpawn = [self randomBetween:minimumSpawnTime
                                                and:maximumSpawnTime];
        
        _nextCreatureSpawnTime = currentTime+timeToNextSpawn;
        
        if ([_creatures count]<creatureLimit) {
            int newY = floorf([self randomBetween:5 and:20]);
        
            int type = floorf([self randomBetween:0 and:2]);
            int newX, newDirection;
            if (type == 0) {
                newX = -1;
                newDirection = 2;
            } else {
                newX = _scene.size.width/kTileWidth+1;
                newDirection = 4;
            }
            
            // spawn on left or right side of screen
            [self _spawnCreatureWithDirection:newDirection
                                          atX:newX
                                         andY:newY];
        }
    }
    
}

- (void)removeCreature:(SeaCreature*)creature {
    
    [_creatures removeObject:creature];
    [creature removeFromParent];
    self.creatureLimit -= 1;
    NSLog(@"creature removed: %lu",(unsigned long)[_creatures count]);
}

- (id) getCreatureByContactNode:(SKNode*) node {
    for (id creature in _creatures) {
        if ([node isEqual:creature]) {
            return creature;
        }
    }
    return nil;
}

@end
