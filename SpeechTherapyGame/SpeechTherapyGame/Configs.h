//
//  Configs.h
//  audio
//
//  Created by Hai Le on 19/2/14.
//  Copyright (c) 2014 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDefaultSampleRate 22050
#define hpfCutoffKey @"hpfCutoffVal"

#define hpfGraphColorKey @"XColor"


#define noiseFloorDefaultValue 10
#define hpNoiseFloorKey @"kHPNoiseFloor"

#define dFilterOrder 5;

#define kHighPassGain            @"kHighPassGain"
#define kHighPassCutOff          @"kHighPassCutOff"
#define kHighPassFilterOrder     @"kHighPassFilterOrder"
#define kHighPassGraphColor      @"kHighPassGraphColor"

#define dHighPassCutOff         1100

#define kBandPassGain           @"kBandPassGain"
#define kBandPassCutOff         @"kBandPassCutOff"
#define kBandPassBandWidth      @"kBandPassBandWidth"
#define kBandPassFilterOrder    @"kBandPassFilterOrder"
#define kBandPassGraphColor     @"kBandPassGraphColor"

#define dBandPassCutOff         1000
#define dBandPassBandWidth      100

#define kLowPassGain            @"kLowPassGain"
#define kLowPassCutOff          @"kLowPassCutOff"
#define kLowPassFilterOrder     @"kLowPassFilterOrder"
#define kLowPassGraphColor      @"kLowPassGraphColor"

#define dLowPassCutOff          100

#define kDefaultMaximumSegment 20
#define kKeyMaximumSegment @"kMaximumSegment"
#define kDefaultOrder 12
#define kKeyOrder @"kOrder"

#define IS_iPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)