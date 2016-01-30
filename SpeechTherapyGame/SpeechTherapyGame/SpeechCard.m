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
#import "Word.h"

@interface SpeechCard() <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSTimer *meterTimer;

@end

@implementation SpeechCard {
    SKLabelNode* _lbWord;
    SKLabelNode* _lbDesc;
    SKSpriteNode* _spriteSpeaker;
    SKSpriteNode* _spriteMic;
    SKSpriteNode* _spriteSquid;
    SKShapeNode* _spriteVolume;
    Word *_word;
    SKSpriteNode* _spriteStar1;
    SKSpriteNode* _spriteStar2;
    SKSpriteNode* _spriteStar3;
    NSDictionary *_recordSettings;
}

- (id)initWithColor:(UIColor *)color size:(CGSize)size {
    self = [super initWithColor:[UIColor clearColor] size:size];
    if (self) {
        self.userInteractionEnabled = YES;
        
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
        [self addChild:_spriteStar1];
        
        _spriteStar2 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar2.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar2.position = CGPointMake(self.size.width/2, 40);
        _spriteStar2.zPosition = self.zPosition+1;
        [self addChild:_spriteStar2];
        
        _spriteStar3 = [SKSpriteNode spriteNodeWithImageNamed:@"imgStar0"];
        _spriteStar3.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteStar3.position = CGPointMake(self.size.width/2+70, 50);
        _spriteStar3.zPosition = self.zPosition+1;
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
        
        // Record settings
        _recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                           [NSNumber numberWithInt:44100],AVSampleRateKey,
                           [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                           [NSNumber numberWithInt:32],AVLinearPCMBitDepthKey,
                           [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                           [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                           nil];
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

- (void)enlargeWithWord:(Word*)word {
    _word = word;
    
    if (_enlarged) {
        [self removeAllActions];
        SKAction* slide = [SKAction moveTo:self.startPosition duration:0.4];
        SKAction* scaleDown = [SKAction scaleTo:0.0 duration:0.4];
        [self runAction:[SKAction group:@[slide, scaleDown]] completion:^{
            _enlarged = NO;
            [self setHidden:YES];
        }];
    } else {
        _lbWord.text = word.wText;
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

#pragma mark - Audio delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [self.audioPlayer stop];
        
        // Stop previous session
        [self _stopRecording];
        // Start new session
        [self _startRecording];
    }
}

-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

#pragma mark - Private

- (void)_playSound {
    //
    NSURL* url = [NSURL URLWithString:[_word fullFilePath]];
    self.audioPlayer = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url  error:nil];
    _audioPlayer.numberOfLoops = 0; // negative value repeats indefinitely
    _audioPlayer.volume = 1;
    [_audioPlayer play];
    _audioPlayer.delegate = self;
}

- (void)_startRecording {
    // Session
    
    // Audio Session
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:&error];
    if (error) {
        NSLog(@"Error description: %@", [error description]);
    }
    [audioSession setActive:YES error:nil];
    
    // Mic indicator
    [_spriteMic setTexture:[SKTexture textureWithImageNamed:@"btnMicOn"]];
    
    // Mic meter timer
    if (!self.meterTimer) {
        self.meterTimer = [NSTimer scheduledTimerWithTimeInterval:1/60.0f
                                                           target:self
                                                         selector:@selector(_updateAudioMeter)
                                                         userInfo:nil
                                                          repeats:YES];
    }
    
    
    // Start new session
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[self _recordedSoundURL]
                                                 settings:_recordSettings
                                                    error:nil];
    _audioRecorder.delegate = self;
    [_audioRecorder prepareToRecord];
    [_audioRecorder setMeteringEnabled:YES];
    [_audioRecorder record];
}

- (void)_stopRecording {
    // Mic indicator
    [_spriteMic setTexture:[SKTexture textureWithImageNamed:@"btnMicOff"]];
    
    // Mic meter timer
    [self.meterTimer invalidate];
    self.meterTimer = nil;
    
    // Stop session
    [self.audioRecorder stop];
    self.audioRecorder = nil;
}

- (void)_updateAudioMeter //called by timer
{
    // audioRecorder being your instance of AVAudioRecorder
    [self.audioRecorder updateMeters];
    float vol = [self.audioRecorder averagePowerForChannel:0];
    float per = MAX((vol+70)/70.0, 0.0);

    [_spriteVolume runAction:[SKAction scaleTo:1+(per/2) duration:1/60.0f]];
}

- (NSURL*)_recordedSoundURL {
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL* url = [NSURL fileURLWithPath:soundFilePath];
    return url;
}

@end
