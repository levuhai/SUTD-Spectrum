//
//  FishBar.m
//  SpeechTherapyGame
//
//  Created by Vit on 1/2/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "FishBar.h"
@interface FishBar ()
{
    SKSpriteNode* _container;
}
@end

@implementation FishBar
- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size {
    self = [super initWithColor:color size:size];
    if (self) {
        _container = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:size];
        
        for (int i = 0; i < 5; i++) {
            SKTexture* fishTex = [SKTexture textureWithImageNamed:@"smallfish"];
            SKSpriteNode* fish = [[SKSpriteNode alloc] initWithTexture:fishTex color:[UIColor clearColor] size:CGSizeMake(36, 23)];
            fish.position = CGPointMake(_container.size.width*i/5 - _container.size.width/2 + fish.size.width/2 + 5, 0);
            fish.name = [NSString stringWithFormat:@"fish%d",i+1];
            
            fish.color = [UIColor darkGrayColor];
            fish.blendMode = SKBlendModeAlpha;
            fish.colorBlendFactor = 1;
            fish.alpha = 0.75;
            
            [_container addChild:fish];
        }
        [self addChild:_container];
    }
    return self;
}

- (void) setFish:(int) index active:(BOOL) active {
    for (SKSpriteNode* node in _container.children) {
        if ([node.name rangeOfString:[NSString stringWithFormat:@"%d",index]].location != NSNotFound) {
            
            [node runAction:[SKAction scaleTo:1.3 duration:0.3] completion:^{
                SKTexture* tex = [SKTexture textureWithImageNamed:@"smallfish"];
                node.texture = tex;
                if (active) {
                    node.color = [UIColor clearColor];
                    node.colorBlendFactor = 0;
                    node.alpha = 1;
                } else {
                    node.color = [UIColor darkGrayColor];
                    node.blendMode = SKBlendModeAlpha;
                    node.colorBlendFactor = 1;
                    node.alpha = 0.75;
                }
                [node runAction:[SKAction scaleTo:1.0 duration:0.3]];
            }];
            break;
        }
    }
}

@end