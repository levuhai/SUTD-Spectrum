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
    }
    return self;
}

@end
