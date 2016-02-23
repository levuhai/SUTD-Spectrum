//
//  SFXPlayer.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/14/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "AudioPlayer.h"
#import "TheAmazingAudioEngine.h"

@interface AudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer* bgmPlayer;
@property (nonatomic, strong) AVAudioPlayer* sfxPlayer;
@property (nonatomic, strong) AVAudioPlayer* soundPlayer;

@end

@implementation AudioPlayer

static AudioPlayer *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone
{
    return [self shared];
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return [self shared];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone
{
    return [self shared];
}

- (id)copy
{
    return [[AudioPlayer alloc] init];
}

- (id)mutableCopy
{
    return [[AudioPlayer alloc] init];
}

AudioStreamBasicDescription AEAudioStreamBasicDescriptionMono = {
    .mFormatID          = kAudioFormatLinearPCM,
    .mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
    .mChannelsPerFrame  = 1,
    .mBytesPerPacket    = sizeof(float),
    .mFramesPerPacket   = 1,
    .mBytesPerFrame     = sizeof(float),
    .mBitsPerChannel    = 8 * sizeof(float),
    .mSampleRate        = 44100.0,
};

- (id) init
{
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    
    // BGM
    NSError *error;
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"bgm" withExtension:@"mp3"];
    self.bgmPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    self.bgmPlayer.numberOfLoops = -1;
    [self.bgmPlayer setVolume:self.musicVolume];
    [self.bgmPlayer prepareToPlay];
    
    // SFX
    NSURL *soundfx = [[NSBundle mainBundle] URLForResource:@"click" withExtension:@"m4a"];
    self.sfxPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundfx error:&error];
    [self.sfxPlayer setVolume:self.soundVolume];
    [self.sfxPlayer prepareToPlay];
    
    // AE Controlelr
    self.aAEController = [[AEAudioController alloc] initWithAudioDescription:AEAudioStreamBasicDescriptionMono inputEnabled:YES];
    self.aAEController.preferredBufferDuration = 0.005;
    self.aAEController.useMeasurementMode = YES;
    [self.aAEController start:nil];
    
    return self;
}

#pragma mark - Public
- (void)playBgm {
    if (self.musicVolume == 0) {
        [self.bgmPlayer stop];
    } else {
        if (!self.bgmPlayer.playing) {
            [self.bgmPlayer play];
        }
    }
}

- (void)stopBgm {
    [self.bgmPlayer pause];
}

- (void)playSfx {
    if (self.soundVolume == 0) {
        [self.sfxPlayer stop];
    } else {
        [self.sfxPlayer stop];
        [self.sfxPlayer setCurrentTime:0];
        [self.sfxPlayer play];
    }
}

- (void)playSoundInDocument:(NSString *)path {
    self.soundPlayer = nil;
    NSError *error;
    NSURL *url = [NSURL URLWithString:path];
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"%@",error.description);
    }
    [self.soundPlayer prepareToPlay];
    [self.soundPlayer play];
}

- (void)playSoundInDocument:(NSString *)path delegate:(id)del {
    self.soundPlayer.delegate = nil;
    self.soundPlayer = nil;
    NSError *error;
    NSURL *url = [NSURL URLWithString:path];
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.soundPlayer.delegate = del;
    if (error) {
        NSLog(@"%@",error.description);
    }
    [self.soundPlayer prepareToPlay];
    [self.soundPlayer play];
}

//
// Sound Volume
- (void)setSoundVolume:(float)soundVolume {
    [NSStandardUserDefaults setFloat:soundVolume forKey:kKeySoundVol];
    self.sfxPlayer.volume = soundVolume;
    [self playSfx];
}
- (float)soundVolume {
    if (![NSStandardUserDefaults hasValueForKey:kKeySoundVol]) {
        return 0.6f;
    } else {
        return [NSStandardUserDefaults floatForKey:kKeySoundVol];
    }
}
//
// Music Volume
- (void)setMusicVolume:(float)musicVolume {
    [NSStandardUserDefaults setFloat:musicVolume forKey:kKeyMusicVol];
    self.bgmPlayer.volume = musicVolume;
    [self playBgm];
}
- (float)musicVolume {
    if (![NSStandardUserDefaults hasValueForKey:kKeyMusicVol]) {
        return 0.6f;
    } else {
        return [NSStandardUserDefaults floatForKey:kKeyMusicVol];
    }
}


@end
