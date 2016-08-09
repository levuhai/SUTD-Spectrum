//
//  Fisherman.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/21/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Fisherman : SKSpriteNode

- (SKSpriteNode*) getHook;
- (void)setupRod;
- (CGPoint)hookStartPosition;
- (void)raiseHook;
- (void)dropHook;

@end
