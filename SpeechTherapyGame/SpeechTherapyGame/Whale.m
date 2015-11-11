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
        self.anchorPoint = CGPointMake(0.5, 0.5);
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:-10 duration:0.5], [SKAction moveByX:0 y:10 duration:0.5]]]]];
    }
    return self;
}

@end
