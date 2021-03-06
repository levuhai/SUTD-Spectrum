//
//  AudioPlayer.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/14/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AEAudioController;

@interface AudioPlayer : NSObject

@property (nonatomic, assign) float soundVolume;
@property (nonatomic, assign) float musicVolume;
@property (nonatomic, strong) AEAudioController* aAEController;


/**
 * gets singleton object.
 * @return singleton
 */
+ (AudioPlayer*)shared;

- (void)playSoundInDocument:(NSString*)path;
- (void)stopSound;
- (void)playSoundInDocument:(NSString *)path delegate:(id)del;
- (void)playBgm;
- (void)stopBgm;

- (void)playSfx;

@end
