//
//  SMSeaTurtle.m
//  sushi-master
//
//  Created by Michael Garrido on 3/16/14.
//  Copyright (c) 2014 PRZM. All rights reserved.
//

#import "SeaFish.h"

@implementation SeaFish

-(id) init
{
    self = [super init];
    
    if (self)
    {
        NSLog(@"init sea fish");

        movementSpeed = 0.15; // time to move 1 tile width
        
        float creatureWidth = fishAwidth;
        float creatureHeight = fishAheight;

        self.name = @nodeNameFish;
        self.zPosition = zOceanForeground;
        
        //[self updateBody];
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(creatureWidth*fishAContactSizeRatio, creatureHeight*fishAContactSizeRatio)];
        
        self.physicsBody.categoryBitMask = bitmaskCategoryCreature;
        self.physicsBody.allowsRotation = NO;
        self.physicsBody.collisionBitMask = bitmaskCategoryNeutral;
        self.physicsBody.contactTestBitMask = bitmaskCategoryHook | bitmaskCategoryChum;
        
        self.physicsBody.dynamic = YES;
        self.physicsBody.restitution = 0.2;
        self.physicsBody.mass = 5;
         

        SKSpriteNode* newBody = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@fileFish] size:CGSizeMake(creatureWidth, creatureHeight)];
        newBody.color = [SKColor randomFlatColor];
        newBody.colorBlendFactor = 1.0f;

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
    SKTextureAtlas *fishSwimmingAtlas = [SKTextureAtlas atlasNamed:@"fish"];
    
    NSArray *swimFrames = @[[fishSwimmingAtlas textureNamed:@"fish1"],
                            [fishSwimmingAtlas textureNamed:@"fish2"],
                            [fishSwimmingAtlas textureNamed:@"fish3"]];
    
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
