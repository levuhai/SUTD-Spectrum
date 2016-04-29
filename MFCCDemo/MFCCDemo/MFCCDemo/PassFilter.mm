//
//  PassFilter.m
//  MFCCDemo
//
//  Created by Hai Le on 4/25/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#import "PassFilter.h"
#import <EZAudio/EZAudio.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "BMTNFilter.h"
#import "BMMultiLevelBiquad.h"

@implementation PassFilter

+ (NSURL*)urlForPath:(NSString*)path {
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [path stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *url = [NSURL URLWithString:result];
    return url;
}

+ (AudioStreamBasicDescription)monoFloatFormatWithSampleRate:(float)sampleRate
{
    AudioStreamBasicDescription asbd;
    UInt32 byteSize = sizeof(float);
    asbd.mBitsPerChannel   = 8 * byteSize;
    asbd.mBytesPerFrame    = byteSize;
    asbd.mBytesPerPacket   = byteSize;
    asbd.mChannelsPerFrame = 1;
    asbd.mFormatFlags      = kAudioFormatFlagIsPacked|kAudioFormatFlagIsFloat|kAudioFormatFlagIsNonInterleaved;
    asbd.mFormatID         = kAudioFormatLinearPCM;
    asbd.mFramesPerPacket  = 1;
    asbd.mSampleRate       = sampleRate;
    return asbd;
}

@end
