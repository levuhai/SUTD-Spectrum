//
//  AudioPlayer.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/14/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioPlayer : NSObject

@property (nonatomic, assign) float soundVolume;
@property (nonatomic, assign) float musicVolume;


/**
 * gets singleton object.
 * @return singleton
 */
+ (AudioPlayer*)shared;

- (void)playSoundInDocument:(NSString*)path;
- (void)playBgm;
- (void)playSfx;

@end
