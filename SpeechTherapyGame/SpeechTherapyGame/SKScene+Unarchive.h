//
//  SKScene+Unarchive.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/3/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file;

@end
