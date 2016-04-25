//
//  PassFilter.h
//  MFCCDemo
//
//  Created by Hai Le on 4/25/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PassFilter : NSObject

+ (void)filter:(float*)data length:(size_t)len path:(NSString*)fullPath;
+ (NSURL*)urlForPath:(NSString*)path;

@end
