//
//  SpeechCard.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/27/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "SpeechCard.h"
#import "Chameleon.h"
#import "NSMutableArray+Queue.h"
#import "Word.h"
#import "MFCCAudioController.h"
#import "TheAmazingAudioEngine.h"
#import "AERecorder.h"
#import "AudioPlayer.h"
#import "SKSpriteNode+ES.h"
#import "UIImage+ES.h"
#import <EZAudio/EZAudio.h>
#import "AudioPlayer.h"
#import "DataManager.h"
#import "Score.h"
#import "FishingGameScene.h"
#import "PassFilter.h"
#include "SUTDMFCCHelperFunctions.hpp"
#define kBufferLength 80
#define kTick 20

@interface SpeechCard()

@property (nonatomic, weak) AEAudioController* audioController;
@property (nonatomic, strong) AERecorder *recorder;
//@property (nonatomic, strong) id receiver;
@property (nonatomic, strong) AEAudioFilePlayer *player;
@property (nonatomic, assign) int count;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL soundDetected;
@property (nonatomic, strong) NSMutableArray *silenceArray;

@end

@implementation SpeechCard {
    SKLabelNode* _lbWord;
    SKLabelNode* _lbDesc;
    int _currentStarIdx;
    SKSpriteNode* _spriteSpeaker;
    SKSpriteNode* _spriteMic;
    SKSpriteNode* _spriteSquid;
    SKShapeNode* _spriteVolume;
    SKSpriteNode* _spriteFinger;
    Word *_word;
    SKSpriteNode* _spriteStar1;
    SKSpriteNode* _spriteStar2;
    SKSpriteNode* _spriteStar3;
    SKSpriteNode* _spriteStar4;
    SKSpriteNode* _spriteStar5;
    NSTimer *_idleTimer;
    
    NSMutableArray* _words;
    int _failedAttemp;
    float _energyMeter;
    NSString* _currentFileName;
    NSString* _currentFilePath;
}

- (id)initWithColor:(UIColor *)color size:(CGSize)size {
    self = [super initWithColor:[UIColor clearColor] size:size];
    if (self) {
        self.userInteractionEnabled = YES;
        
        self.silenceArray = [[NSMutableArray alloc] initWithMaxItem:kBufferLength];
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
        _lbDesc.text = @"Tap the picture to hear the sound";
        _lbDesc.zPosition = self.zPosition+1;
        [self addChild:_lbDesc];
        
        // Add squid
        _spriteSquid = [SKSpriteNode spriteNodeWithImageNamed:@"charSquid"];
        _spriteSquid.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteSquid.position = CGPointMake(self.size.width/2-10, self.size.height/2+25);
        _spriteSquid.zPosition = self.zPosition+1;
        [self addChild:_spriteSquid];
        
        int y = 65;
        int x = 60;
        int dY = 75;
        // Star 1
        _spriteStar1 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar1.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar1.position = CGPointMake(x, self.size.height-y-dY);
        _spriteStar1.zPosition = self.zPosition+1;
        _spriteStar1.name = @"star1";
        [self addChild:_spriteStar1];
        
        _spriteStar2 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar2.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar2.position = CGPointMake(x, self.size.height-y-dY*2);
        _spriteStar2.zPosition = self.zPosition+1;
        _spriteStar2.name = @"star2";
        [self addChild:_spriteStar2];
        
        _spriteStar3 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar3.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar3.position = CGPointMake(x, self.size.height-y-dY*3);
        _spriteStar3.zPosition = self.zPosition+1;
        _spriteStar3.name = @"star3";
        [self addChild:_spriteStar3];
        
        _spriteStar4 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar4.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar4.position = CGPointMake(x, self.size.height-y-dY*4);
        _spriteStar4.zPosition = self.zPosition+1;
        _spriteStar4.name = @"star4";
        [self addChild:_spriteStar4];
        
        _spriteStar5 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar5.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar5.position = CGPointMake(x, self.size.height-y-dY*5);
        _spriteStar5.zPosition = self.zPosition+1;
        _spriteStar5.name = @"star5";
        [self addChild:_spriteStar5];
        
        // Add mic
        _spriteMic = [SKSpriteNode spriteNodeWithImageNamed:@"btnMicOff"];
        _spriteMic.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteMic.position = CGPointMake(self.size.width - 70, 200);
        _spriteMic.zPosition = self.zPosition+2;
        [self addChild:_spriteMic];
        
        // Add vol meter
//        _spriteVolume = [SKShapeNode shapeNodeWithCircleOfRadius:_spriteMic.size.height/2];
//        _spriteVolume.position = _spriteMic.position;
//        _spriteVolume.fillColor = [[SKColor flatWhiteColor] colorWithAlphaComponent:0.3];
//        _spriteVolume.lineWidth = 0;
//        _spriteVolume.antialiased = YES;
//        _spriteVolume.zPosition = self.zPosition+1;
//        [self addChild:_spriteVolume];
        
        // ==========================================================================
        // AE Audio Controller
//        __weak SpeechCard *weakSelf = self;
        self.audioController = [[AudioPlayer shared] aAEController];
        
//        // AE Audio Receiver
//        self.receiver = [AEBlockAudioReceiver audioReceiverWithBlock:
//               ^(void                     *source,
//                 const AudioTimeStamp     *time,
//                 UInt32                    frames,
//                 AudioBufferList          *audio) {
//                   // Do something with 'audio'
//                   if (audio) {
//                       float *source= (float *)audio->mBuffers[0].mData;
//                       float tick = 0;
//                       for (int j = 0; j < frames; j++) {
//                           tick += sqrtf(source[j]*source[j]);
//                       }
//                       if (!weakSelf.soundDetected) {
//                           weakSelf.count++;
//                       }
//                       if (weakSelf.count == 150) {
//                           [weakSelf _stopRecording];
//                           weakSelf.count = 0;
//                           weakSelf.recording = NO;
//                           //[weakSelf resetIdleTimer];
//                           [self doSth];
//                       }
//                       if (tick>=25 && !_soundDetected) {
//                           weakSelf.soundDetected = YES;
//                           [weakSelf.silenceArray removeAllObjects];
//                           weakSelf.count = 0;
//                       }
//                       if (weakSelf.soundDetected) {
//                           [weakSelf.silenceArray addItem:[NSNumber numberWithFloat:tick]];
//                           if (weakSelf.silenceArray.count == kBufferLength) {
//                               float a = [weakSelf avg];
//                               if (a <= 30) {
//                                   [weakSelf _stopRecording];
//                                   [weakSelf _score];
//                               }
//                           }
//                       }
//                   }
//               }];
        
        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
    }
    return self;
}

