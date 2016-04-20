//
//  BMDirtyResampler.h
//  BMAudioFilters
//
//  Fast upsample and downsample for use in guitar distortion modelling
//
//  Guitar speaker cabs don't output much tone above 3KHz. This file does
//  resampling using butterworth lowpass filters with a 3.5KHz cutoff, which
//  is unacceptable for general audio signals but fine for distorted guitar.
//  Reducing the cutoff from nyquist down to 3.5KHz simplifies the design.
//
//  Created by Hans on 2/4/16.
//  Copyright © 2016 Hans. All rights reserved.
//

#ifndef BMDirtyResampler_h
#define BMDirtyResampler_h

#include "BMMultiLevelBiquad.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef struct BMDirtyResampler {
        
        size_t upsampleFactor;
        float upsampleGain;
    } BMDirtyResampler;
    
    /*
     * output length = inputLength * upsampleFactor
     * 
     * must call init function before calling this
     *
     */
    void BMDirtyResampler_upsample(BMDirtyResampler* rs, const float* input, float* output, size_t inputLength);
    
    
    /*
     * output length = inputLength / upsampleFactor
     *
     * must call init function before calling this
     *
     * input will be used as temp memory, so make a copy if you need
     * to preserve it.
     *
     */
    void BMDirtyResampler_downsample(BMDirtyResampler* rs, float* input, float* output, size_t inputLength);
    
    /*
     * Call this before calling any other function in this file
     *
     * sampleRate is the audio system sample rate before upsampling
     */
    void BMDirtyResampler_init(BMDirtyResampler* rs, size_t upsampleFactor, float sampleRate);
    
    
#ifdef __cplusplus
}
#endif

#endif /* BMDirtyResampler_h */
