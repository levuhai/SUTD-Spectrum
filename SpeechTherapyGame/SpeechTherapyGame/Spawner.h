//
//  Spawner.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/21/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SeaCreature;

@interface Spawner : NSObject {
    
    SKScene* _scene;
    
    Class _creatureClass;
    
    double _nextCreatureSpawnTime;
    NSMutableArray* _creatures;
}

@property float minimumSpawnTime;
@property float maximumSpawnTime;
@property int creatureLimit;
@property BOOL isActive;


-(id) initWithCreatureClass:(Class)creatureClass
                    inScene:(SKScene*)scene;
-(void) spawnCreaturesContinuously;
-(void) removeCreature:(SeaCreature*)creature;

@end
