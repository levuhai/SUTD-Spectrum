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
#import "LPCAudioController.h"
#import "LPCView.h"

const uint32_t HOOK = 0x1 << 0;
const uint32_t FISHIES = 0x1 << 1;
const uint32_t BOUND = 0x1 << 2;

NSUInteger FISHTYPE = 0;
NSUInteger SHARKTYPE = 1;
NSUInteger WHALETYPE = 2;

#define speakingTimeOut 2
#define kCyclesPerSecond 0.25f
#define WaterViewHeigh 470 //460
#define FishBeingCaughtDestination 460

@interface FishingGameScene () <SKPhysicsContactDelegate> {
    SKSpriteNode* _hook;
    SKSpriteNode* _hookLine;
    SKSpriteNode* _potView;
    SKSpriteNode* _fishBeingCaught;
    SKSpriteNode* _pencil;
    
    BOOL didShowText;
    TCProgressTimerNode *_progressTimerNode3;
    NSTimeInterval _startTime;
    NSTimer *_drawTimer;
}

@property (nonatomic, strong) NSMutableArray *fishTypeArray;
@property (nonatomic, strong) NSMutableArray *fishArray;
@property (nonatomic, strong) NSArray *fishSwim;
@property (nonatomic, strong) NSArray *sharkSwim;
@property (nonatomic, strong) NSArray *whaleSwim;
@property (strong, nonatomic) LPCView *lpcView;

@end

@implementation FishingGameScene

- (void)didMoveToView:(SKView *)view {
    self.backgroundColor = RGB(66, 191, 254);
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    SKPhysicsBody *boundPhysicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.frame.size.width, FishBeingCaughtDestination)];
    boundPhysicsBody.categoryBitMask = BOUND;
    boundPhysicsBody.collisionBitMask = HOOK;
    boundPhysicsBody.contactTestBitMask = HOOK;
    self.physicsBody = boundPhysicsBody;

    [self setupGameScene];
    [self _setup];
    
    // LPC Graph
    float rectW = self.view.width/2;
    float rectH = self.view.height/4;
    CGRect LPCRect = CGRectMake((self.view.width-rectW)/2, self.view.height-rectH, rectW, rectH-20);
    self.lpcView = [[LPCView alloc] initWithFrame:LPCRect];
    self.lpcView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.lpcView.layer.cornerRadius = 20;
    self.lpcView.clipsToBounds = YES;
    
    [view addSubview:self.lpcView];
    [self _startDrawing];
}

- (void)_setup {
    
}

