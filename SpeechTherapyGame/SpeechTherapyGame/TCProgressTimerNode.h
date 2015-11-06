//
//  TCProgressTimerNode.h
//  TCProgressTimerDemo
//
//  Created by Tony Chamblee on 11/17/13.
//  Copyright (c) 2013 Tony Chamblee. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface TCProgressTimerNode : SKNode

@property (nonatomic) CGFloat progress;

- (instancetype)initWithForegroundImageNamed:(NSString *)foregroundImageName
                        backgroundImageNamed:(NSString *)backgroundImageName
                         accessoryImageNamed:(NSString *)accessoryImageName;

- (instancetype)initWithForegroundTexture:(SKTexture *)foregroundTexture
                        backgroundTexture:(SKTexture *)backgroundTexture
                         accessoryTexture:(SKTexture *)accessoryTexture;

- (instancetype)initWithRadius:(CGFloat)radius
               backgroundColor:(UIColor *)backgroundColor
               foregroundColor:(UIColor *)foregroundColor;

@end