- (void)_score {
    // Calculate score
    BOOL isCorrect = NO;
    NSLog(@"=======================================");
    float maxScore = 0.0f;
    for (Word* w in _words) {
        
        float s = [MFCCAudioController scoreUserVoice:_currentFilePath dbVoice:w];
        //float s = [MFCCAudioController scoreUserVoiceMemoryTest:_currentFilePath dbVoice:w];
        if (s > maxScore) maxScore = s;
        NSLog(@"score %f",s);
    }
    NSLog(@"max score %f",maxScore);
    NSLog(@"=======================================");
    // Insert score to database
    Word* word = _words[0];
    Score *score = [[Score alloc] init];
    score.phoneme = word.phoneme;
    score.sound = word.sound;
    score.score = maxScore;
    score.date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd MMM yyyy"];
    score.dateString = [format stringFromDate:score.date];
    score.recordPath = _currentFileName;
    [[DataManager shared] insertScore:score];
    
    // Update UI
    float minScore = [[DataManager shared] difficultyValue];
    if (maxScore >= minScore) {
        isCorrect = YES;
    }
//        _failedAttemp = 0;
//    } else {
//        _failedAttemp ++;
//        if (_failedAttemp == 3) {
//            _failedAttemp = 0;
//            isCorrect = YES;
//        }
//    }
//    if (isCorrect) {
//        [self _displayStar:isCorrect];
//    } else {
//        [self _displayStar:NO];
//    }
    [self _displayStar:isCorrect];
}

#pragma mark - Idle Timer

- (void)resetIdleTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
    if (_idleTimer) {
        [_idleTimer invalidate];
    }
    
    _idleTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0f
                                                  target:self
                                                selector:@selector(tick)
                                                userInfo:nil
                                                 repeats:YES];
        //[_idleTimer fire];
    
    });
}

- (void)stopTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_idleTimer) {
            [_idleTimer invalidate];
        }
    });
}

