//
//  BMDirtyResampler.c
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

#include "BMDirtyResampler.h"
#include <Accelerate/Accelerate.h>

#define BM_DIRTY_RESAMPLER_FC 3500 // 3.5Khz cutoff for lowpass filters

#ifdef __cplusplus
extern "C" {
#endif

    /*
     * output length = inputLength * upsampleFactor
     *
     * must call init function before calling this
     *
     */
    void BMDirtyResampler_upsample(BMDirtyResampler* rs, const float* input, float* output, size_t inputLength){
        
        // set the output to zero
        memset(output,0,inputLength*rs->upsampleFactor*sizeof(float));
        
        // multiply the input * upsampleFactor and write into output,
        // placing upsampleFactor-1 zeros between each nonzero value
        vDSP_vsmul(input, 1, &rs->upsampleGain, output, rs->upsampleFactor, inputLength);
        
        // lowpass filter the upsampled output
        BMMultiLevelBiquad_processBufferMono(&rs->upLpf, output, output, inputLength*rs->upsampleFactor);
    }
    
    
    /*
     * output length = inputLength / upsampleFactor
     *
     * must call init function before calling this
     *
     * input will be used as temp memory, so make a copy if you need
     * to preserve it unharmed.
     *
     */
    void BMDirtyResampler_downsample(BMDirtyResampler* rs, float* input, float* output, size_t inputLength){
        
        // lowpass filter the upsampled input
        BMMultiLevelBiquad_processBufferMono(&rs->downLpf, input, input,inputLength);
        
        // downsample and copy to output
        size_t j=0;
        for(size_t i=0; i<inputLength; i+=rs->upsampleFactor)
            output[j++] = input[i];
    }
    
    
    
    /*
     * Call this before calling any other function in this file
     */
    void BMDirtyResampler_init(BMDirtyResampler* rs, size_t upsampleFactor, float sampleRate){
        
        rs->upsampleFactor = upsampleFactor;
        rs->upsampleGain = (float)upsampleFactor;
     
        // initialize filter structs
        // FIR filter
        
        
    }

#ifdef __cplusplus
}
#endif