- (void) setupGameScene {
    //Static objects
    SKSpriteNode *waves = [SKSpriteNode spriteNodeWithImageNamed:@"waves"];
    waves.size = CGSizeMake(self.frame.size.width + 100, waves.size.height);
    waves.zPosition = -1;
    waves.position = CGPointMake(0, WaterViewHeigh);
    waves.anchorPoint = CGPointZero;
    [self addChild:waves];
    
    CGFloat cloudShiftXDelta = 100;
    SKSpriteNode *cloud = [SKSpriteNode spriteNodeWithImageNamed:@"cloud-1"];
    cloud.position = CGPointMake(-cloudShiftXDelta, self.frame.size.height - cloud.size.height - 10); // offset cloud y a bit
    cloud.anchorPoint = CGPointZero;
    [self addChild:cloud];
    
    SKAction *cloudMoveRightAction = [SKAction moveByX:self.frame.size.width+cloudShiftXDelta y:0 duration:120];
    SKAction *cloudResetAction = [SKAction moveByX:-self.frame.size.width-cloudShiftXDelta y:0 duration:0];
    SKAction *cloudAction = [SKAction repeatActionForever:[SKAction sequence:@[cloudMoveRightAction, cloudResetAction]]];
    [cloud runAction:cloudAction];
    
    CGFloat waveYDelta = 5;
    CGFloat waveXDelta = 100;
    CGFloat waveXMovementPeriod = 10;
    SKAction *wavesMoveUpAction = [SKAction moveByX:0 y:-waveYDelta duration:waveXMovementPeriod/2];
    SKAction *wavesMoveDownAction = [SKAction moveByX:0 y:waveYDelta duration:waveXMovementPeriod/2];
    SKAction *wavesUpDownAction = [SKAction sequence:@[wavesMoveUpAction, wavesMoveDownAction]];
    SKAction *wavesMoveRightAction = [SKAction moveByX:waveXDelta y:0 duration:waveXMovementPeriod];
    SKAction *wavesMoveLeftAction = [SKAction moveByX:-waveXDelta y:0 duration:waveXMovementPeriod];
    SKAction *wavesGroupRightAction = [SKAction group:@[wavesUpDownAction, wavesMoveRightAction]];
    SKAction *wavesGroupLeftAction = [SKAction group:@[wavesUpDownAction, wavesMoveLeftAction]];
    SKAction *wavesAction = [SKAction repeatActionForever:[SKAction sequence:@[wavesGroupLeftAction, wavesGroupRightAction]]];
    [waves runAction:wavesAction];

    // Water
    SKSpriteNode* waterView = [[SKSpriteNode alloc] initWithColor:RGB(58, 166, 221)
                                                             size:CGSizeMake(self.size.width, WaterViewHeigh)];
    waterView.anchorPoint = CGPointZero;
    waterView.position = CGPointZero;
    waterView.zPosition = -1;
    [self addChild:waterView];
    
    [self addParticalsAnimations];

    // Land
    SKSpriteNode* landView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"land-sand"]];
    landView.anchorPoint = CGPointMake(-1, 0);
    landView.position = CGPointMake(-150, WaterViewHeigh - 10);
    landView.zPosition = -2;
    [self addChild:landView];
    
    // The Sun
    SKSpriteNode* sunView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"thesun"]];
    sunView.anchorPoint = CGPointMake(0.5, 0.5);
    sunView.position = CGPointMake(self.size.width - 20, self.size.height - 20);
    sunView.zPosition = -3;
    [sunView runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:2*M_PI duration:60]]];
    [self addChild:sunView];
    
//    // turtle
//    SKSpriteNode* turtleView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"turtle"]];
//    turtleView.anchorPoint = CGPointMake(0, 0);
//    turtleView.position = CGPointMake(self.size.width - turtleView.size.width, WaterViewHeigh + 10);
//    [self addChild:turtleView];
    
    // pot
//    _potView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"fish-pot"]];
//    _potView.anchorPoint = CGPointMake(0.5, 0.5);
//    _potView.zPosition = 1;
//    _potView.position = CGPointMake(self.size.width - turtleView.size.width - _potView.size.width, WaterViewHeigh + _potView.size.height/2 + 5);
//    [self addChild:_potView];
    
    // bear
    SKSpriteNode* bearView = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"bear"]];
    bearView.anchorPoint = CGPointMake(0, 0);
    bearView.position = CGPointMake(self.size.width*0.5, WaterViewHeigh + 20);
    [self addChild:bearView];
    
    
    _pencil = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"pencil"]];
    _pencil.anchorPoint = CGPointMake(0, 0);
    _pencil.position = CGPointMake(bearView.position.x - _pencil.size.width/2, bearView.position.y);
    [self addChild:_pencil];
    
    // Dynamic objects
    // set up swimming fishes
    _fishSwim = [self swimmingFramesWithAtlasNamed:@"small_fish"];
    _sharkSwim = [self swimmingFramesWithAtlasNamed:@"shark"];
    _whaleSwim = [self swimmingFramesWithAtlasNamed:@"whale"];
    
    _fishArray = [@[] mutableCopy];
    _fishTypeArray = [@[] mutableCopy];
    [self generateRandomFish];
    
    
    // Hook
    // set up hook and hook line
    _hook = [SKSpriteNode spriteNodeWithImageNamed:@"buoy"];
    _hook.position = CGPointMake(_pencil.position.x, WaterViewHeigh);
    _hook.anchorPoint = CGPointMake(0.5, 0.0);
    [self addChild:_hook];
    SKPhysicsBody *hookPhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 10)];
    hookPhysicsBody.categoryBitMask = HOOK;
    hookPhysicsBody.collisionBitMask = BOUND;
    hookPhysicsBody.contactTestBitMask = FISHIES | BOUND;
    hookPhysicsBody.usesPreciseCollisionDetection = YES;
    _hook.physicsBody = hookPhysicsBody;
    
    _hookLine = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:CGSizeMake(2,(_pencil.position.y + _pencil.size.height) - (_hook.position.y + _hook.size.height) + 10)];
    _hookLine.anchorPoint = CGPointMake(0.5, 1.0);
    _hookLine.position = CGPointMake(_pencil.position.x, _pencil.position.y + _pencil.size.height);
    [self addChild:_hookLine];
    
    
    // bear thought
    [self bearThoughtAnimation:CGPointMake(bearView.position.x + bearView.size.width/2 + 20, bearView.position.y + bearView.size.height/2 + 20)];
}

