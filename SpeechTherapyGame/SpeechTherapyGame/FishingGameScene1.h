//
//  FishingGameScene.h
//  SpeechTherapyGame
//
//  Created by Vit on 10/15/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@class FishingGameViewController;

@interface FishingGameScene : SKScene

@property (nonatomic, weak) FishingGameViewController* fishingGameVC;
- (void) shouldShowThoughtBox:(BOOL) value with:(SKSpriteNode*) tb1 :(SKSpriteNode*) tb2 :(SKSpriteNode*) tb3 :(SKSpriteNode*) tb4 :(SKSpriteNode*) afish completion:(void (^)())block;

@end
