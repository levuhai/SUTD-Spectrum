//
//  SpeechCard.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/27/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "SpeechCard.h"
#import "Chameleon.h"

@implementation SpeechCard

- (id)initWithColor:(UIColor *)color size:(CGSize)size {
    self = [super initWithColor:[UIColor clearColor] size:size];
    if (self) {
        self.texture = [SKTexture textureWithImageNamed:@"imgCardBg"];
        SKAction* scaleDown = [SKAction scaleTo:0.0 duration:0.0];
        [self runAction:scaleDown];
        _enlarged = NO;
    }
    return self;
}

#pragma mark - Public
- (void)enlarge {
    if (_enlarged) {
        [self removeAllActions];
        SKAction* slide = [SKAction moveTo:self.startPosition duration:0.3];
        SKAction* scaleDown = [SKAction scaleTo:0.0 duration:0.3];
        [self runAction:[SKAction group:@[slide, scaleDown]] completion:^{
            _enlarged = NO;
            [self setHidden:YES];
        }];
    } else {
        [self removeAllActions];
        _enlarged = YES;
        [self setHidden:NO];
        
        SKAction* slide = [SKAction moveTo:self.endPosition duration:0.3];
        SKAction* scaleUp = [SKAction scaleTo:1.0 duration:0.3];
        [self runAction:[SKAction group:@[slide, scaleUp]]];
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

@end
