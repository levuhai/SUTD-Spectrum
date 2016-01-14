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
    
    SKSpriteNode* owl = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"owl-body"]];
    owl.position = CGPointMake(CGRectGetMidX(self.frame) - 29,
                               CGRectGetMidY(self.frame) - 215);
    owl.zPosition = 10;
    [self addChild:owl];
    
    
    
    SKSpriteNode* owlLeftWing = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"left-wing"]];
    
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
    SKSpriteNode* speechtherapytext = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"speechtherapy-text"]];
    speechtherapytext.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 20);
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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_homeSceneViewController showFishingGame];
}

-(void)update:(CFTimeInterval)currentTime {

}

@end
