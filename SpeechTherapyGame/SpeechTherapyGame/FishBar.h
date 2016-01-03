//
//  FishBar.h
//  SpeechTherapyGame
//
//  Created by Vit on 1/2/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface FishBar : SKSpriteNode
- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size;
- (void) setFish:(int) index active:(BOOL) active;
@end
