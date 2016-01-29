//
//  NodeUtility.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/28/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "NodeUtility.h"

@implementation NodeUtility

+ (SKAction *)buttonPushAction {
    SKAction *pushDown = [SKAction scaleTo:0.85 duration:0.15];
    //SKAction *click = [SKAction playSoundFileNamed:@"click.wav" waitForCompletion:YES];
    SKAction *pushUp = [SKAction scaleTo:1.0 duration:0.1];
    
    SKAction *clickAndUp;
    clickAndUp = [SKAction group:@[pushUp]];
    
    return [SKAction sequence:@[pushDown, clickAndUp]];
}

+ (SKAction *)buttonPushActionWithSound {
    SKAction *pushDown = [SKAction scaleTo:0.85 duration:0.15];
    SKAction *click = [SKAction playSoundFileNamed:@"click.wav" waitForCompletion:YES];
    SKAction *pushUp = [SKAction scaleTo:1.0 duration:0.1];
    
    SKAction *clickAndUp;
    if ([NSStandardUserDefaults boolForKey:kKeySound]) {
        clickAndUp = [SKAction group:@[click, pushUp]];
    } else {
        clickAndUp = [SKAction group:@[pushUp]];
    }
    return [SKAction sequence:@[pushDown, clickAndUp]];
}

@end
