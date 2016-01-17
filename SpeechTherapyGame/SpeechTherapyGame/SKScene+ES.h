//
//  SKScene+ES.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/17/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKScene (ES)

+ (instancetype)unarchiveFromFile:(NSString *)file;

@end
