//
//  NSMutableArray+Queue.m
//  FIFO
//
//  Created by Mr.J on 6/6/15.
//  Copyright (c) 2015 ___NhuanQuang___. All rights reserved.
//

#import "NSMutableArray+Queue.h"
#import <objc/runtime.h>

@implementation NSMutableArray (Queue)

// Queues are first-in-first-out, so we remove objects from the head
static char maxItemKey;
- (id) dequeue {
    // if ([self count] == 0) return nil; // to avoid raising exception (Quinn)
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        headObject = nil;
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

- (void)setMaxItem:(NSUInteger)max{
    objc_setAssociatedObject(self, &maxItemKey, [NSNumber numberWithInteger:max], OBJC_ASSOCIATION_RETAIN);
}
- (NSUInteger)maxItem{
    return [objc_getAssociatedObject( self, &maxItemKey ) intValue];
}
- (instancetype)initWithMaxItem:(int)max{
    self = [[NSMutableArray alloc]init];
    if (self) {
        [self setMaxItem:max];
    }
    return self;
}
// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) enqueue:(id)anObject {
    [self addObject:anObject];
    //this method automatically adds to the end of the array
}
- (void)addItem:(id)anItem{
    if (self.count == self.maxItem) {
        [self dequeue];
    }
    [self enqueue:anItem];
}
@end
