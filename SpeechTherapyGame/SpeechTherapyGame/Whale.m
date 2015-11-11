//
//  Whale.m
//  SpeechTherapyGame
//
//  Created by Vit on 11/10/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "Whale.h"

@implementation Whale

- (id)init {
    if (self = [super init]) {
        self = [[Whale alloc] initWithTexture:[SKTexture textureWithImageNamed:@"whale"]];
        self.name = @"Whale";
        
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width/2];
        self.physicsBody.affectedByGravity = YES;
        self.physicsBody.dynamic = YES;
        //self.physicsBody.categoryBitMask = ballCategory;
        //self.physicsBody.collisionBitMask = barCategory | wallCategory;
        //self.physicsBody.contactTestBitMask = barCategory | wallCategory;
        //self.physicsBody.usesPreciseCollisionDetection = YES;
        
        self.physicsBody.friction = 0.0;
        self.physicsBody.restitution = 1.0f;
        self.physicsBody.angularDamping = 0.0f;
        self.physicsBody.linearDamping = 0.0f;
        self.anchorPoint = CGPointMake(0.5, 0.5);
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:-10 duration:0.5], [SKAction moveByX:0 y:10 duration:0.5]]]]];
    }
    return self;
}

@end