- (void) addParticalsAnimations {
    
    CGPoint bubblesPosition = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame));
    [self addEmitterWithFileNamed:@"Bubbles" atPosition:bubblesPosition];
    
    CGFloat fishesXDelta = 50;
    CGPoint fishLeftPosition = CGPointMake(-fishesXDelta, CGRectGetMinY(self.frame));
    [self addEmitterWithFileNamed:@"FishLeft" atPosition:fishLeftPosition];
    CGPoint fishRightPosition = CGPointMake(CGRectGetMaxX(self.frame) + fishesXDelta, CGRectGetMinY(self.frame));
    [self addEmitterWithFileNamed:@"FishRight" atPosition:fishRightPosition];
    
    CGPoint sharkLeftPosition = CGPointMake(-fishesXDelta, CGRectGetMinY(self.frame));
    [self addEmitterWithFileNamed:@"SharkLeft" atPosition:sharkLeftPosition];
    CGPoint sharkRightPosition = CGPointMake(CGRectGetMaxX(self.frame) + fishesXDelta, CGRectGetMinY(self.frame));
    [self addEmitterWithFileNamed:@"SharkRight" atPosition:sharkRightPosition];
    
    CGPoint whaleLeftPosition = CGPointMake(-fishesXDelta, CGRectGetMinY(self.frame));
    [self addEmitterWithFileNamed:@"WhaleLeft" atPosition:whaleLeftPosition];
    CGPoint whaleRightPosition = CGPointMake(CGRectGetMaxX(self.frame) + fishesXDelta, CGRectGetMinY(self.frame));
    [self addEmitterWithFileNamed:@"WhaleRight" atPosition:whaleRightPosition];
}

- (void)addEmitterWithFileNamed:(NSString *)fileName atPosition:(CGPoint)position {
    SKEmitterNode *emitter = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"sks"]];
    emitter.position = position;
    [self addChild:emitter];
    
}

- (NSArray *)swimmingFramesWithAtlasNamed:(NSString *)atlasName {
    NSMutableArray *swimmingFrames = [@[] mutableCopy];
    SKTextureAtlas *animAtlas = [SKTextureAtlas atlasNamed:atlasName];
    for (int i = 1; i < animAtlas.textureNames.count; ++i) {
        NSString *tex = [NSString stringWithFormat:@"s%02d", i];
        [swimmingFrames addObject:[animAtlas textureNamed:tex]];
    }
    return swimmingFrames;
}

- (void) bearThoughtAnimation:(CGPoint) pos {
    
    if (_fishBeingCaught) {
        return;
    }
    
    __block SKSpriteNode* tb1 = [[SKSpriteNode alloc] initWithTexture:nil color:[UIColor whiteColor] size:CGSizeMake(5, 5)];
    tb1.position = CGPointMake(pos.x + 10, pos.y + 10);
    [self addChild:tb1];
    
    __block SKSpriteNode* tb2 = [[SKSpriteNode alloc] initWithTexture:nil color:[UIColor whiteColor] size:CGSizeMake(10, 10)];
    tb2.position = CGPointMake(pos.x + 20, pos.y + 20);
    [self addChild:tb2];
    
    __block SKSpriteNode* tb3 = [[SKSpriteNode alloc] initWithTexture:nil color:[UIColor whiteColor] size:CGSizeMake(20, 20)];
    tb3.position = CGPointMake(pos.x + 35, pos.y + 35);
    [self addChild:tb3];
    
    __block SKSpriteNode* tb4 = [[SKSpriteNode alloc] initWithTexture:nil color:[UIColor whiteColor] size:CGSizeMake(70, 35)];
    tb4.position = CGPointMake(pos.x + 60, pos.y + 60);
    [self addChild:tb4];
    
    __block SKSpriteNode* afish = [[SKSpriteNode alloc] initWithTexture:_fishSwim[0]];
    afish.position = CGPointMake(tb4.size.width/2, tb4.size.height/2);
    [tb4 addChild:afish];
    
    tb1.anchorPoint = tb2.anchorPoint = tb3.anchorPoint = tb4.anchorPoint = CGPointMake(0, 0);
    tb1.alpha = tb2.alpha = tb3.alpha = tb4.alpha = afish.alpha = 0;
    
    __weak FishingGameScene* weakSelf = self;
    
    [self shouldShowThoughtBox:YES with:tb1 :tb2 :tb3 :tb4 :afish completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf shouldShowThoughtBox:NO with:tb1 :tb2 :tb3 :tb4 :afish completion:^{
                [tb1 removeFromParent];
                tb1 = nil;
                [tb2 removeFromParent];
                tb2 = nil;
                [tb3 removeFromParent];
                tb3 = nil;
                [tb4 removeFromParent];
                tb4 = nil;
                [afish removeFromParent];
                afish = nil;
                
                [weakSelf bearThoughtAnimation:pos];
            }];
        });
    }];
}

