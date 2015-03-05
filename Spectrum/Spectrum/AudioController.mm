//
//  AudioController.m
//  audio
//
//  Created by Hai Le on 26/2/14.
//  Copyright (c) 2014 Hai Le. All rights reserved.
//

#import "AudioController.h"
#import "EZAudio+Expanded.h"
#import "Configs.h"
#include <stdio.h>
#import "Dsp.h"
#include <dispatch/dispatch.h>

using namespace Dsp;

#define absX(x) (x<0?0-x:x)
#define decibel(amplitude) (20.0 * log10(amplitude))
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)

static AudioController *sharedInstance = nil;

@interface AudioController () {
    __block float dbVal;
    
//    Filter* lowPassFilter;
//    Filter* bandPassFilter;
//    Filter* highPassFilter;
    
    SimpleFilter<Butterworth::HighPass<10>,1> highpass;
    SimpleFilter<Butterworth::BandPass<10>,1> bandpass;
    SimpleFilter<Butterworth::LowPass<10>,1> lowpass;
    
    std::vector<float> vectorLP;
    std::vector<float> vectorBP;
    std::vector<float> vectorHP;
    
    int _bufferSize;
    
    COMPLEX_SPLIT _A;
    FFTSetup      _FFTSetup;
    BOOL          _isFFTSetup;
    vDSP_Length   _log2n;
}

@end

@implementation AudioController

@synthesize volume;

@synthesize highPassGain            = _highPassGain;
@synthesize highPassCutOff          = _highPassCutOff;
@synthesize highPassFilterOrder     = _highPassFilterOrder;
@synthesize highPassGraphColor      = _highPassGraphColor;

@synthesize bandPassGain            = _bandPassGain;
@synthesize bandPassBandWidth       = _bandPassBandWidth;
@synthesize bandPassCutOff          = _bandPassCutOff;
@synthesize bandPassFilterOrder     = _bandPassFilterOrder;
@synthesize bandPassGraphColor      = _bandPassGraphColor;

@synthesize lowPassGain             = _lowPassGain;
@synthesize lowPassCutOff           = _lowPassCutOff;
@synthesize lowPassFilterOrder      = _lowPassFilterOrder;
@synthesize lowPassGraphColor       = _lowPassGraphColor;

#pragma mark - Singleton

+ (AudioController*) sharedInstance
{
	@synchronized(self)
	{
		if (sharedInstance == nil) {
			sharedInstance = [[AudioController alloc] init];
		}
	}
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        self.isProcessing = NO;
        
        // Alloc filters
//        lowPassFilter = new SmoothedFilterDesign<Butterworth::Design::LowPass <10>, 1> (1024);
//        bandPassFilter = new SmoothedFilterDesign<Butterworth::Design::BandPass <10>, 1> (1024);
//        highPassFilter = new SmoothedFilterDesign<Butterworth::Design::HighPass <10>, 1> (1024);
        
        if (self.highPassFilterOrder    == 0.0) self.highPassFilterOrder = dFilterOrder;
        if (self.highPassCutOff         == 0.0) self.highPassCutOff = dHighPassCutOff;
        if (self.highPassGain           == 0.0) self.highPassGain = noiseFloorDefaultValue;
        if (self.highPassGraphColor     == nil)
            self.highPassGraphColor = [UIColor colorWithRed:0.99 green:0.96 blue:0 alpha:1];
        [self resetHighPassFilter];
        
        if (self.bandPassFilterOrder    == 0.0) self.bandPassFilterOrder = dFilterOrder;
        if (self.bandPassBandWidth      == 0.0) self.bandPassBandWidth = dBandPassBandWidth;
        if (self.bandPassCutOff         == 0.0) self.bandPassCutOff = dBandPassCutOff;
        if (self.bandPassGain           == 0.0) self.bandPassGain = noiseFloorDefaultValue;
        if (self.bandPassGraphColor     == nil)
            self.bandPassGraphColor = [UIColor colorWithRed:1.0 green:0.5 blue:0 alpha:0.8];
        [self resetBandPassFilter];
        
        if (self.lowPassFilterOrder     == 0.0) self.lowPassFilterOrder = dFilterOrder;
        if (self.lowPassCutOff          == 0.0) self.lowPassCutOff = dLowPassCutOff;
        if (self.lowPassGain            == 0.0) self.lowPassGain = noiseFloorDefaultValue;
        if (self.lowPassGraphColor      == nil)
            self.lowPassGraphColor = [UIColor colorWithRed:0.27 green:0.58 blue:0.84 alpha:1];
        [self resetLowPassFilter];
        
        //lpcData = new float[512];
        
        [EZMicrophone sharedMicrophone].microphoneDelegate = self;
        [EZAudio printASBD:[[EZMicrophone sharedMicrophone] audioStreamBasicDescription]];
        [[AVAudioSession sharedInstance] setPreferredSampleRate:kDefaultSampleRate error:nil];
    }
    return self;
}

