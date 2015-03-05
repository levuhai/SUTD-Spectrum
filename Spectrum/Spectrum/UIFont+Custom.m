//
//  UIFont+Custom.m
//  BraveFrontierWikia
//
//  Created by Hai Le on 5/6/14.
//  Copyright (c) 2014 Hai Le. All rights reserved.
//

#import "UIFont+Custom.h"

@implementation UIFont (Custom)

+ (UIFont *)openSansOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"OpenSans" size:size];
}

+ (UIFont *)openSansBoldOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"OpenSans-Bold" size:size];
}

+ (UIFont *)ioniconsOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Ionicons" size:size];
}

+ (UIFont*)iosStyleOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"ios7-style-font-icons" size:size];
}

+ (UIFont*)rodinNTLGOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"FTT-RodinNTLG EB" size:size];
}


+ (void)printAllFontName {
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}

@end
