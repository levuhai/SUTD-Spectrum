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
    
    // Text
    SKSpriteNode* speechtherapytext = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"speechtherapy-text"] size:CGSizeMake(480, 97)];
    speechtherapytext.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
    [self addChild:speechtherapytext];
    
    
    SKSpriteNode* star = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"star"] size:CGSizeMake(47, 46)];
    star.position = CGPointMake(80, 80);
    star.name = starButtonName;
    [self addChild:star];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([self handleButtonTouches:touches]) return;
}

-(BOOL) handleButtonTouches:(NSSet *)touches {
    BOOL didTouchButton = NO;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:starButtonName]) {
        didTouchButton = YES;
        [_homeSceneViewController showScheduleScene];
    }
    
    
    return didTouchButton;
}

-(void)update:(CFTimeInterval)currentTime {
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
    
}

@end
