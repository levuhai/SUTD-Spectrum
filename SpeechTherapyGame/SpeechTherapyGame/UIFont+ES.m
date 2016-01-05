//
//  UIFont+ES.m
//  Bone
//
//  Created by Hai Le on 4/17/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import "UIFont+ES.h"

@implementation UIFont (ES)
+ (UIFont *)ioniconsOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Ionicons" size:size];
}
+ (UIFont *)rodinOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"TT_RodinCattleya-B" size:size];
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
