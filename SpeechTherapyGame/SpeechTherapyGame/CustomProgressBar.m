//
//  CustomProgressBar.m
//  SpeechTherapyGame
//
//  Created by Vit on 11/4/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "CustomProgressBar.h"

@implementation CustomProgressBar
- (id)init {
    if (self = [super init]) {
        self.maskNode = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake(300,20)];
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"fish-pot"];
        [self addChild:sprite];
    }
    return self;
}

- (void) setProgress:(CGFloat) progress {
    [self.maskNode runAction:[SKAction scaleXTo:progress duration:0.5]];
}
@end
