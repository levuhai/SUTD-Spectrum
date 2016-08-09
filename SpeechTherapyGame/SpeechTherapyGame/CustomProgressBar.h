//
//  CustomProgressBar.h
//  SpeechTherapyGame
//
//  Created by Vit on 11/4/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CustomProgressBar : SKCropNode
/// Set to a value between 0.0 and 1.0.
- (void) setProgress:(CGFloat) progress;
@end