- (void) shouldShowThoughtBox:(BOOL) value with:(SKSpriteNode*) tb1 :(SKSpriteNode*) tb2 :(SKSpriteNode*) tb3 :(SKSpriteNode*) tb4 :(SKSpriteNode*) afish completion:(void (^)())block {
    
    int alpha = value ? 1 : 0;
    
    [tb1 runAction:[SKAction fadeAlphaTo:alpha duration:0.2] completion:^{
        [tb1 runAction:[SKAction scaleTo:1.2 duration:0.1] completion:^{
            [tb1 runAction:[SKAction scaleTo:1.0 duration:0.2] completion:^{
                
                [tb2 runAction:[SKAction fadeAlphaTo:alpha duration:0.2] completion:^{
                    [tb2 runAction:[SKAction scaleTo:1.2 duration:0.1] completion:^{
                        [tb2 runAction:[SKAction scaleTo:1.0 duration:0.2] completion:^{
                            
                            [tb3 runAction:[SKAction fadeAlphaTo:alpha duration:0.2] completion:^{
                                [tb3 runAction:[SKAction scaleTo:1.2 duration:0.1] completion:^{
                                    [tb3 runAction:[SKAction scaleTo:1.0 duration:0.2] completion:^{
                                        
                                        [tb4 runAction:[SKAction fadeAlphaTo:alpha duration:0.2] completion:^{
                                            [tb4 runAction:[SKAction scaleTo:1.2 duration:0.1] completion:^{
                                                [tb4 runAction:[SKAction scaleTo:1.0 duration:0.2] completion:^{
                                                    
                                                    [afish runAction:[SKAction fadeAlphaTo:alpha duration:0.3] completion:^{
                                                        if (block)
                                                            block();
                                                    }];
                                                    
                                                }];
                                            }];
                                        }];
                                        
                                        
                                    }];
                                }];
                            }];
                            
                        }];
                    }];
                }];
                
                
            }];
        }];
    }];
}

