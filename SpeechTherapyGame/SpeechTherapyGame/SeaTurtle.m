//
//  SMSeaTurtle.m
//  sushi-master
//
//  Created by Michael Garrido on 3/16/14.
//  Copyright (c) 2014 PRZM. All rights reserved.
//

#import "SeaTurtle.h"

@implementation SeaTurtle

-(id) init
{
    self = [super init];
    
    if (self)
    {
        NSLog(@"init sea turtle");

        movementSpeed = 0.1; // time to move 1 tile width
        
        float creatureWidth = turtleWidth;
        float creatureHeight = turtleHeight;

        self.name = @nodeNameTurtle;
        self.zPosition = zOceanForeground;
        
        //[self updateBody];
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(creatureWidth, creatureHeight)];
        
        self.physicsBody.categoryBitMask = bitmaskCategoryCreature;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.collisionBitMask = bitmaskCategoryNeutral;
        self.physicsBody.contactTestBitMask = bitmaskCategoryHook | bitmaskCategoryChum;
        
        self.physicsBody.dynamic = NO;
        self.physicsBody.restitution = 0.2;
        self.physicsBody.mass = 5;
         

        SKSpriteNode* newBody = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@fileTurtle] size:CGSizeMake(creatureWidth, creatureHeight)];

        sizeRatio = 1.0;
        bodyNode = newBody;
        
        [self addChild:bodyNode];
    }
    
    return self;
    
}

-(void) setup {
    
}

-(void)swimmingLoop
{
    SKTextureAtlas *fishSwimmingAtlas = [SKTextureAtlas atlasNamed:@"seaturtle"];
    
    NSArray *swimFrames = @[[fishSwimmingAtlas textureNamed:@"seaturtle1"],
                            [fishSwimmingAtlas textureNamed:@"seaturtle2"],
                            [fishSwimmingAtlas textureNamed:@"seaturtle3"],
                            [fishSwimmingAtlas textureNamed:@"seaturtle4"],
                            [fishSwimmingAtlas textureNamed:@"seaturtle5"],
                            [fishSwimmingAtlas textureNamed:@"seaturtle4"],
                            [fishSwimmingAtlas textureNamed:@"seaturtle3"],
                            [fishSwimmingAtlas textureNamed:@"seaturtle2"]];
    
    //NSLog(@"swim frames: %@",swimFrames);
    
    [bodyNode runAction:[SKAction repeatActionForever:
                         [SKAction animateWithTextures:swimFrames
                                          timePerFrame:0.2f
                                                resize:NO
                                               restore:YES]] withKey:@"swimming"];
    return;
}

-(void) startSwimmingInDirection:(int)_movementDirection {
    [super startSwimmingInDirection:_movementDirection];
    [self swimmingLoop];
}

@end
