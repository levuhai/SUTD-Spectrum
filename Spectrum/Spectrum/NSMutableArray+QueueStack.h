//
//  NSMutableArray+QueueStack.h
//  Spectrum
//
//  Created by Hai Le on 29/6/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueStack)

-(id)stackPop;
-(void)stackPush:(id)obj;

@end