#pragma mark - Override Getters Setters
//
// High-pass Filter
//
- (void)setHighPassGain:(float)highPassGain {
    _highPassGain = highPassGain;
    [self saveFloat:highPassGain forKey:kHighPassGain];
}

- (float)highPassGain {
    if (_highPassGain == 0.0) {
        _highPassGain = [self floatForKey:kHighPassGain];
    }
    return _highPassGain;
}

- (void)setHighPassCutOff:(float)highPassCutOff {
    _highPassCutOff = highPassCutOff;
    
    [self saveFloat:highPassCutOff forKey:kHighPassCutOff];
}

- (float)highPassCutOff {
    if (_highPassCutOff == 0.0) {
        _highPassCutOff = [self floatForKey:kHighPassCutOff];
    }
    return _highPassCutOff;
}

- (void)setHighPassFilterOrder:(float)highPassFilterOrder {
    _highPassFilterOrder = highPassFilterOrder;
    
    [self saveFloat:highPassFilterOrder forKey:kHighPassFilterOrder];
}

- (float)highPassFilterOrder {
    if (_highPassFilterOrder == 0.0) {
        _highPassFilterOrder = [self floatForKey:kHighPassFilterOrder];
    }
    return _highPassFilterOrder;
}

- (void)setHighPassGraphColor:(UIColor *)highPassGraphColor {
    _highPassGraphColor = highPassGraphColor;
    
    [self saveColor:highPassGraphColor forKey:kHighPassGraphColor];
}

- (UIColor *)highPassGraphColor {
    if (_highPassGraphColor == nil) {
        _highPassGraphColor = [self colorForKey:kHighPassGraphColor];
    }
    return _highPassGraphColor;
}

//
// Band-pass Filter
//
- (void)setBandPassGain:(float)bandPassGain {
    _bandPassGain = bandPassGain;
    [self saveFloat:bandPassGain forKey:kBandPassGain];
}

- (float)bandPassGain {
    if (_bandPassGain == 0.0) {
        _bandPassGain = [self floatForKey:kBandPassGain];
    }
    return _bandPassGain;
}

- (void)setBandPassCutOff:(float)bandPassCutOff {
    _bandPassCutOff = bandPassCutOff;
    
    [self saveFloat:bandPassCutOff forKey:kBandPassCutOff];
}

- (float)bandPassCutOff {
    if (_bandPassCutOff == 0.0) {
        _bandPassCutOff = [self floatForKey:kBandPassCutOff];
    }
    return _bandPassCutOff;
}

- (void)setBandPassBandWidth:(float)bandPassBandWidth {
    _bandPassBandWidth = bandPassBandWidth;
    
    [self saveFloat:bandPassBandWidth forKey:kBandPassBandWidth];
}

- (float)bandPassBandWidth {
    if (_bandPassBandWidth == 0.0) {
        _bandPassBandWidth = [self floatForKey:kBandPassBandWidth];
    }
    return _bandPassBandWidth;
}

- (void)setBandPassFilterOrder:(float)bandPassFilterOrder {
    _bandPassFilterOrder = bandPassFilterOrder;
    
    [self saveFloat:bandPassFilterOrder forKey:kBandPassFilterOrder];
}

- (float)bandPassFilterOrder {
    if (_bandPassFilterOrder == 0.0) {
        _bandPassFilterOrder = [self floatForKey:kBandPassFilterOrder];
    }
    return _bandPassFilterOrder;
}

- (void)setBandPassGraphColor:(UIColor *)bandPassGraphColor {
    _bandPassGraphColor = bandPassGraphColor;
    
    [self saveColor:bandPassGraphColor forKey:kBandPassGraphColor];
}

- (UIColor *)bandPassGraphColor {
    if (_bandPassGraphColor == nil) {
        _bandPassGraphColor = [self colorForKey:kBandPassGraphColor];
    }
    return _bandPassGraphColor;
}

//
// Low-pass Filter
//
- (void)setLowPassGain:(float)lowPassGain {
    _lowPassGain = lowPassGain;
    [self saveFloat:lowPassGain forKey:kLowPassGain];
}

- (float)lowPassGain {
    if (_lowPassGain == 0.0) {
        _lowPassGain = [self floatForKey:kLowPassGain];
    }
    return _lowPassGain;
}