- (void)tick {
    Float32 avg;
    Float32 peak;
    [self.audioController inputAveragePowerLevel:&avg peakHoldLevel:&peak];
    
    if (!self.soundDetected) {
        self.count++;
    }
    if (self.count == 150) {
        [self _stopRecording];
        self.count = 0;
        self.recording = NO;
        //[weakSelf resetIdleTimer];
        [self doSth];
    }
    
    if (avg>=-30 && !_soundDetected) {
        self.soundDetected = YES;
        [self.silenceArray removeAllObjects];
        self.count = 0;
    }
    if (self.soundDetected) {
        [self.silenceArray addItem:[NSNumber numberWithFloat:avg]];
        if (self.silenceArray.count == kBufferLength) {
            float a = [self avg];
            NSLog(@"%f",a);
            if (a <= -40) {
                [self _stopRecording];
                [self _score];
            }
        }
    }
}

- (void)addFinger {
    if (!_spriteFinger) {
        _spriteFinger = [SKSpriteNode spriteNodeWithImageNamed:@"finger1.png"];
        _spriteFinger.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteFinger.position = CGPointMake(self.size.width - 70, 275);
        _spriteFinger.zPosition = self.zPosition+10;
        [self addChild:_spriteFinger];
        
        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"finger"];
        
        NSArray *frames = @[[atlas textureNamed:@"finger1"],
                            [atlas textureNamed:@"finger2"]];
        
        [_spriteFinger runAction:[SKAction repeatActionForever:
                         [SKAction animateWithTextures:frames
                                          timePerFrame:0.25f
                                                resize:NO
                                               restore:NO]] withKey:@"finger"];
    }
    [_spriteFinger runAction:[SKAction fadeInWithDuration:0.3]];
}

- (void)removeFinger {
    [_spriteFinger runAction:[SKAction fadeOutWithDuration:0.3]];
}

#pragma mark - Public

- (void)enlargeWithWord:(NSMutableArray*)words {
    [self resetIdleTimer];
    _words = words;
    
    Word*a = (Word*)_words[0];
    [_spriteSquid removeFromParent];
    
    [self _showWithCompletion:^{
        // Update UI
        _lbWord.text = a.sound;
        if (a.imgPath.length == 0) {
            _spriteSquid = [SKSpriteNode spriteNodeWithImageNamed:@"charSquid"];
            _spriteSquid.anchorPoint = CGPointMake(0.5, 0.5);
            _spriteSquid.position = CGPointMake(self.size.width/2-10, self.size.height/2+45);
            _spriteSquid.zPosition = self.zPosition+1;
            [self addChild:_spriteSquid];
        } else {
            UIImage* img = [UIImage imageWithContentsOfFile:a.imgFilePath];
            double width = img.size.width;
            double height = img.size.height;
            double screenWidth = 270;
            double apect = width/height;
            double nHeight = screenWidth/ apect;
            img = [UIImage imageWithImage:img scaledToSize:CGSizeMake(screenWidth, nHeight)];
            
            _spriteSquid = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:img]];
            _spriteSquid.anchorPoint = CGPointMake(0.5, 0.5);
            _spriteSquid.position = CGPointMake(self.size.width/2-10, self.size.height/2+45);
            _spriteSquid.zPosition = self.zPosition+1;
            [self addChild:_spriteSquid];
        }
        [self doSth];
    }];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInNode:self];
//    SKNode *touchNode = [self nodeAtPoint:location];
//    
//    SKAction *push = [NodeUtility buttonPushAction];
//    // Button Home clicked
//    if (![touchNode.name containsString:@"star"] && !_recording) {
//        _recording = YES;
//        if (touchNode == self) {
//            [self _stopRecording];
//            // Present home scene
//            [self _playSound];
//        } else {
//            [touchNode runAction:push completion:^{
//                [self _stopRecording];
//                // Present home scene
//                [self _playSound];
//            }];
//        }
//    }
    //[self resetIdleTimer];
}

- (void)doSth {
    _recording = YES;
    
    [self _stopRecording];
    // Present home scene
    [self _playSound];
}

- (void)removeFromParent {
    
    // Mic meter timer
    [self stopTimer];
    //[self.audioController removeInputReceiver:self.receiver];
    [self.audioController removeInputReceiver:self.recorder];
    
    //self.receiver = nil;
    
    [self.recorder finishRecording];
    self.recorder = nil;
    
    [super removeFromParent];
}

#pragma mark - Private

