//
//  StarsNode.h
//  SpeechTherapyGame
//
//  Created by Vit on 12/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface StarsNode : SKSpriteNode

- (instancetype)initWithColor:(UIColor *)color size:(CGSize)size;

- (void) setStar:(int) index active:(BOOL) active;

@end