#pragma mark generate random fish
- (void)generateRandomFish {
    // random fish swimming direction
    BOOL goingRight = arc4random() % 100 <= 50;
    // random fish type
    NSUInteger fishToWhale = arc4random() % (int)50;
    // default is small fish
    NSArray *swim = self.fishSwim;
    CGFloat fishAppearingYRangePercentage = 0.75;
    CGFloat duration = 100.0/12.5;//fishSwimmingSpeed
    CGFloat fishMouthXOffsetRatio = 0.9;
    CGFloat fishMouthYOffsetRatio = 0.5;
    NSUInteger fishTypeNum = FISHTYPE;
    CGFloat fishMouthHitTargetRadius = 6.0;//fishMouthHitTargetRadius
    
    if (fishToWhale == 0) {
        swim = self.whaleSwim;
        fishAppearingYRangePercentage = 0.2;
        duration = 100.0/4;//whaleSwimmingSpeed
        fishMouthXOffsetRatio = 0.93;
        fishMouthYOffsetRatio = 0.26;
        fishTypeNum = WHALETYPE;
        fishMouthHitTargetRadius = 6;//whaleMouthHitTargetRadius
    } else if (fishToWhale % 10 == 0) { // fishToSharkFrequency
        swim = self.sharkSwim;
        fishAppearingYRangePercentage = 0.6;
        duration = 100.0/8;//sharkSwimmingSpeed
        fishMouthXOffsetRatio = 0.97;
        fishMouthYOffsetRatio = 0.4;
        fishTypeNum = SHARKTYPE;
        fishMouthHitTargetRadius = 6;//sharkMouthHitTargetRadius
    }
    
    if (swim.count > 0) {
        SKSpriteNode *fish = [SKSpriteNode spriteNodeWithTexture:[swim firstObject]];
        fish.zPosition = 1;
        [self.fishArray addObject:fish];
        [self.fishTypeArray addObject:@(fishTypeNum)];
        fish.anchorPoint = CGPointMake(fishMouthXOffsetRatio, fishMouthYOffsetRatio);
        
        CGFloat fishAppearingXDelta = 200;
        CGFloat x = goingRight ? -fishAppearingXDelta : self.frame.size.width + fishAppearingXDelta;
        CGFloat yOffset = [swim[0] size].height / 2;
        int yInt = arc4random() % (int)(WaterViewHeigh * fishAppearingYRangePercentage) + yOffset;
        CGFloat y = (CGFloat)yInt;
        CGPoint fishLocation = CGPointMake(x, y);
        
        fish.position = fishLocation;
        [self addChild:fish];
        
        fish.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:fishMouthHitTargetRadius];
        fish.physicsBody.categoryBitMask = FISHIES;
        fish.physicsBody.collisionBitMask = 0;
        fish.physicsBody.contactTestBitMask = HOOK;
        fish.physicsBody.usesPreciseCollisionDetection = YES;
        
        const NSTimeInterval kFishAnimSpeed = 1 / 5.0;
        SKAction *fishSwimmingAction = [SKAction animateWithTextures:swim timePerFrame:kFishAnimSpeed];
        SKAction *fishSwimmingForeverAction = [SKAction repeatActionForever:fishSwimmingAction];
        [fish runAction:fishSwimmingForeverAction];
        
        NSUInteger deltaYInterval = 20;
        CGFloat deltaY = arc4random() % deltaYInterval - deltaYInterval / 2.0;
        CGFloat deltaX = 600;
        SKAction *fishMoveAction = goingRight ? [SKAction moveByX:self.frame.size.width + deltaX y:deltaY duration:duration] : [SKAction moveByX:-1 * (self.frame.size.width + deltaX) y:deltaY duration:duration];
        if (!goingRight) {
            fish.xScale = -1;
        }
        __weak FishingGameScene *slf = self;
        [fish runAction:fishMoveAction completion:^{
            [fish removeFromParent];
            NSUInteger index = [slf.fishArray indexOfObject:fish];
            if (index != NSNotFound && index < slf.fishTypeArray.count) {
                [slf.fishArray removeObjectAtIndex:index];
                [slf.fishTypeArray removeObjectAtIndex:index];
            }
        }];
    }
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(generateRandomFish) userInfo:nil repeats:NO];
}

#pragma mark - Game play

- (void) animateCountDownCircle {
    
    _progressTimerNode3 = [[TCProgressTimerNode alloc] initWithForegroundImageNamed:@"progress_foreground"
                                                               backgroundImageNamed:@"progress_background"
                                                                accessoryImageNamed:@"progress_accessory"];
    _progressTimerNode3.position = CGPointMake(_hook.position.x, _hook.position.y + 50);
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
            //[self animateCatchAWhale];
        } else {
            //[self animateWhaleBack];
        }
    });

}

- (void) processAudio {

}

- (void) addLetterToWhale {
    SKLabelNode* letter = [SKLabelNode node];
    //letter.fontName = @"Arial-Bold";
    letter.text = @"T";
    letter.fontSize = 50;
    letter.fontColor = [UIColor whiteColor];
    //letter.position = CGPointMake(-_whale.size.width/2 + 30, _whale.size.height/2 - 60);
    //[_whale addChild:letter];
}
#pragma mark - Points

- (void) getPoint {
    [self resultTrackingWithLetter:@"t" isCorrect:YES];
}

