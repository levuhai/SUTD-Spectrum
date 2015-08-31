//
//  GameScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 8/31/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"homeBackground"] size:self.frame.size];
    bg.position = CGPointMake(CGRectGetMidX(self.frame),
                             CGRectGetMidY(self.frame));
    [self addChild:bg];
    
    SKSpriteNode* owl = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"homeOwl"] size:CGSizeMake(156, 152)];
    owl.position = CGPointMake(CGRectGetMidX(self.frame),
                              CGRectGetMidY(self.frame) - 150);
    [self addChild:owl];
    
    // wind mill
    SKSpriteNode* windmillBody = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"windmill-body"] size:CGSizeMake(71, 115)];
    windmillBody.position = CGPointMake(self.frame.size.width - 85,
                               CGRectGetMidY(self.frame)-65);
    [self addChild:windmillBody];
    
    SKSpriteNode* windmillWings = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"windmill-wings"] size:CGSizeMake(111, 107)];
    windmillWings.position = CGPointMake(windmillBody.position.x,
                                        windmillBody.position.y + 25);
    SKAction *action = [SKAction rotateByAngle:M_PI duration:5];
    [windmillWings runAction:[SKAction repeatActionForever:action]];
    [self addChild:windmillWings];
    SKSpriteNode* windmillFrontGrass = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"windmill-front-grass"] size:CGSizeMake(44, 17)];
    windmillFrontGrass.position = CGPointMake(windmillBody.position.x - 45,
                                         windmillBody.position.y - 55);
    [self addChild:windmillFrontGrass];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.xScale = 0.5;
        sprite.yScale = 0.5;
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
    */
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