- (void)_hide {
    _currentStarIdx = 1;
    _failedAttemp = 0;
    for (int i = 1; i<=5; i++) {
        NSString* key = [NSString stringWithFormat:@"star%d",i];
        SKSpriteNode* node = (SKSpriteNode*)[self childNodeWithName:key];
        node.texture = [SKTexture textureWithImageNamed:@"imgStar0"];
    }
    [self removeAllActions];
    SKAction* slide = [SKAction moveTo:self.startPosition duration:0.4];
    SKAction* scaleDown = [SKAction scaleTo:0.0 duration:0.4];
    SKAction* sound = [SKAction playSoundFileNamed:@"hide.m4a" waitForCompletion:NO];
    [self runAction:[SKAction group:@[slide, sound,scaleDown]] completion:^{
        _enlarged = NO;
        [self setHidden:YES];
        FishingGameScene* s = (FishingGameScene*)self.scene;
        [s removeCatchCreature];
    }];
}

- (void)_showWithCompletion:(void (^)())block {
    [self removeAllActions];
    _enlarged = YES;
    [self setHidden:NO];
    
    SKAction* slide = [SKAction moveTo:self.endPosition duration:0.4];
    SKAction* scaleUp = [SKAction scaleTo:1.0 duration:0.4];
    SKAction* sound = [SKAction playSoundFileNamed:@"show.m4a" waitForCompletion:NO];
    [self runAction:[SKAction group:@[slide,sound, scaleUp]] completion:^{
        block();
    }];
}

- (void)_playSound {
    //
    Word*a = (Word*)_words[0];
    
    [self runAction:[SKAction playSoundFileNamed:@"say.mp3" waitForCompletion:YES] completion:^{
        NSURL* url = [NSURL URLWithString:[a sampleFilePath]];
        self.player = [AEAudioFilePlayer audioFilePlayerWithURL:url error:nil];
        self.player.removeUponFinish = YES;
        __weak SpeechCard *weakSelf = self;
        _player.completionBlock = ^{
            weakSelf.player = nil;
            [weakSelf _startRecording];
        };
        [_audioController addChannels:@[_player]];
    }];
    
}

- (void)_startRecording {
    if ([self.recorder recording]) {
        [self _stopRecording];
        self.recorder = nil;
    }
    // Session
    _soundDetected = NO;
    
    // Mic indicator
    [_spriteMic setTexture:[SKTexture textureWithImageNamed:@"btnMicOn"]];
    _spriteVolume.hidden = NO;
    
    // Start new session
    //[self.audioController addInputReceiver:self.receiver];
    [self resetIdleTimer];
    // AE Recorder
    
    [_audioController addInputReceiver:_recorder];
    
    NSString *path = [self _recordedSoundPath];
    NSError *error = nil;
    [_recorder beginRecordingToFileAtPath:path
                                       fileType:kAudioFileWAVEType
     bitDepth:32 channels:1
                                     error:&error];

    if (error) {
        NSLog(@"error %@",error.description);
    }
    

}

- (void)_stopRecording {
    
    // Stop recording
    if ([_recorder recording]) {
        [_recorder finishRecording];
    }

    [_audioController removeInputReceiver:self.recorder];
    //[_audioController removeInputReceiver:self.receiver];
    [self stopTimer];
    
    // Remove all buffer
    [_silenceArray removeAllObjects];
    
    // Mic indicator
    [_spriteMic setTexture:[SKTexture textureWithImageNamed:@"btnMicOff"]];
    [_spriteVolume runAction:[SKAction scaleTo:1 duration:1/60.0f]];
    _spriteVolume.hidden = YES;
    
    // Read full file
    AEAudioFileLoaderOperation *fullFileOperation;
    fullFileOperation = [[AEAudioFileLoaderOperation alloc]
                         initWithFileURL:[PassFilter urlForPath:_currentFilePath]
                         targetAudioDescription:[PassFilter monoFloatFormatWithSampleRate:44100.0f]];
    [fullFileOperation start];
    if ( fullFileOperation.error ) {
        // Load failed! Clean up, report error, etc.
        return;
    }
    
    float* mBuffer = (float*)fullFileOperation.bufferList->mBuffers[0].mData;
    UInt64 mLen = fullFileOperation.lengthInFrames;
    // Writer
    NSString* filterP = [_currentFilePath stringByReplacingOccurrencesOfString:@".wav" withString:@"_filtered.wav"];
    
    const char *cha = [filterP cStringUsingEncoding:NSUTF8StringEncoding];
    filterSound(mBuffer, mLen, cha);
    _currentFilePath = filterP;

}