- (void)setLowPassCutOff:(float)lowPassCutOff {
    _lowPassCutOff = lowPassCutOff;
    
    [self saveFloat:_lowPassCutOff forKey:kLowPassCutOff];
}

- (float)lowPassCutOff {
    if (_lowPassCutOff == 0.0) {
        _lowPassCutOff = [self floatForKey:kLowPassCutOff];
    }
    return _lowPassCutOff;
}

- (void)setLowPassFilterOrder:(float)lowPassFilterOrder {
    _lowPassFilterOrder = lowPassFilterOrder;
    
    [self saveFloat:lowPassFilterOrder forKey:kLowPassFilterOrder];
}

- (float)lowPassFilterOrder {
    if (_lowPassFilterOrder == 0.0) {
        _lowPassFilterOrder = [self floatForKey:kLowPassFilterOrder];
    }
    return _lowPassFilterOrder;
}

- (void)setLowPassGraphColor:(UIColor *)lowPassGraphColor {
    _lowPassGraphColor = lowPassGraphColor;
    
    [self saveColor:lowPassGraphColor forKey:kLowPassGraphColor];
}

- (UIColor *)lowPassGraphColor {
    if (_lowPassGraphColor == nil) {
        _lowPassGraphColor = [self colorForKey:kLowPassGraphColor];
    }
    return _lowPassGraphColor;
}

#pragma mark - EZMicrophoneDelegate

-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    //dispatch_async(dispatch_get_main_queue(),^{
    _bufferSize = bufferSize;
//        // Setup the FFT if it's not already setup
//        if( !_isFFTSetup ){
//            [self createFFTWithBufferSize:bufferSize withAudioData:buffer[0]];
//            _isFFTSetup = YES;
//        }
//        
//        // Get the FFT data
//        [self updateFFTWithBufferSize:bufferSize withAudioData:buffer[0]];
    if (!_isProcessing) {
        vectorLP.empty();
        vectorBP.empty();
        vectorHP.empty();
        
        vectorLP.assign(buffer[0], buffer[0]+bufferSize);
        vectorBP.assign(buffer[0], buffer[0]+bufferSize);
        vectorHP.assign(buffer[0], buffer[0]+bufferSize);
    }
    //});
}

#pragma mark - Public Category

- (void)start {
    [[EZMicrophone sharedMicrophone] startFetchingAudio];
}

- (void)stop {
    [[EZMicrophone sharedMicrophone] stopFetchingAudio];
}

- (void)getFilterDataWithLowPass:(CGFloat*)lpf bandPass:(CGFloat*)bpf highPass:(CGFloat*)hpf {
     //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         self.isProcessing = YES;
         
         // Low pass
         *lpf = 0.0;
         float *temp = vectorLP.data();
         lowpass.process(_bufferSize, &temp);
//         lowPassFilter->process(_bufferSize, &temp);
         *lpf = [EZAudio average:temp length:_bufferSize];
         *lpf = decibel(*lpf) + 50;
         *lpf = *lpf < 0 ? 0 : *lpf;
         
         // Band pass
         *bpf = 0.0;
         float *temp1 = vectorBP.data();
//         bandPassFilter->process(_bufferSize, &temp1);
         bandpass.process(_bufferSize, &temp1);
         *bpf = [EZAudio average:temp1 length:_bufferSize];
         *bpf = decibel(*bpf) + 50;
         *bpf = *bpf < 0 ? 0 : *bpf;
         
         // High pass
         *hpf = 0.0;
         float *temp2 = vectorHP.data();
//         highPassFilter->process(_bufferSize, &temp2);
         highpass.process(_bufferSize, &temp2);
         *hpf = [EZAudio average:temp2 length:_bufferSize];
         *hpf = decibel(*hpf) + 50;
         *hpf = *hpf < 0 ? 0 : *hpf;
         
         self.isProcessing = NO;
     //});
}

- (float*)getHighPassDataWithBufferSize:(int*)size {
     float *temp = vectorHP.data();
     //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         self.isProcessing = YES;
         *size = _bufferSize;
         highpass.process(_bufferSize, &temp);
         self.isProcessing = NO;
     //});
    return temp;
}

- (float*)getBandPassDataWithBufferSize:(int*)size {
    float *temp = vectorBP.data();
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    self.isProcessing = YES;
    *size = _bufferSize;
    bandpass.process(_bufferSize, &temp);
    self.isProcessing = NO;
    //});
    return temp;
}

- (float*)getLowPassDataWithBufferSize:(int*)size {
    float *temp = vectorLP.data();
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    self.isProcessing = YES;
    *size = _bufferSize;
    lowpass.process(_bufferSize, &temp);
    self.isProcessing = NO;
    //});
    return temp;
}

