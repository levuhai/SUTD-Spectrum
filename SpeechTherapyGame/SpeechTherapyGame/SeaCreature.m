//
//  SeaCreature.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/21/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "SeaCreature.h"
#import "Spawner.h"

#define kActionSwimmingKey "swimming"

@implementation SeaCreature

@synthesize bodyNode,movementSpeed,weight;


-(void) setup {
    
}

-(CGPoint) setDestination {
    deltaX = 0, deltaY = 0;
    
    switch (movementDirection) {
        case 1:
            rotation = 0;
            deltaY = kTileWidth;
            break;
        case 2:
            deltaX = kTileWidth;
            rotation = -M_PI/2;
            break;
        case 3:
            deltaY = -kTileWidth;
            rotation = M_PI;
            break;
        case 4:
            deltaX = -kTileWidth;
            rotation = M_PI/2;
            break;
    }
    
    //destination = CGPointMake(self.position.x+deltaX, self.position.y+deltaY);
    //NSLog(@"destination: %f,%f",destination.x,destination.y);
    
    return CGPointMake(self.position.x+deltaX, self.position.y+deltaY);
}


- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(void) startSwimmingInDirection: (int)_movementDirection {
    movementDirection = _movementDirection;
    
    [self setDestination];
    
    SKAction *unitDestinationAction = [SKAction runBlock:(dispatch_block_t)^() {
        //NSLog(@"arrived at destination: %f,%f",self.position.x,self.position.y);
        //[self setDestination];
    }];
    
    //SKAction* unitRotateAction = [SKAction rotateToAngle:rotation duration:0.1 shortestUnitArc:YES];
    //[self runAction:unitRotateAction];
    
    float variedSpeed = [self randomValueBetween:1.40 andValue:2.60]*movementSpeed;
    
    SKAction *unitMoveAction = [SKAction moveByX:deltaX y:deltaY duration:variedSpeed];
    
    
    // transform body to match direction
    // assume creature facing right
    if (movementDirection==4) {
        bodyNode.xScale = -(sizeRatio);
    } else {
        bodyNode.xScale = sizeRatio;
    }
    // TODO angle body if moving up or down???
    
    SKAction* movementSequence = [SKAction sequence:@[unitMoveAction,unitDestinationAction]];
    SKAction *movementLoop = [SKAction repeatActionForever:movementSequence];
    
    [self runAction:movementLoop withKey:@kActionSwimmingKey];
    
}


-(void) wrapMovement {
    
    float sceneWidth = self.scene.size.width;
    float sceneHeight = self.scene.size.height;
    
    float offscreenPadding = bodyNode.size.width/2;
    
    //NSLog(@"fish x: %f",self.position.x);
    
    bool isOffscreenRight = (self.position.x>sceneWidth+offscreenPadding+1);
    bool isOffscreenLeft = (self.position.x<-offscreenPadding-1);
    bool isOffscreenTop = (self.position.y>sceneHeight+offscreenPadding+1);
    bool isOffscreenBottom = (self.position.y<-offscreenPadding-1);
    
    if (isOffscreenTop || isOffscreenRight || isOffscreenBottom || isOffscreenLeft) {
        
        [self removeActionForKey:@kActionSwimmingKey];
        
        if (isOffscreenTop) {
            self.position = CGPointMake(self.position.x,-offscreenPadding);
            [self startSwimmingInDirection:1];
            
        } else if (isOffscreenRight) {
            self.position = CGPointMake(sceneWidth+offscreenPadding,self.position.y);
            [self startSwimmingInDirection:4];
            
        } else if (isOffscreenBottom) {
            //self.position = CGPointMake(self.position.x,sceneHeight+offscreenPadding);
            //[self startSwimmingInDirection:3];
            
            
            // remove fish if moving down
            // it has eaten and and will not be lured again
            
            [_spawner removeCreature:self];
            
        } else if (isOffscreenLeft) {
            self.position = CGPointMake(-offscreenPadding,self.position.y);
            [self startSwimmingInDirection:2];
        }
    }
    
}

- (void) beingCaughtAnimationByHook:(SKSpriteNode*) hook {
    
    [self removeAllActions];
    
    CGFloat rotateAngle = 0.5 * M_PI;
    if (bodyNode.xScale == -1) {
        rotateAngle = -0.5 * M_PI;
    }
    // raise the hook
    SKAction *fishToHookTranslationAction = [SKAction moveTo:CGPointMake(hook.position.x, hook.position.y - bodyNode.size.width/2) duration:0];
    SKAction *fishToHookRotationAction = [SKAction rotateByAngle:rotateAngle duration:1/8.0f];
    SKAction *fishToHookAction = [SKAction group:@[fishToHookTranslationAction, fishToHookRotationAction]];
    
    SKAction *followHookOnceAction = [SKAction moveByX:0 y:hookMovementDeltaY duration:1/hookRaiseSpeed];
    int count = ceilf((yHookStart-self.position.y)/hookMovementDeltaY);
    SKAction *followHookAction = [SKAction repeatAction:followHookOnceAction count:count];
    SKAction *fishActions = [SKAction group:@[fishToHookAction, followHookAction]];
    [self runAction:fishActions];
}

@end