- (void) resultTrackingWithLetter:(NSString*) letter isCorrect:(BOOL) correct {
    
    
    NSArray* dates = @[[NSDate beginningOfToday],[NSDate endOfToday]];
    GameStatistics* stat = [GameStatistics getGameStatFromLetter:letter between:dates];
    
    if (stat == nil) {
        stat = [GameStatistics MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        stat.gameId  = @(1);
        stat.letter = letter;
        stat.totalPlayedCount = @(1);
        stat.correctCount = correct ? @(1) : @(0);
        stat.dateAdded = [NSDate date];
    } else {
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            //GameStatistics *localStat = [stat MR_inContext:localContext];
            stat.gameId  = @(1);
            stat.letter = letter;
            stat.totalPlayedCount = @(stat.totalPlayedCount.integerValue + 1);
            if (correct) {
                stat.correctCount = @(stat.correctCount.integerValue + 1);
            }
            stat.dateAdded = [NSDate date];

            
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

#pragma mark hook actions
- (void)dropHook {
    [_hook removeActionForKey:@"hook"];
    [_hookLine removeActionForKey:@"hookline"];
    CGFloat hookMovementDeltaY = 20;
    SKAction *hookGoingDownOnceAction = [SKAction moveByX:0 y:-hookMovementDeltaY duration:1.0/(float)3.0f];
    SKAction *hookGoingDownAction = [SKAction repeatActionForever:hookGoingDownOnceAction];
    [_hook runAction:hookGoingDownAction withKey:@"hook"];
    SKAction *hookLineOnceAction = [SKAction resizeByWidth:0 height:hookMovementDeltaY duration:1.0/(float)3.0f];
    SKAction *hookLineAction = [SKAction repeatActionForever:hookLineOnceAction];
    [_hookLine runAction:hookLineAction withKey:@"hookline"];
}

- (void)raiseHook {
    [_hook removeActionForKey:@"hook"];
    [_hookLine removeActionForKey:@"hookline"];
    if (_hook.position.y > WaterViewHeigh) {
        return;
    }
    CGFloat hookMovementDeltaY = 20.0f;
    SKAction *hookGoingUpOnceAction = [SKAction moveByX:0 y:hookMovementDeltaY duration:1/6.0f];
    int count = ceilf((FishBeingCaughtDestination - _hook.position.y)/hookMovementDeltaY);
    
    SKAction *hookGoingUpAction = [SKAction repeatAction:hookGoingUpOnceAction count:(int)count];
    [_hook runAction:hookGoingUpAction withKey:@"hook"];
    SKAction *hookLineOnceAction = [SKAction resizeByWidth:0 height:-hookMovementDeltaY duration:1/6.0f];
    SKAction *hookLineAction = [SKAction repeatAction:hookLineOnceAction count:(int)count];
    [_hookLine runAction:hookLineAction withKey:@"hookline"];
}

#pragma mark touch events callback
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_fishBeingCaught)
        return;
    [_pencil runAction:[SKAction rotateByAngle:0.3 duration:0.3]];
    [_pencil runAction:[SKAction moveByX:15 y:-10 duration:0.3]];
    
    [self dropHook];
    [_hook runAction:[SKAction moveByX:-10 y:-15 duration:0.3]];
    [_hookLine runAction:[SKAction moveByX:-10 y:-15 duration:0.3]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_fishBeingCaught)
        return;
    [_pencil runAction:[SKAction rotateByAngle:-0.3 duration:0.3]];
    [_pencil runAction:[SKAction moveByX:-15 y:10 duration:0.3]];
    
    
    [self raiseHook];
    [_hook runAction:[SKAction moveByX:10 y:15 duration:0.3]];
    [_hookLine runAction:[SKAction moveByX:10 y:15 duration:0.3]];
}

#pragma mark contact delegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    // hook going out of bound
    if ((contact.bodyA.node == self.scene && contact.bodyB.node == _hook) ||
        (contact.bodyB.node == self.scene && contact.bodyA.node == _hook)) {
        //[_hook removeAllActions];
        //[_hookLine removeAllActions];
        
        NSLog(@"ctp : %f",contact.contactPoint.y);
        
        if (contact.contactPoint.y >= FishBeingCaughtDestination - 100) { // if at the top
            if (_fishBeingCaught) {
                [self showSpeakBubbleAt:_fishBeingCaught.position];
            }
        }
        return;
    }
    if (_fishBeingCaught)
        return;
    
    // check if caught a fish
    SKSpriteNode *fish = nil;
    if ([self.fishArray containsObject:contact.bodyA.node]) {
        fish = (SKSpriteNode *)contact.bodyA.node;
    } else if ([self.fishArray containsObject:contact.bodyB.node]) {
        fish = (SKSpriteNode *)contact.bodyB.node;
    }
    if (fish) {
        _fishBeingCaught = fish;
        [self raiseHook];
        [fish removeAllActions];
        
        // put the fish onto the hook
        CGFloat rotateAngle = 0.5 * M_PI;
        if (fish.xScale == -1) {
            rotateAngle = -0.5 * M_PI;
        }
        // raise the hook
        SKAction *fishToHookTranslationAction = [SKAction moveTo:_hook.position duration:0];
        SKAction *fishToHookRotationAction = [SKAction rotateByAngle:rotateAngle duration:1/6.0f];
        SKAction *fishToHookAction = [SKAction group:@[fishToHookTranslationAction, fishToHookRotationAction]];
        
        SKAction *followHookOnceAction = [SKAction moveByX:0 y:20 duration:1/6.0f];
        int count = ceilf((FishBeingCaughtDestination-fish.position.y)/20);
        SKAction *followHookAction = [SKAction repeatAction:followHookOnceAction count:count];
        SKAction *fishActions = [SKAction group:@[fishToHookAction, followHookAction]];
        [fish runAction:fishActions];
        
    }
}

