//
//  TCProgressTimerNode.m
//  TCProgressTimerDemo
//
//  Created by Tony Chamblee on 11/17/13.
//  Copyright (c) 2013 Tony Chamblee. All rights reserved.
//

#import "TCProgressTimerNode.h"
#import "TCProgressTimerForegroundCropNode.h"

@interface TCProgressTimerNode ()

@property (nonatomic, strong) SKSpriteNode *backgroundImageSpriteNode;
@property (nonatomic, strong) TCProgressTimerForegroundCropNode *foregroundCropNode;
@property (nonatomic, strong) SKSpriteNode *accessorySpriteNode;

@end

@implementation TCProgressTimerNode

#pragma mark - Properties

- (void)setProgress:(CGFloat)progress
{
    if (_progress != progress)
    {
        _progress = progress;
        
        [self didUpdateProgress];
    }
}

#pragma mark - Init / Dealloc

- (instancetype)initWithForegroundImageNamed:(NSString *)foregroundImageName
                        backgroundImageNamed:(NSString *)backgroundImageName
                         accessoryImageNamed:(NSString *)accessoryImageName
{
    SKTexture *backgroundTexture = nil;
    SKTexture *foregroundTexture = nil;
    SKTexture *accessoryTexture = nil;
    
    if (backgroundImageName)
    {
        backgroundTexture = [SKTexture textureWithImageNamed:backgroundImageName];
    }
    
    if (foregroundImageName)
    {
        foregroundTexture = [SKTexture textureWithImageNamed:foregroundImageName];
    }
    
    if (accessoryImageName)
    {
        accessoryTexture = [SKTexture textureWithImageNamed:accessoryImageName];
    }
    
    return [self initWithForegroundTexture:foregroundTexture
                         backgroundTexture:backgroundTexture
                          accessoryTexture:accessoryTexture];
}


- (instancetype)initWithForegroundTexture:(SKTexture *)foregroundTexture
                        backgroundTexture:(SKTexture *)backgroundTexture
                         accessoryTexture:(SKTexture *)accessoryTexture
{
    if (!foregroundTexture)
    {
        NSAssert(NO, @"Error - must be initialized with foreground texture.");
        return nil;
    }
    
    self = [super init];
    
    if (self)
    {
        [self initializeBackgroundImageSpriteNodeWithTexture:backgroundTexture];
        [self initializeForegroundCropNodeWithTexture:foregroundTexture];
        [self initializeAccessorySpriteNodeWithTexture:accessoryTexture];
    }
    
    return self;
}

- (instancetype)initWithRadius:(CGFloat)radius
               backgroundColor:(UIColor *)backgroundColor
               foregroundColor:(UIColor *)foregroundColor
{
    SKTexture *backgroundTexture = [self textureFromLayer:[self circleShapeLayerWithRadius:radius color:backgroundColor]];
    SKTexture *foregroundTexture = [self textureFromLayer:[self circleShapeLayerWithRadius:radius color:foregroundColor]];
    
    return [self initWithForegroundTexture:foregroundTexture backgroundTexture:backgroundTexture accessoryTexture:nil];
}

#pragma mark - Shape Layer Creation

- (CAShapeLayer *)circleShapeLayerWithRadius:(CGFloat)radius color:(UIColor *)color
{
    CAShapeLayer *shapeLayer = [CAShapeLayer new];
    
    shapeLayer.frame = CGRectMake(0.0, 0.0, radius * 2, radius * 2);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                              radius:radius startAngle:0
                                                            endAngle:2 * M_PI
                                                           clockwise:YES];
    
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = 0.0;
    shapeLayer.fillColor = color.CGColor;
    
    return shapeLayer;
}

#pragma mark - Texture Creation

- (SKTexture *)textureFromLayer:(CALayer *)layer
{
    CGFloat width = layer.frame.size.width;
    CGFloat height = layer.frame.size.height;
    
    // value of 0 for scale will use device's main screen scale
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, width, height));
    
    [layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    SKTexture *texture = [SKTexture textureWithImage:image];
    
    return texture;
}

#pragma mark - Initialization

- (void)initializeBackgroundImageSpriteNodeWithTexture:(SKTexture *)backgroundTexture
{
    if (backgroundTexture)
    {
        _backgroundImageSpriteNode = [SKSpriteNode spriteNodeWithTexture:backgroundTexture];
        _backgroundImageSpriteNode.zPosition = 1;
        [self addChild:_backgroundImageSpriteNode];
    }
}

- (void)initializeForegroundCropNodeWithTexture:(SKTexture *)foregroundTexture
{
    _foregroundCropNode = [[TCProgressTimerForegroundCropNode alloc] initWithTexture:foregroundTexture];
    _foregroundCropNode.zPosition = 2;
    [self addChild:_foregroundCropNode];
}

- (void)initializeAccessorySpriteNodeWithTexture:(SKTexture *)accessoryTexture
{
    if (accessoryTexture)
    {
        _accessorySpriteNode = [SKSpriteNode spriteNodeWithTexture:accessoryTexture];
        _accessorySpriteNode.zPosition = 3;
        [self addChild:_accessorySpriteNode];
    }
}

#pragma mark - Progress Update

- (void)didUpdateProgress
{
    [self.foregroundCropNode setProgress:self.progress];
}

@end
