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

@interface SpeechCard()

@property (strong, nonatomic) AVAudioPlayer *musicPlayer;

@end

@implementation SpeechCard {
    SKLabelNode* _lbWord;
    SKSpriteNode* _spriteSpeaker;
    SKSpriteNode* _spriteSquid;
    Word *_word;
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
        
        // Add Speaker
        _spriteSpeaker = [SKSpriteNode spriteNodeWithImageNamed:@"btnSpeaker1"];
        _spriteSpeaker.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteSpeaker.position = CGPointMake(self.size.width - 55.0, 220);
        _spriteSpeaker.zPosition = self.zPosition+1;
        [self addChild:_spriteSpeaker];
        
        // Add squid
        _spriteSquid = [SKSpriteNode spriteNodeWithImageNamed:@"charSquid"];
        _spriteSquid.anchorPoint = CGPointMake(0.5, 0.5);
        _spriteSquid.position = CGPointMake(self.size.width/2-10, self.size.height/2+45);
        _spriteSquid.zPosition = self.zPosition+1;
        [self addChild:_spriteSquid];
        
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
    if (touchNode == _spriteSpeaker) {
        [touchNode runAction:push completion:^{
            // Present home scene
            [self _playSound];
        }];
    }
}

#pragma mark - Private

- (void)_playSound {
    NSURL* url = [NSURL URLWithString:[_word fullFilePath]];
    self.musicPlayer = nil;
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url  error:nil];
    _musicPlayer.numberOfLoops = 0; // negative value repeats indefinitely
    _musicPlayer.volume = 1;
    [_musicPlayer play];
}

@end
