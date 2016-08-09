//
//  NSObject+UIPopover_Iphone.m
//  Spectrum
//
//  Created by Mr.J on 5/31/15.
//  Copyright (c) 2015 Earthling Studio. All rights reserved.
//

#import "NSObject+UIPopover_Iphone.h"

@implementation UIPopoverController (overrides)

+(BOOL)_popoversDisabled
{
    return NO;
}

@end