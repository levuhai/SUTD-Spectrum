//
//  SpeechCard.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/27/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

@import AVFoundation;
#import "SpeechCard.h"
#import "Chameleon.h"
#import "NSMutableArray+Queue.h"
#import "Word.h"
#import "MFCCAudioController.h"
#import "TheAmazingAudioEngine.h"
#import "AERecorder.h"
#define kBufferLength 90

@interface SpeechCard()

@property (strong, nonatomic) NSTimer *meterTimer;
@property (nonatomic, strong) AEAudioController* audioController;
@property (nonatomic, strong) AERecorder *recorder;
@property (nonatomic, strong) AEAudioFilePlayer *player;

@end

@implementation SpeechCard {
    SKLabelNode* _lbWord;
    SKLabelNode* _lbDesc;
    int _currentStarIdx;
    SKSpriteNode* _spriteSpeaker;
    SKSpriteNode* _spriteMic;
    SKSpriteNode* _spriteSquid;
    SKShapeNode* _spriteVolume;
    Word *_word;
    SKSpriteNode* _spriteStar1;
    SKSpriteNode* _spriteStar2;
    SKSpriteNode* _spriteStar3;
    
    NSMutableArray* _silenceArray;
    NSMutableArray* _words;
    BOOL _soundDetected;
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

- (id)initWithColor:(UIColor *)color size:(CGSize)size {
    self = [super initWithColor:[UIColor clearColor] size:size];
    if (self) {
        self.userInteractionEnabled = YES;
        
        _silenceArray = [[NSMutableArray alloc] initWithMaxItem:kBufferLength];
        _soundDetected = NO;
        _currentStarIdx = 1;
        
        // Set texture bg
        self.texture = [SKTexture textureWithImageNamed:@"imgCardBg"];
        
        // Scale down to 0 by default
        SKAction* scaleDown = [SKAction scaleTo:0.0 duration:0.0];
        [self runAction:scaleDown];
        _enlarged = NO;
        
        // Add lb text
        _lbWord = [SKLabelNode labelNodeWithFontNamed:@"Arial-BoldItalic"];
        _lbWord.fontSize = 40;
        _lbWord.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _lbWord.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _lbWord.fontColor = [UIColor whiteColor];
        _lbWord.position = CGPointMake(self.size.width/2, self.size.height-40);
        _lbWord.text = @"";
        _lbWord.zPosition = self.zPosition+1;
        [self addChild:_lbWord];
        
        // Add lb desc
        _lbDesc = [SKLabelNode labelNodeWithFontNamed:@"Debussy"];
        _lbDesc.fontSize = 16;
        _lbDesc.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _lbDesc.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _lbDesc.fontColor = [UIColor colorWithHexString:@"847C7C"];
        _lbDesc.position = CGPointMake(self.size.width/2, self.size.height-105);
        _lbDesc.text = @"Tap on picture to hear sample sound";
        _lbDesc.zPosition = self.zPosition+1;
        [self addChild:_lbDesc];
        
        // Add Speaker
//        _spriteSpeaker = [SKSpriteNode spriteNodeWithImageNamed:@"btnSpeaker1"];
//        _spriteSpeaker.anchorPoint = CGPointMake(0.5, 0.5);
//        _spriteSpeaker.position = CGPointMake(self.size.width - 55.0, 220);
//        _spriteSpeaker.zPosition = self.zPosition+1;
//        [self addChild:_spriteSpeaker];
        
        // Add squid
        _spriteSquid = [SKSpriteNode spriteNodeWithImageNamed:@"charSquid"];
        _spriteSquid.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteSquid.position = CGPointMake(self.size.width/2-10, self.size.height/2+45);
        _spriteSquid.zPosition = self.zPosition+1;
        [self addChild:_spriteSquid];
        
        // Star 1
        _spriteStar1 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar1.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar1.position = CGPointMake(self.size.width/2-70, 50);
        _spriteStar1.zPosition = self.zPosition+1;
        _spriteStar1.name = @"star1";
        [self addChild:_spriteStar1];
        
        _spriteStar2 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar2.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar2.position = CGPointMake(self.size.width/2, 40);
        _spriteStar2.zPosition = self.zPosition+1;
        _spriteStar2.name = @"star2";
        [self addChild:_spriteStar2];
        
        _spriteStar3 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar3.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar3.position = CGPointMake(self.size.width/2+70, 50);
        _spriteStar3.zPosition = self.zPosition+1;
        _spriteStar3.name = @"star3";
        [self addChild:_spriteStar3];
        
        // Add mic
        _spriteMic = [SKSpriteNode spriteNodeWithImageNamed:@"btnMicOff"];
        _spriteMic.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteMic.position = CGPointMake(self.size.width/2, 115);
        _spriteMic.zPosition = self.zPosition+2;
        [self addChild:_spriteMic];
        
        // Add vol meter
        _spriteVolume = [SKShapeNode shapeNodeWithCircleOfRadius:_spriteMic.size.height/2];
        _spriteVolume.position = _spriteMic.position;
        _spriteVolume.fillColor = [[SKColor flatWhiteColor] colorWithAlphaComponent:0.3];
        _spriteVolume.lineWidth = 0;
        _spriteVolume.antialiased = YES;
        _spriteVolume.zPosition = self.zPosition+1;
        [self addChild:_spriteVolume];
        
        // Audio Session
        self.audioController = [[AEAudioController alloc] initWithAudioDescription:AEAudioStreamBasicDescriptionMono inputEnabled:YES];
        _audioController.preferredBufferDuration = 0.005;
        _audioController.useMeasurementMode = YES;
        [_audioController start:NULL];
    }
    return self;
}

#pragma mark - Public
- (void)enlarge {
    if (_enlarged) {
        [self removeAllActions];
        SKAction* slide = [SKAction moveTo:self.startPosition duration:0.4];
        SKAction* scaleDown = [SKAction scaleTo:0.0 duration:0.4];
        [self runAction:[SKAction group:@[slide, scaleDown]] completion:^{
            _enlarged = NO;
            [self setHidden:YES];
        }];
    } else {
        [self removeAllActions];
        _enlarged = YES;
        [self setHidden:NO];
        
        SKAction* slide = [SKAction moveTo:self.endPosition duration:0.4];
        SKAction* scaleUp = [SKAction scaleTo:1.0 duration:0.4];
        [self runAction:[SKAction group:@[slide, scaleUp]]];
    }
}

- (void)enlargeWithWord:(NSMutableArray*)words {
    _words = words;
    
    if (_enlarged) {
        [self removeAllActions];
        SKAction* slide = [SKAction moveTo:self.startPosition duration:0.4];
        SKAction* scaleDown = [SKAction scaleTo:0.0 duration:0.4];
        [self runAction:[SKAction group:@[slide, scaleDown]] completion:^{
            _enlarged = NO;
            [self setHidden:YES];
        }];
    } else {
        Word*a = (Word*)_words[0];
        _lbWord.text = a.wText;
        [self removeAllActions];
        _enlarged = YES;
        [self setHidden:NO];
        
        SKAction* slide = [SKAction moveTo:self.endPosition duration:0.4];
        SKAction* scaleUp = [SKAction scaleTo:1.0 duration:0.4];
        [self runAction:[SKAction group:@[slide, scaleUp]] completion:^{
            [self _playSound];
        }];
    }
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *touchNode = [self nodeAtPoint:location];
    
    SKAction *push = [NodeUtility buttonPushAction];
    
    // Button Home clicked
    if (touchNode == _spriteSquid) {
        [touchNode runAction:push completion:^{
            [self _stopRecording];
            // Present home scene
            [self _playSound];
            
        }];
    }
}

#pragma mark - Private

- (void)_playSound {
    //
    NSError *error = nil;
    Word*a = (Word*)_words[0];
    NSURL* url = [NSURL URLWithString:[a fullFilePath]];
    self.player = [AEAudioFilePlayer audioFilePlayerWithURL:url error:&error];
    if ( !_player ) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    
    
    _player.removeUponFinish = YES;
    __weak SpeechCard *weakSelf = self;
    _player.completionBlock = ^{
        weakSelf.player = nil;
        // Stop previous session
        if ([weakSelf.recorder recording]) {
            [weakSelf _stopRecording];
        }
        
        // Start new session
        [weakSelf _startRecording];
    };
    [_audioController addChannels:@[_player]];
}

- (void)_startRecording {
    // Session
    _soundDetected = NO;
    
    // Mic indicator
    [_spriteMic setTexture:[SKTexture textureWithImageNamed:@"btnMicOn"]];
    _spriteVolume.hidden = NO;
    
    // Mic meter timer
    if (!self.meterTimer) {
        self.meterTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0f
                                                           target:self
                                                         selector:@selector(_updateAudioMeter)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    
    
    // Start new session
    self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
    NSString *path = [self _recordedSoundPath];
    NSError *error = nil;
    if ( ![_recorder beginRecordingToFileAtPath:path
                                       fileType:kAudioFileWAVEType
                                          error:&error] ) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        self.recorder = nil;
        return;
    }
    
    //_recordButton.selected = YES;
    //self.btnPlay.enabled = NO;
    [_audioController addInputReceiver:_recorder];

}

- (void)_stopRecording {
    // Mic meter timer
    [self.meterTimer invalidate];
    self.meterTimer = nil;
    
    // Stop session
    [_recorder finishRecording];
    [_audioController removeInputReceiver:_recorder];
    self.recorder = nil;
    
    // Remove all buffer
    [_silenceArray removeAllObjects];
    
    // Mic indicator
    [_spriteMic setTexture:[SKTexture textureWithImageNamed:@"btnMicOff"]];
    [_spriteVolume runAction:[SKAction scaleTo:1 duration:1/60.0f]];
    _spriteVolume.hidden = YES;
}

- (void)_updateAudioMeter //called by timer
{
    Float32 vol, peak;
    [self.audioController inputAveragePowerLevel:&vol peakHoldLevel:&peak];
    // audioRecorder being your instance of AVAudioRecorder
 
    NSLog(@"%f",vol);
    // Case 1:
    // After 2s without sound -> stop
    // Case 2:
    // After detecting sound, 1s without sound -> stop
    
    
    
    [_silenceArray addItem:[NSNumber numberWithFloat:vol]];
    //NSLog(@"%f %lu",vol,(unsigned long)_silenceArray.count);
    if (vol >= -40 && !_soundDetected) {
        _soundDetected = YES;
        [_silenceArray removeAllObjects];
    }
    if (_silenceArray.count == kBufferLength) {
        float a = [self avg];
        if (a < -35.0f) {
            [self _stopRecording];
            if (_soundDetected) {
                _soundDetected = NO;
                BOOL isCorrect = NO;
                for (Word* w in _words) {
                    float s = [MFCCAudioController scoreFileA:[self _recordedSoundPath] fileB:w];
                    NSLog(@"score %f",s);
                    if (s >= kScore) {
                        isCorrect = YES;
                        break;
                    }
                }
                if (isCorrect) {
                    [self _displayStar:YES];
                    _currentStarIdx ++;
                } else {
                    [self _displayStar:NO];
                }
                
//                _spriteStar1
            }
        }
    }
    
    
    // Animation
    float per = MAX((vol+160-110)/50.0, 0.0);
    [_spriteVolume runAction:[SKAction scaleTo:1+(per/1.8) duration:1/60.0f]];
}

- (float)avg {
    float sum = 0.0;
    for (NSNumber* num in _silenceArray) {
        sum += [num floatValue];
    }
    return sum/_silenceArray.count;
}

- (NSURL*)_recordedSoundURL {
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.wav"];
    
    NSURL* url = [NSURL fileURLWithPath:soundFilePath];
    return url;
}

- (NSString*)_recordedSoundPath {
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.wav"];
    
    return soundFilePath;
}

- (void)_displayStar:(BOOL)boo {
    NSString* key = [NSString stringWithFormat:@"star%d",_currentStarIdx];
    SKSpriteNode* node = (SKSpriteNode*)[self childNodeWithName:key];
    if (boo) {
        SKAction* scaleUp = [SKAction scaleTo:1.2 duration:0.2];
        [node runAction:scaleUp completion:^{
            node.texture = [SKTexture textureWithImageNamed:@"imgStar1"];
            SKAction* scaleDown = [SKAction scaleTo:1.0 duration:0.2];
            [node runAction:scaleDown];
        }];
    } else {
        SKAction* rot1 = [SKAction rotateByAngle:-3 duration:0.2];
        SKAction* rot2 = [SKAction rotateByAngle:6 duration:0.2];
        [node runAction:[SKAction group:@[rot1, rot2]] completion:^{
            node.texture = [SKTexture textureWithImageNamed:@"imgStar0"];
            SKAction* rot3 = [SKAction rotateByAngle:-3 duration:0.2];
            [node runAction:rot3];
        }];
    }
}

@end
