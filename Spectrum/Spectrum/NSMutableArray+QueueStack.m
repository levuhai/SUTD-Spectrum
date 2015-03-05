//
//  NSMutableArray+QueueStack.m
//  Spectrum
//
//  Created by Hai Le on 29/6/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import "NSMutableArray+QueueStack.h"

@implementation NSMutableArray (QueueStack)

//Stacks are last-in-first-out.
-(id)stackPop {
    id lastObject = [self lastObject];
    
    if (lastObject)
        [self removeLastObject];
    
    return lastObject;
}

-(void)stackPush:(id)obj {
    [self insertObject:obj atIndex: 0];
}

@end
