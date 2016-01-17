//
//  FishingGameScene.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/17/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "FishingGameScene.h"
#import "UIColor+Chameleon.h"

@implementation FishingGameScene

- (void)didMoveToView:(SKView *)view {
    // Emitter
    self.backgroundColor = [UIColor flatSkyBlueColor];
}

#pragma mark - Private Method
- (void)_addEmitterWithFileNamed:(NSString *)fileName
                      atPosition:(CGPoint)position {
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"sks"]];
    emitter.position = position;
    [self addChild:emitter];
    
}

@end
