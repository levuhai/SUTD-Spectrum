//
//  LPCView.m
//  Spectrum
//
//  Created by Hai Le on 29/9/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import "LPCView.h"
#import "AudioController.h"
#import "EZAudio.h"
#import <EZAudio/EZMicrophone.h>

@interface LPCView () <EZMicrophoneDelegate> {
    short int *longBuffer;
    int bufferSegCount;
    
    BOOL _needResetLPC;
    BOOL _drawing;
}

@end

@implementation LPCView
{
    int decimatedEndIdx;
    int truncatedStartIdx, truncatedEndIdx;
    int strongStartIdx, strongEndIdx;
    short int *dataBuffer;
    int dataBufferLength;
    
    EZMicrophone* _mic;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)start {
    longBuffer = (short int *)(malloc(1024000 * sizeof(short int)));
    bufferSegCount = 0;
    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate			= 44100.0;
    audioFormat.mFormatID			= kAudioFormatLinearPCM;
    audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket	= 1;
    audioFormat.mChannelsPerFrame	= 1;
    audioFormat.mBitsPerChannel		= 16;
    audioFormat.mBytesPerPacket		= 2;
    audioFormat.mBytesPerFrame		= 2;
    
    _mic = [[EZMicrophone alloc] initWithMicrophoneDelegate:self
                            withAudioStreamBasicDescription:audioFormat
                                          startsImmediately:YES];
    [[EZMicrophone sharedMicrophone] stopFetchingAudio];
    [EZAudio printASBD:_mic.audioStreamBasicDescription];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _drawing = NO;

    }
    return self;
}

- (void)refresh
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!_drawing) {
        return;
    }
    // A few variable used in plotting of H(w).
    double omega, realHw, imagHw, maxFreqResp, minFreqResp, freqRespScale;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat dashPattern[2];
    int i, k, degIdx, chunkIdx;
    CGPoint startPoint, endPoint;
    
    dataBuffer = [self longBuffer];
    dataBufferLength = [self lpcBufferSize];
    
    // https://github.com/fulldecent/formant-analyzer
    // First we find the truncating start and end indices
    [self removeSilence];
    [self removeTails];
    [self decimateDataBuffer];
    
    // Find ORDER+1 autocorrelation coefficient
    double *Rxx = (double *)(malloc((ORDER + 1) * sizeof(double)));
    double *pCoeff = (double *)(malloc((ORDER + 1) * sizeof(double)));
    
    for (int delayIdx = 0; delayIdx <= ORDER; delayIdx++) {
        double corrSum = 0;
        for (int dataIdx = 0; dataIdx < (decimatedEndIdx - delayIdx); dataIdx++) {
            corrSum += (dataBuffer[dataIdx] * dataBuffer[dataIdx + delayIdx]);
        }
        
        Rxx[delayIdx] = corrSum;
    }
    
    // Now solve for the predictor coefficiens.
    double pError = Rxx[0];                             // initialise error to total power
    pCoeff[0] = 1.0;                                    // first coefficient must be = 1
    
    // for each coefficient in turn
    for (k = 1 ; k <= ORDER ; k++) {
        
        // find next reflection coeff from pCoeff[] and Rxx[]
        double rcNum = 0;
        for (int i = 1 ; i <= k ; i++)
        {
            rcNum -= pCoeff[k-i] * Rxx[i];
        }
        
        pCoeff[k] = rcNum/pError;
        
        // perform recursion on pCoeff[]
        for (i = 1 ; i <= k/2 ; i++) {
            double pci  = pCoeff[i] + pCoeff[k] * pCoeff[k-i];
            double pcki = pCoeff[k-i] + pCoeff[k] * pCoeff[i];
            pCoeff[i] = pci;
            pCoeff[k-i] = pcki;
        }
        
        // calculate residual error
        pError = pError * (1.0 - pCoeff[k]*pCoeff[k]);
    }
    
    // Now we find frequency response of the inverse of the predictor filter
    
    double *freqResponse = (double *)(malloc((300) * sizeof(double)));
    for (degIdx=0; degIdx < 300; degIdx++) {
        omega = degIdx * M_PI / 330.0;
        realHw = 1.0;
        imagHw = 0.0;
        
        for (int k = 1 ; k <= ORDER ; k++) {
            realHw = realHw + pCoeff[k] * cos(k * omega);
            imagHw = imagHw - pCoeff[k] * sin(k * omega);
        }
        
        freqResponse[degIdx] = 20*log10(1.0 / sqrt(realHw * realHw + imagHw * imagHw));
    }
    
    // Now plot the frequency response
    maxFreqResp = -100.0;
    minFreqResp = 100.0;
    
    for (degIdx = 0; degIdx < 300; degIdx++) {
        maxFreqResp = MAX(maxFreqResp, freqResponse[degIdx]);
        minFreqResp = MIN(minFreqResp, freqResponse[degIdx]);
    }
    
    freqRespScale = 180.0 / (maxFreqResp - minFreqResp);
    
    UIColor* mycolor = [UIColor blackColor];
    CGContextSetStrokeColorWithColor(ctx, mycolor.CGColor);
    CGContextSetLineWidth(ctx, 2.0);
    startPoint = CGPointMake(0, 190 - freqRespScale * (freqResponse[0] - minFreqResp));
    
    for (chunkIdx=0; chunkIdx<300; chunkIdx++) {
        endPoint = CGPointMake(chunkIdx, 190 - freqRespScale * (freqResponse[chunkIdx] - minFreqResp));
        CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
        startPoint = endPoint;
    }
    
    CGContextStrokePath(ctx);
    
    // Draw four dashed vertical lines at 1kHz, 2kHz, 3kHz, and 4 kHz.
    mycolor = [UIColor blueColor];
    
    dashPattern[0] = 3.0;
    dashPattern[1] = 3.0;
    CGContextSetLineDash(ctx, 0, dashPattern, 1);
    CGContextSetStrokeColorWithColor(ctx, mycolor.CGColor);
    for (k=1; k<5; k++) {
        CGContextMoveToPoint(ctx, 60*k - 1, 0);
        CGContextAddLineToPoint(ctx, 60*k - 1, 200);
        CGContextStrokePath(ctx);
    }
    
    // Free two buffers started with malloc()
    free(Rxx);
    free(pCoeff);
    free(freqResponse);
    
    //    UIBezierPath *path = [UIBezierPath bezierPath];
    //    float xScale = size.width / waveformLength;
    //
    //    for (int i = 0; i < waveformLength; i++) {
    //        float x = xScale * i;
    //        float y = (waveform[i] * 0.5f + 0.5f) * size.height;
    //        if (i == 0) {
    //            [path moveToPoint:CGPointMake(x, y)];
    //        } else {
    //
    //            if (y>-200&&y<200) {
    //                [path addLineToPoint:CGPointMake(x, y)];
    //            }
    //        }
    //    }
    //    [[UIColor redColor] setStroke];
    //    path.lineWidth = 0.5f;
    //    [path stroke];
}

