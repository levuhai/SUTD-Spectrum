//
//  GameScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 8/31/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "HomeScene.h"
#import "HomeSceneViewController.h"

@interface HomeScene ()
{
    SKSpriteNode* _cloud1;
    SKSpriteNode* _cloud2;
    SKSpriteNode* _cloud3;
}

@end

#define starButtonName  @"StarButton"

@implementation HomeScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    [self setupHomeScene];
    
}

-(void)setupHomeScene {
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"homeBackground"] size:self.frame.size];
    bg.position = CGPointMake(CGRectGetMidX(self.frame),
                              CGRectGetMidY(self.frame));
    bg.zPosition = -1;
    [self addChild:bg];
    
    SKSpriteNode* owl = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"owl-body"] size:CGSizeMake(117, 152)];
    owl.position = CGPointMake(CGRectGetMidX(self.frame),
                               CGRectGetMidY(self.frame) - 150);
    owl.zPosition = 10;
    [self addChild:owl];
    
    
    
    SKSpriteNode* owlLeftWing = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"left-wing"] size:CGSizeMake(60, 49)];
    
    owlLeftWing.anchorPoint = CGPointMake(1, 0.5);
    SKSpriteNode* wingContainer = [SKSpriteNode node];
    wingContainer.zPosition = 9;
    wingContainer.color = [UIColor clearColor];
    wingContainer.size = CGSizeMake(owlLeftWing.size.width*2, owlLeftWing.size.height);
    wingContainer.position = CGPointMake(owl.position.x + 40, owl.position.y+5);
    
    owlLeftWing.position = CGPointMake(wingContainer.size.width/2, 0);
    [wingContainer addChild:owlLeftWing];
    [self addChild:wingContainer];
    
    SKAction* rotateRight = [SKAction rotateToAngle:0.2 duration:1];
    SKAction* rotateLeft = [SKAction rotateByAngle:-0.5 duration:1];
    SKAction* wingSequence = [SKAction sequence:@[rotateRight, rotateLeft]];
    [wingContainer runAction:[SKAction repeatActionForever:wingSequence]];
    
    // wind mill
    SKSpriteNode* windmillBody = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"windmill-body"] size:CGSizeMake(71, 115)];
    windmillBody.position = CGPointMake(self.frame.size.width - 85,
                                        CGRectGetMidY(self.frame)-65);
    windmillBody.zPosition = 6;
    [self addChild:windmillBody];
    
    SKSpriteNode* windmillWings = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"windmill-wings"] size:CGSizeMake(111, 107)];
    windmillWings.position = CGPointMake(windmillBody.position.x,
                                         windmillBody.position.y + 25);
    SKAction *action = [SKAction rotateByAngle:M_PI duration:20];
    [windmillWings runAction:[SKAction repeatActionForever:action]];
    windmillWings.zPosition = 7;
    [self addChild:windmillWings];
    SKSpriteNode* windmillFrontGrass = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"windmill-front-grass"] size:CGSizeMake(44, 17)];
    windmillFrontGrass.position = CGPointMake(windmillBody.position.x - 45,
                                              windmillBody.position.y - 55);
    windmillFrontGrass.zPosition = 8;
    [self addChild:windmillFrontGrass];
    
    // Clouds
    _cloud1 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"cloud-1"] size:CGSizeMake(125, 55)];
    _cloud1.position = CGPointMake(CGRectGetMidX(self.frame) - 200, CGRectGetMidY(self.frame) + 300);
    [_cloud1 setScale:0.75];
    [self addChild:_cloud1];
    
    _cloud2 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"cloud-1"] size:CGSizeMake(125, 55)];
    _cloud2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
    [self addChild:_cloud2];
    
    
    _cloud3 = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"cloud-2"] size:CGSizeMake(153, 54)];
    _cloud3.position = CGPointMake(self.view.width - 200, CGRectGetMidY(self.frame) + 100);
    [self addChild:_cloud3];
    
    _cloud1.zPosition = _cloud2.zPosition = _cloud3.zPosition = 5;
    
    // Text
    SKSpriteNode* speechtherapytext = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"speechtherapy-text"] size:CGSizeMake(480, 97)];
    speechtherapytext.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
    speechtherapytext.zPosition = 9;
    [self addChild:speechtherapytext];
    
    // Animation for clouds
    
    SKAction* flyToLeft = [SKAction moveToX:-_cloud1.size.width/2 duration:240.0f];
    SKAction* moveToRight = [SKAction runBlock:^{
        _cloud1.position = CGPointMake(self.size.width + _cloud1.size.width/2, _cloud1.position.y);
    }];
    SKAction* cloud1Sequence = [SKAction sequence:@[flyToLeft, moveToRight]];
    [_cloud1 runAction:[SKAction repeatActionForever:cloud1Sequence]];
    
    SKAction* flyToLeft2 = [SKAction moveToX:-_cloud2.size.width/2 duration:120.0f];
    SKAction* moveToRight2 = [SKAction runBlock:^{
        _cloud2.position = CGPointMake(self.size.width + _cloud2.size.width/2, _cloud2.position.y);
    }];
    SKAction* cloud2Sequence = [SKAction sequence:@[flyToLeft2, moveToRight2]];
    [_cloud2 runAction:[SKAction repeatActionForever:cloud2Sequence]];
    
    SKAction* flyToLeft3 = [SKAction moveToX:-_cloud3.size.width/2 duration:60.0f];
    SKAction* moveToRight3 = [SKAction runBlock:^{
        _cloud3.position = CGPointMake(self.size.width + _cloud3.size.width/2, _cloud3.position.y);
    }];
    SKAction* cloud3Sequence = [SKAction sequence:@[flyToLeft3, moveToRight3]];
    [_cloud3 runAction:[SKAction repeatActionForever:cloud3Sequence]];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([self handleButtonTouches:touches]) return;
}

-(BOOL) handleButtonTouches:(NSSet *)touches {
    BOOL didTouchButton = NO;
    return didTouchButton;
}

-(void)update:(CFTimeInterval)currentTime {
    /*
    _cloud1.position = CGPointMake(_cloud1.position.x - 1.5, _cloud1.position.y);
    _cloud2.position = CGPointMake(_cloud2.position.x - 1, _cloud2.position.y);
    _cloud3.position = CGPointMake(_cloud3.position.x - 0.5, _cloud3.position.y);
    
    if (_cloud1.position.x < 0 - _cloud1.size.width/2) {
        _cloud1.position = CGPointMake(self.size.width + _cloud1.size.width/2, _cloud1.position.y);
    }
    if (_cloud2.position.x < 0 - _cloud2.size.width/2) {
        _cloud2.position = CGPointMake(self.size.width + _cloud2.size.width/2, _cloud2.position.y);
    }
    if (_cloud3.position.x < 0 - _cloud3.size.width/2) {
        _cloud3.position = CGPointMake(self.size.width + _cloud3.size.width/2, _cloud3.position.y);
    }
    */
}

@end
