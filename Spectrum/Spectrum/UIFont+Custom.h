//
//  UIFont+Custom.h
//  BraveFrontierWikia
//
//  Created by Hai Le on 5/6/14.
//  Copyright (c) 2014 Hai Le. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Custom)

+ (UIFont*) ioniconsOfSize:(CGFloat)size;

+ (UIFont*) openSansOfSize:(CGFloat)size;
+ (UIFont*) openSansBoldOfSize:(CGFloat)size;
+ (UIFont*) iosStyleOfSize:(CGFloat)size;
+ (UIFont*) rodinNTLGOfSize:(CGFloat)size;

+ (void) printAllFontName;

@end