- (void) showSpeakBubbleAt:(CGPoint) pos {
    SKSpriteNode* bubble = [[SKSpriteNode alloc] initWithTexture:[SKTexture textureWithImageNamed:@"speakbubble"]];
    bubble.position = CGPointMake(pos.x - bubble.size.width/2 - 15, pos.y + bubble.size.height/2 + 15);
    
    SKLabelNode* text = [SKLabelNode node];
    text.text = @"good";
    text.fontName = @"HelveticaNeue-Bold";
    text.fontColor = [UIColor redColor];
    text.fontSize = 50;
    text.zPosition = 10;
    [bubble addChild:text];
    [self addChild:bubble];
}

- (void) throwCaughtFish {
    if (_fishBeingCaught) {
        [_fishBeingCaught removeAllActions];
        
        // show fish thrown away animation
        SKAction *fishThrownAwayTraslateAction = [SKAction moveByX:150 y:150 duration:0.5];
        SKAction *fishThrownAwayRotateAction = [SKAction rotateByAngle:-M_PI duration:0.5];
        SKAction *fishThrownAwayAction = [SKAction group:@[fishThrownAwayTraslateAction, fishThrownAwayRotateAction]];
        __weak FishingGameScene *slf = self;
        [_fishBeingCaught runAction:fishThrownAwayAction completion:^{
            [_fishBeingCaught removeFromParent];
            NSUInteger index = [slf.fishArray indexOfObject:_fishBeingCaught];
            if (index != NSNotFound && index < slf.fishTypeArray.count) {
                switch ([slf.fishTypeArray[index] integerValue]) {
                    case 0: // fish
                        //slf.score += FISHSCORE;
                        break;
                    case 1: // shark
                        //slf.score += SHARKSCORE;
                        break;
                    case 2: // whale
                        //slf.score += WHALESCORE;
                        break;
                    default:
                        break;
                }
                [slf.fishArray removeObjectAtIndex:index];
                [slf.fishTypeArray removeObjectAtIndex:index];
            }
            _fishBeingCaught = nil;
        }];
    }
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

#pragma mark - LPC

- (void)_startDrawing {
    // Start LPC Instance
    [[LPCAudioController sharedInstance] start];
    
    if (!_drawTimer) {
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval: 1/50
                                                      target: self
                                                    selector: @selector(_drawGraph)
                                                    userInfo: nil
                                                     repeats: YES];
    }
}

- (void)_stopDrawing {
    // Stop LPC Instance
    [[LPCAudioController sharedInstance] stop];
    
    // Invalidate Timer
    [_drawTimer invalidate];
    _drawTimer = nil;
}

- (void)_drawGraph {
    // LPC
    [self.lpcView refresh];
}

@end