-(void) decimateDataBuffer
{
    int dumidx;
    
    for (dumidx=0; dumidx < (truncatedEndIdx - truncatedStartIdx)/4; dumidx++) {
        dataBuffer[dumidx] = dataBuffer[4*dumidx + truncatedStartIdx];
    }
    
    decimatedEndIdx = dumidx - 1;
}
-(void) removeSilence
{
    int chunkEnergy, energyThreshold;
    int maxEnergyValue;
    int chunkIdx;
    int j;
    
    int chunkSize = dataBufferLength / 300;
    
    maxEnergyValue = 0;
    for (chunkIdx=0; chunkIdx<300; chunkIdx++) {
        chunkEnergy = 0;
        for (j=0; j<chunkSize; j++) {
            chunkEnergy += dataBuffer[j + chunkIdx*chunkSize] * dataBuffer[j + chunkIdx*chunkSize]/1000;
        }
        maxEnergyValue = MAX(maxEnergyValue, chunkEnergy);
    }
    
    energyThreshold = maxEnergyValue / 10;
    
    // Find strong starting index.
    strongStartIdx = 0;
    for (chunkIdx=0; chunkIdx<300; chunkIdx++) {
        chunkEnergy = 0;
        for (j=0; j<chunkSize; j++) {
            chunkEnergy += dataBuffer[j + chunkIdx*chunkSize] * dataBuffer[j + chunkIdx*chunkSize]/1000;
        }
        if (chunkEnergy > energyThreshold) {
            strongStartIdx = chunkIdx * chunkSize;
            strongStartIdx = MAX(0, strongStartIdx);
            break;
        }
    }
    
    // Find strong ending index
    strongEndIdx = dataBufferLength;
    for (chunkIdx = 299; chunkIdx >= 0; chunkIdx--) {
        chunkEnergy = 0;
        for (j=0; j<chunkSize; j++) {
            chunkEnergy += dataBuffer[j + chunkIdx*chunkSize] * dataBuffer[j + chunkIdx*chunkSize]/1000;
        }
        if (chunkEnergy > energyThreshold) {
            strongEndIdx = chunkIdx * chunkSize + chunkSize - 1;
            strongEndIdx = MIN(dataBufferLength, strongEndIdx);
            break;
        }
    }
}

// The follosing function removes 15% from both ends of strong section of the buffer
-(void) removeTails
{
    truncatedStartIdx = strongStartIdx + (strongEndIdx - strongStartIdx)*15/100;
    truncatedEndIdx = strongEndIdx - (strongEndIdx - strongStartIdx)*15/100;
}

- (void)microphone:(EZMicrophone *)microphone
     hasBufferList:(AudioBufferList *)bufferList
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    dispatch_async(dispatch_get_main_queue(),^{
        
        if (_needResetLPC) {
            bufferSegCount = 0;
            self.lpcBufferSize = 0;
            
            // Clear all entries from the long audio buffer in audioDeviceManager.
            for (int j=0; j<1024000; j++) {
                longBuffer[j] = 0;
            }
            _needResetLPC = NO;
        }
        unsigned long bufferEnergy;
        short signed int *source= (short signed int *)bufferList->mBuffers[0].mData;
        
        bufferEnergy = 0;
        for (int j = 0; j < bufferSize; j++) {
            bufferEnergy = bufferEnergy + source[j]*source[j];
            //NSLog(@"%hd %d",source[j],numberOfChannels);
            
        }
        
        //NSLog(@"============");
        if (bufferEnergy > 300000000/5) {
            for (int j = 0; j < bufferSize; j++) {
                longBuffer[j + bufferSegCount * bufferSize] = source[j];
            }
            bufferSegCount = bufferSegCount + 1;
            self.lpcBufferSize = bufferSegCount * bufferSize;
        } else {
            bufferSegCount = 1;
            self.lpcBufferSize = bufferSize;
        }
    if (!_drawing) {
        [NSTimer scheduledTimerWithTimeInterval:(1.0f / 40) target:self selector:@selector(refresh) userInfo:nil repeats:YES];
        _drawing = YES;
    }
    });
}

#pragma mark - LPC

- (short int*)longBuffer {
    NSLog(@"%d",bufferSegCount);
    //bufferSegCount = 1;
    //self.lpcBufferSize = 1024;
    _needResetLPC = YES;
    return longBuffer;
}

@end
