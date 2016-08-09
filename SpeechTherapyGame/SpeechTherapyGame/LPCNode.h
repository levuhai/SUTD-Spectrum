//
//  LPCNode.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/28/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LPCNode : SKShapeNode

@property (nonatomic, assign) CGSize size;

- (void)draw;
- (void)setupWithSize:(CGSize)size;

@end
