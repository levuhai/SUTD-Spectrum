//
//  MFCCAudioController.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/1/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Word;

@interface MFCCAudioController : NSObject

+ (float)scoreFileA:(NSString*)pathA fileB:(Word*)pathB;

@end
