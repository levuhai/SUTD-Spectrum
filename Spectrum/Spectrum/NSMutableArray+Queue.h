//
//  NSMutableArray+Queue.h
//  FIFO
//
//  Created by Mr.J on 6/6/15.
//  Copyright (c) 2015 ___NhuanQuang___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)
@property (nonatomic, readonly) NSUInteger maxItem;
- (id) dequeue;
- (void) enqueue:(id)obj;
- (instancetype)initWithMaxItem:(int)max;
- (void)addItem:(id)anItem;
@end
