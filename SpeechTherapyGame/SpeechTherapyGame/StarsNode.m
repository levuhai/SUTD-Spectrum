//
//  StarsNode.m
//  SpeechTherapyGame
//
//  Created by Vit on 12/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "StarsNode.h"

@interface StarsNode ()
{
    SKSpriteNode* _container;
}
@end

@implementation StarsNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size {
    self = [super initWithColor:color size:size];
    if (self) {
        _container = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:size];
        
        for (int i = 0; i < 3; i++) {
            SKTexture* starTex = [SKTexture textureWithImageNamed:@"star-inactive"];
            SKSpriteNode* star = [[SKSpriteNode alloc] initWithTexture:starTex color:[UIColor clearColor] size:CGSizeMake(_container.size.width/4, _container.size.width/4)];
            star.position = CGPointMake(_container.size.width*i/3 - star.size.width*1.3, 0);
            star.name = [NSString stringWithFormat:@"star%d",i];
            [_container addChild:star];
            
            if (i == 1) {
                star.xScale = 1.2;
                star.yScale = 1.2;
            } else {
                star.xScale = 0.8;
                star.yScale = 0.8;
            }
        }
        [self addChild:_container];
    }
    return self;
}

- (void) setStar:(int) index active:(BOOL) active {
    for (SKSpriteNode* node in _container.children) {
        if ([node.name rangeOfString:[NSString stringWithFormat:@"%d",index]].location != NSNotFound) {
            SKTexture* tex = [SKTexture textureWithImageNamed:@"star-inactive"];
            if (active) {
                tex = [SKTexture textureWithImageNamed:@"star-active"];
            }
            node.texture = tex;
        }
    }
}

@end