- (void)resetBandPassFilter {
    // Setup Bandpass Filter
//    Params paramsBP;
//    paramsBP[0] = kDefaultSampleRate; // sample rate
//    paramsBP[1] = _bandPassFilterOrder; // order
//    paramsBP[2] = _bandPassCutOff; // center frequency
//    paramsBP[3] = _bandPassBandWidth; // cutoff frequency
//    bandPassFilter->setParams (paramsBP);
//
//    bandPassFilter->reset();
    
    bandpass.setup(_bandPassFilterOrder, kDefaultSampleRate, _bandPassCutOff,_bandPassBandWidth);
    bandpass.reset();
}

- (void)resetHighPassFilter {
//    Params params;
//    params[0] = kDefaultSampleRate; // sample rate
//    params[1] = _highPassFilterOrder; // order
//    params[2] = _highPassCutOff; // cutoff frequency
//    highPassFilter->setParams (params);
//    
//    highPassFilter->reset();
    
    highpass.setup(_highPassFilterOrder, kDefaultSampleRate, _highPassCutOff);
    highpass.reset();
}

- (void)resetLowPassFilter {
//    Params params;
//    params[0] = kDefaultSampleRate; // sample rate
//    params[1] = _lowPassFilterOrder; // order
//    params[2] = _lowPassCutOff; // cutoff frequency
//    lowPassFilter->setParams (params);
//    
//    lowPassFilter->reset();
    
    lowpass.setup(_lowPassFilterOrder, kDefaultSampleRate, _lowPassCutOff);
    lowpass.reset();
}

/**
 Adapted from http://batmobile.blogs.ilrt.org/fourier-transforms-on-an-iphone/
 */
-(void)createFFTWithBufferSize:(float)bufferSize withAudioData:(float*)data {
    
    // Setup the length
    _log2n = log2f(bufferSize);
    
    // Calculate the weights array. This is a one-off operation.
    _FFTSetup = vDSP_create_fftsetup(_log2n, FFT_RADIX2);
    
    // For an FFT, numSamples must be a power of 2, i.e. is always even
    int nOver2 = bufferSize/2;
    
    // Populate *window with the values for a hamming window function
    float *window = (float *)malloc(sizeof(float)*bufferSize);
    vDSP_hamm_window(window, bufferSize, 0);
    // Window the samples
    vDSP_vmul(data, 1, window, 1, data, 1, bufferSize);
    free(window);
    
    // Define complex buffer
    _A.realp = (float *) malloc(nOver2*sizeof(float));
    _A.imagp = (float *) malloc(nOver2*sizeof(float));
    
}

-(void)updateFFTWithBufferSize:(float)bufferSize withAudioData:(float*)data {
    
    // For an FFT, numSamples must be a power of 2, i.e. is always even
    int nOver2 = bufferSize/2;
    
    // Pack samples:
    // C(re) -> A[n], C(im) -> A[n+1]
    vDSP_ctoz((COMPLEX*)data, 2, &_A, 1, nOver2);
    
    // Perform a forward FFT using fftSetup and A
    // Results are returned in A
    vDSP_fft_zrip(_FFTSetup, &_A, 1, _log2n, FFT_FORWARD);
    
    // Convert COMPLEX_SPLIT A result to magnitudes
    float amp[nOver2];
    float maxMag = 0;
    
    for(int i=0; i<nOver2; i++) {
        // Calculate the magnitude
        float mag = _A.realp[i]*_A.realp[i]+_A.imagp[i]*_A.imagp[i];
        maxMag = mag > maxMag ? mag : maxMag;
    }
    for(int i=0; i<nOver2; i++) {
        // Calculate the magnitude
        float mag = _A.realp[i]*_A.realp[i]+_A.imagp[i]*_A.imagp[i];
        // Bind the value to be less than 1.0 to fit in the graph
        amp[i] = [EZAudio MAP:mag leftMin:0.0 leftMax:maxMag rightMin:0.0 rightMax:1.0];
    }
    
    // Update the frequency domain plot
//    [self.audioPlotFreq updateBuffer:amp
//                      withBufferSize:nOver2];
    
}

#pragma mark - Private Category

- (void)saveFloat:(float)value forKey:(NSString*)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithFloat:value] forKey:key];
    [defaults synchronize];
}

- (float)floatForKey:(NSString*)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[defaults objectForKey:key]floatValue];
}

- (void)saveColor:(UIColor*)color forKey:(NSString*)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    [defaults setObject:colorData forKey:key];
    [defaults synchronize];
}

- (UIColor*)colorForKey:(NSString*)key {
    NSData *colorData = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return (UIColor*)[NSKeyedUnarchiver unarchiveObjectWithData:colorData];
}

@end
