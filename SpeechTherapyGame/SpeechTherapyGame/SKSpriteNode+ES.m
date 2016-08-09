//
//  SKSpriteNode+ES.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/15/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "SKSpriteNode+ES.h"

@implementation SKSpriteNode (ES)

- (void)aspectFillToWidth:(float)w {
    if (self.texture != nil) {
        CGSize textureSize = self.texture.size;
        
        float horizontalRatio = w / textureSize.width;
        
        [self setScale:horizontalRatio];
    }
}

@end
