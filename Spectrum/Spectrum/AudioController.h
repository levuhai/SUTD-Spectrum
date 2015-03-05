//
//  AudioController.h
//  audio
//
//  Created by Hai Le on 26/2/14.
//  Copyright (c) 2014 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#import "EZAudio.h"

@protocol AudioControllerDelegate;

@interface AudioController : NSObject <EZMicrophoneDelegate>

@property (nonatomic, assign)       float volume;
//@property (nonatomic, assign)       float lpf;
//@property (nonatomic, assign)       float hpf;
//@property (nonatomic, assign)       float bpf;

@property (nonatomic, assign)       float              highPassGain;
@property (nonatomic, assign)       BOOL               isProcessing;
@property (nonatomic, assign)       float              highPassCutOff;
@property (nonatomic, assign)       float              highPassFilterOrder;
@property (nonatomic, strong)       UIColor            *highPassGraphColor;

@property (nonatomic, assign)       float              bandPassGain;
@property (nonatomic, assign)       float              bandPassCutOff;
@property (nonatomic, assign)       float              bandPassBandWidth;
@property (nonatomic, assign)       float              bandPassFilterOrder;
@property (nonatomic, strong)       UIColor            *bandPassGraphColor;

@property (nonatomic, assign)       float              lowPassGain;
@property (nonatomic, assign)       float              lowPassCutOff;
@property (nonatomic, assign)       float              lowPassFilterOrder;
@property (nonatomic, strong)       UIColor            *lowPassGraphColor;

@property (nonatomic,assign) id<AudioControllerDelegate> delegate;

// Singleton methods
+ (AudioController *) sharedInstance;
- (void)getFilterDataWithLowPass:(CGFloat*)lpf bandPass:(CGFloat*)bpf highPass:(CGFloat*)hpf;
- (float*)getHighPassDataWithBufferSize:(int*)size;
- (float*)getBandPassDataWithBufferSize:(int*)size;
- (float*)getLowPassDataWithBufferSize:(int*)size;
- (void)start;
- (void)stop;
- (void)resetLowPassFilter;
- (void)resetBandPassFilter;
- (void)resetHighPassFilter;

@end

@protocol AudioControllerDelegate <NSObject>

@optional
- (void)lowPassDidFinish:(float*)data withBufferSize:(UInt32)bufferSize;
- (void)bandPassDidFinish:(float*)data withBufferSize:(UInt32)bufferSize;
- (void)highPassDidFinish:(float*)data withBufferSize:(UInt32)bufferSize;

@end
