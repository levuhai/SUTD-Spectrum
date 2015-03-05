//
//  EZAudio+Expanded.h
//  Spectrum
//
//  Created by Hai Le on 28/6/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import "EZAudio.h"

@interface EZAudio (Expanded)

+(float)average:(float *)buffer
         length:(int)bufferSize;

+ (void) printASBD: (AudioStreamBasicDescription) asbd;

@end
