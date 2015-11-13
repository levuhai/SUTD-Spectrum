//
//  FishingGameScene.m
//  SpeechTherapyGame
//
//  Created by Vit on 10/15/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "FishingGameScene.h"
#import "FishingGameViewController.h"
#import "TCProgressTimerNode.h"
#import "Whale.h"


#define speakingTimeOut 2
#define kCyclesPerSecond 0.25f
#define WaterViewHeigh 460

@interface FishingGameScene () {
    Whale* _whale;
    SKSpriteNode* _buoy;
    SKSpriteNode* _potView;
    
    BOOL didShowText;
    TCProgressTimerNode *_progressTimerNode3;
    NSTimeInterval _startTime;
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
    _potView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"fish-pot"]];
    _potView.anchorPoint = CGPointMake(0.5, 0.5);
    _potView.zPosition = 1;
    _potView.position = CGPointMake(self.size.width - turtleView.size.width - _potView.size.width, WaterViewHeigh + _potView.size.height/2 + 5);
    [self addChild:_potView];
    
    // bear
    SKSpriteNode* bearView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"pencil-bear"]];
    bearView.anchorPoint = CGPointMake(0, 0);
    bearView.position = CGPointMake(self.size.width - bearView.size.width - 300, WaterViewHeigh + 20);
    [self addChild:bearView];
    
    // Dynamic objects
    // ProgressBar
    
//    _progressBar = [self createSpriteMatchingSKShapeNodeSize:CGSizeMake(self.size.width/3, 32) WithCornerRadius:16 color:[UIColor whiteColor]];
//    _progressBar.position = CGPointMake(self.size.width - _progressBar.size.width*1.5, self.size.height - _progressBar.size.height);
//    [self addChild:_progressBar];
//    
//    SKSpriteNode* n = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(100, 100)];
//    n.position = CGPointZero;
//    n.zPosition = 1;
//    [_progressBar addChild:n];
    
    // Buoy
    _buoy = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"buoy"]];
    _buoy.anchorPoint = CGPointMake(0.5, 0.5);
    _buoy.position = CGPointMake(2*self.size.width/5, WaterViewHeigh);
    [self addChild:_buoy];
    [_buoy runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:3 duration:0.5], [SKAction moveByX:0 y:-3 duration:0.5]]]]];
    
    SKShapeNode *yourline = [SKShapeNode node];
    CGMutablePathRef pathToDraw = CGPathCreateMutable();
    CGPathMoveToPoint(pathToDraw, NULL, bearView.position.x, bearView.position.y+bearView.size.height/2+25);
    CGPathAddLineToPoint(pathToDraw, NULL, _buoy.position.x, _buoy.position.y);
    yourline.path = pathToDraw;
    [yourline setStrokeColor:[SKColor darkGrayColor]];
    [self addChild:yourline];
    [yourline runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:3 duration:0.5], [SKAction moveByX:0 y:-3 duration:0.5]]]]];
    
    
    // Whale
    _whale = [[Whale alloc] init];
    _whale.anchorPoint = CGPointMake(0.5, 0.5);
    _whale.position = CGPointMake(5, WaterViewHeigh);
    [self addChild:_whale];
    [_whale runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction moveByX:0 y:-10 duration:0.5], [SKAction moveByX:0 y:10 duration:0.5]]]]];
    
}

- (void) animateCountDownCircle {
    
    _progressTimerNode3 = [[TCProgressTimerNode alloc] initWithForegroundImageNamed:@"progress_foreground"
                                                               backgroundImageNamed:@"progress_background"
                                                                accessoryImageNamed:@"progress_accessory"];
    _progressTimerNode3.position = CGPointMake(_buoy.position.x, _buoy.position.y + 50);
    [self addChild:_progressTimerNode3];
    _progressTimerNode3.progress = 0.0;
    _startTime = CACurrentMediaTime();
    [_progressTimerNode3 setScale:2];
    
    // After countdown
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(speakingTimeOut * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self processAudio];
        if (_progressTimerNode3) {
            [_progressTimerNode3 removeFromParent];
            _progressTimerNode3 = nil;
        }
        if (/* DISABLES CODE */ (YES)) {
            [self animateCatchAWhale];
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

- (void) animateCatchAWhale {
    // Animate flying whale
    SKSpriteNode* flyingWhale = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"whale-no-text"] color:[UIColor clearColor] size:CGSizeMake(152, 115)];
    flyingWhale.zPosition = _potView.zPosition - 1;
    flyingWhale.position = _whale.position;
    [self addChild:flyingWhale];
    
    // Move up and down
    [flyingWhale runAction:[SKAction sequence:@[[SKAction moveByX:(_potView.position.x - _whale.position.x)/2 y:200 duration:0.5],[SKAction moveByX:(_potView.position.x - _whale.position.x)/2 y:-200 duration:0.5]]] completion:^{
        // Get point!
        [self getPoint];
    }];
    // Move to the pot
    // Scale down
    [flyingWhale runAction:[SKAction scaleTo:0.1 duration:1] completion:^{
        [_whale runAction:[SKAction fadeAlphaTo:1 duration:0.3]];
        [flyingWhale removeFromParent];
    }];
    
    
    [_whale runAction:[SKAction fadeAlphaTo:0 duration:0.3] completion:^{
        // Silently move whale to the start position
        [_whale runAction:[SKAction moveTo:CGPointMake(5, WaterViewHeigh) duration:0] completion:^{
            // Show count down
            [_whale removeAllChildren];
            didShowText = NO;
        }];
    }];
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
#pragma mark - Points

- (void) getPoint {
    [self resultTrackingWithLetter:@"t" isCorrect:YES];
}

- (void) resultTrackingWithLetter:(NSString*) letter isCorrect:(BOOL) correct {
    
    NSDate* today = [[NSDate date] beginningOfDay];
    GameStatistics* stat = [GameStatistics getGameStatFromLetter:letter andDate:today];
    
    if (stat == nil) {
        stat = [GameStatistics MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        stat.gameId  = @(1);
        stat.letter = letter;
        stat.totalPlayedCount = @(1);
        stat.correctCount = correct ? @(1) : @(0);;
        stat.dateAdded = today;
    } else {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            //GameStatistics *localStat = [stat MR_inContext:localContext];
            stat.gameId  = @(1);
            stat.letter = letter;
            stat.totalPlayedCount = @(stat.totalPlayedCount.integerValue + 1);
            if (correct) {
                stat.correctCount = @(stat.correctCount.integerValue + 1);
            }
            stat.dateAdded = today;

            
        } completion:^(BOOL contextDidSave, NSError *error) {
            NSLog(@"Error: %@",error);
        }];
    }
}

#pragma mark - Update
- (void)update:(NSTimeInterval)currentTime
{
    [super update:currentTime];
    
    CGFloat secondsElapsed = currentTime - _startTime;
    CGFloat cycle = secondsElapsed * kCyclesPerSecond;
    CGFloat progress = cycle - (NSInteger)cycle;
    
    _progressTimerNode3.progress = progress;
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
