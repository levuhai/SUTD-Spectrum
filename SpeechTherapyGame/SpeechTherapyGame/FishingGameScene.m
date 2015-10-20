//
//  FishingGameScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 10/15/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "FishingGameScene.h"
#import "FishingGameViewController.h"

#define WaterViewHeigh 460

@interface FishingGameScene () {
    SKSpriteNode* _whale;
    SKSpriteNode* _buoy;
    
    BOOL didShowText;
}

@end

@implementation FishingGameScene

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = RGB(66, 191, 254);
    
    [self setupGameScene];
}

- (void) setupGameScene {
    //Static objects
    // Water
    SKSpriteNode* waterView = [[SKSpriteNode alloc] initWithColor:RGB(16, 100, 171) size:CGSizeMake(self.size.width, WaterViewHeigh)];
    waterView.anchorPoint = CGPointZero;
    waterView.position = CGPointZero;
    waterView.zPosition = -1;
    [self addChild:waterView];

    // Land
    SKSpriteNode* landView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"land-sand"]];
    landView.anchorPoint = CGPointMake(-1, 0);
    landView.position = CGPointMake(0, WaterViewHeigh - 10);
    landView.zPosition = -2;
    [self addChild:landView];
    
    // The Sun
    SKSpriteNode* sunView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"thesun"]];
    sunView.anchorPoint = CGPointMake(0.5, 0.5);
    sunView.position = CGPointMake(self.size.width - 20, self.size.height - 20);
    sunView.zPosition = -3;
    [sunView runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:2*M_PI duration:60]]];
    [self addChild:sunView];
    
    // turtle
    SKSpriteNode* turtleView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"turtle"]];
    turtleView.anchorPoint = CGPointMake(0, 0);
    turtleView.position = CGPointMake(self.size.width - turtleView.size.width, WaterViewHeigh + 10);
    [self addChild:turtleView];
    
    // pot
    SKSpriteNode* potView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"fish-pot"]];
    potView.anchorPoint = CGPointMake(0, 0);
    potView.position = CGPointMake(self.size.width - turtleView.size.width - potView.size.width, WaterViewHeigh + 5);
    [self addChild:potView];
    
    // bear
    SKSpriteNode* bearView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"pencil-bear"]];
    bearView.anchorPoint = CGPointMake(0, 0);
    bearView.position = CGPointMake(self.size.width - bearView.size.width - 300, WaterViewHeigh + 20);
    [self addChild:bearView];
    
    // Dynamic objects
    // Buoy
    _buoy = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"buoy"]];
    _buoy.anchorPoint = CGPointMake(0.5, 0.5);
    _buoy.position = CGPointMake(2*self.size.width/5, WaterViewHeigh);
    [self addChild:_buoy];
    [_buoy runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:3 duration:0.5], [SKAction moveByX:0 y:-3 duration:0.5]]]]];
    
    // Whale
    _whale = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"whale"]];
    _whale.anchorPoint = CGPointMake(0.5, 0.5);
    _whale.position = CGPointMake(5, WaterViewHeigh);
    [self addChild:_whale];
    [_whale runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:-10 duration:0.5], [SKAction moveByX:0 y:10 duration:0.5]]]]];
    
}

- (void) animateCountDownCircle {
    // Positions
    _fishingGameVC.countDownCircleContainer.x = _buoy.position.x - _fishingGameVC.countDownCircleContainer.width/2;
    _fishingGameVC.countDownCircleContainer.y = _buoy.position.y - 300;
    // Animate
    [_fishingGameVC shouldShowCountDown:YES];
    [_fishingGameVC updateProgressValue:0 duration:10];
    
    SKAction* hideMic = [SKAction runBlock:^{
        [UIView animateWithDuration:0.5 animations:^{
            _fishingGameVC.micImage.alpha = 0;
        }];
    }];
    SKAction* showMic = [SKAction runBlock:^{
        [UIView animateWithDuration:0.5 animations:^{
            _fishingGameVC.micImage.alpha = 1;
        }];
    }];
    
    [self runAction:[SKAction repeatAction:[SKAction sequence:@[hideMic,[SKAction waitForDuration:0.5],showMic,[SKAction waitForDuration:1]]] count:10]];
    
    // After countdown
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(9.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_fishingGameVC shouldShowCountDown:NO];
        [self processAudio];
        if (FALSE) { // recording doesn't match
            
        } else {
            [self animateWhaleBack];
        }
    });
}

- (void) processAudio {

}

- (void) animateWhaleHooked {
    
    if (!didShowText) {
        [_whale runAction:[SKAction moveTo:CGPointMake(_buoy.position.x - _whale.size.width/2 - 20, _whale.position.y + 10) duration:1] completion:^{
            // Show count down
            [self addLetterToWhale];
            didShowText = YES;
            [self animateCountDownCircle];
        }];

    }
}

- (void) animateWhaleBack {
    if (didShowText) {
        [_whale runAction:[SKAction scaleXBy:-1 y:1 duration:0.1] completion:^{
            [_whale runAction:[SKAction moveTo:CGPointMake(5, WaterViewHeigh) duration:1] completion:^{
                // Show count down
                [_whale removeAllChildren];
                didShowText = NO;
                _whale.xScale*=-1;
            }];
        }];
    }
}

- (void) addLetterToWhale {
    SKLabelNode* letter = [SKLabelNode node];
    //letter.fontName = @"Arial-Bold";
    letter.text = @"T";
    letter.fontSize = 50;
    letter.fontColor = [UIColor whiteColor];
    letter.position = CGPointMake(-_whale.size.width/2 + 30, _whale.size.height/2 - 60);
    [_whale addChild:letter];
}

#pragma mark - Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self animateWhaleHooked];
}

#pragma mark - Utilities
-(SKSpriteNode *)createSpriteMatchingSKShapeNodeSize:(CGSize) size WithCornerRadius:(float)radius color:(SKColor *)color {
    CALayer *drawingLayer = [CALayer layer];
    CALayer *circleLayer = [CALayer layer];
    circleLayer.frame = CGRectMake(0,0,size.width,size.height);
    circleLayer.backgroundColor = color.CGColor;
    circleLayer.cornerRadius = radius;
    circleLayer.masksToBounds = YES;
    
    [drawingLayer addSublayer:circleLayer];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(circleLayer.frame.size.width, circleLayer.frame.size.height), NO, [UIScreen mainScreen].scale);
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), TRUE);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [UIColor clearColor].CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0,0,circleLayer.frame.size.width,circleLayer.frame.size.height));
    [drawingLayer renderInContext: UIGraphicsGetCurrentContext()];
    
    UIImage *layerImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:layerImage]];
    
    
    return sprite;
}

@end
