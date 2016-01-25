//
//  SeaCreature.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/21/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class Spawner;

@interface SeaCreature : SKNode {
    
    int movementDirection;
    float movementSpeed;
    float rotation;
    float deltaX;
    float deltaY;
    
    int movementWrapLimit; //how many times creature will wrap screen before disappearing
    

    float weight;
    
    float sizeRatio;

    SKSpriteNode* bodyNode;
    SKShapeNode* facingDirection;
    
    Spawner* spawner;
}
@property (weak,readwrite) Spawner* spawner;
//@property (nonatomic, weak) SKScene* scene;
@property (atomic,retain) SKSpriteNode* bodyNode;
@property (assign,readwrite) float movementSpeed;
@property (assign,readwrite) float weight;

-(void) startSwimmingInDirection: (int)_movementDirection;
-(void) setup;
-(void) wrapMovement;

@end