- (void)_updateAudioMeter:(NSTimer *) timer //called by timer
{
    // Animation
    [_spriteVolume removeAllActions];
    float per = MAX((_energyMeter)/80.0, 0.0);
    [_spriteVolume runAction:[SKAction scaleTo:1+(MIN(per,1)) duration:0.005f*kTick]];
//    
//    [_silenceArray addItem:[NSNumber numberWithFloat:vol]];
//    //NSLog(@"%f %lu",vol,(unsigned long)_silenceArray.count);
//    if (vol >= -40 && !_soundDetected ) {
//        _soundDetected = YES;
//        [_silenceArray removeAllObjects];
//    }
//    if (_silenceArray.count == kBufferLength) {
//        float a = [self avg];
//        if (a < -35.0f) {
//            [self _stopRecording];
//            if (_soundDetected) {
//                _soundDetected = NO;
//                BOOL isCorrect = NO;
//                for (Word* w in _words) {
//                    float s = [MFCCAudioController scoreFileA:[self _recordedSoundPath] fileB:w];
//                    NSLog(@"score %f",s);
//                    if (s >= kScore) {
//                        isCorrect = YES;
//                        _failedAttemp = 0;
//                        break;
//                    } else {
//                        _failedAttemp ++;
//                        if (_failedAttemp == 4) {
//                            _failedAttemp = 0;
//                            isCorrect = YES;
//                            break;
//                        }
//                    }
//                }
//                if (isCorrect) {
//                    [self _displayStar:YES];
//                    _currentStarIdx ++;
//                } else {
//                    [self _displayStar:NO];
//                }
//                
////                _spriteStar1
//            }
//        }
//    }
    
    
    
}

- (float)avg {
    float sum = 0.0;
    for (NSNumber* num in _silenceArray) {
        sum += [num floatValue];
    }
    return sum/_silenceArray.count;
}
- (NSString*)_recordingFile {
    NSDate *d = [NSDate date];
    int num = [d timeIntervalSince1970];
    _currentFileName = [NSString stringWithFormat:@"recordings/%d.wav",num];
    return _currentFileName;
}

- (NSString*)_recordedSoundPath {
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:[self _recordingFile]];
    _currentFilePath = soundFilePath;
    
    return soundFilePath;
}

- (void)_displayStar:(BOOL)boo {
    NSString* key = [NSString stringWithFormat:@"star%d",_currentStarIdx];
    SKSpriteNode* node = (SKSpriteNode*)[self childNodeWithName:key];
    SKAction* sound;
    NSString* textureName = @"imgStar1";
    if (boo) {
        sound = [SKAction playSoundFileNamed:@"correct.m4a" waitForCompletion:YES];
        textureName = @"imgStar1";
    } else {
        sound = [SKAction playSoundFileNamed:@"incorrect.m4a" waitForCompletion:YES];
        textureName = @"imgStar2";
    }
    {
        SKAction* scaleUp = [SKAction scaleTo:1.2 duration:0.2];
        [node runAction:scaleUp completion:^{
            node.texture = [SKTexture textureWithImageNamed:textureName];
            SKAction* scaleDown = [SKAction scaleTo:1.0 duration:0.2];
            SKAction* s = [SKAction sequence:@[scaleDown, sound]];
            [node runAction:s completion:^{
                _currentStarIdx ++;
                if (_currentStarIdx > 5) {
                    [self _hide];
                    [self _stopRecording];
                } else {
                    [self runAction:[SKAction playSoundFileNamed:@"again.mp3" waitForCompletion:YES] completion:^{
                        [self doSth];
                    }];
                    
                }
                _recording = NO;
                //[self resetIdleTimer];
            }];
        }];
    }
//    else {
//        SKAction* rot1 = [SKAction rotateByAngle:-1.5 duration:0.2];
//        SKAction* rot2 = [SKAction rotateByAngle:3 duration:0.2];
//        SKAction* sound = [SKAction playSoundFileNamed:@"incorrect.m4a" waitForCompletion:NO];
//        [node runAction:[SKAction sequence:@[rot1,sound, rot2]] completion:^{
//            node.texture = [SKTexture textureWithImageNamed:@"imgStar0"];
//            SKAction* rot3 = [SKAction rotateByAngle:-1.5 duration:0.2];
//            SKAction* s = [SKAction playSoundFileNamed:@"again.mp3" waitForCompletion:YES];
//            [node runAction:[SKAction sequence:@[rot3, s]] completion:^{
//                _recording = NO;
//                //[self resetIdleTimer];
//                [self doSth];
//            }];
//            
//        }];
//    }
}

@end
