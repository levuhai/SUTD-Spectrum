//
//  ViewController.m
//  MFCCDemo
//
//  Created by Hai Le on 9/23/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import "ViewController.h"
#import "EZAudio.h"
#include "MFCCProcessor.hpp"

#define kAudioFile1 [[NSBundle mainBundle] pathForResource:@"good1" ofType:@"wav"]
#define kAudioFile2 [[NSBundle mainBundle] pathForResource:@"good2" ofType:@"wav"]

@interface ViewController ()

@property (nonatomic, strong) EZAudioFile *audioFile1;
@property (nonatomic, strong) EZAudioFile *audioFile2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Read audio files from URLs
    NSURL *url1 = [NSURL URLWithString:kAudioFile1];
    self.audioFile1 = [EZAudioFile audioFileWithURL:url1];
    EZAudioFloatData* data1 = [self.audioFile1 getWaveformData];
    
    
    NSURL *url2 = [NSURL URLWithString:kAudioFile2];
    self.audioFile2 = [EZAudioFile audioFileWithURL:url2];
    EZAudioFloatData* data2 = [self.audioFile2 getWaveformData];
    
    // Data array
    float *r1 = new float[data1.bufferSize];
    float *input1 = data1.buffers[0];
    for (int i = 0; i < data1.bufferSize; i++) {
        r1[i] = input1[i];
    }
    
    float *r2 = new float[data2.bufferSize];
    float *input2 = data2.buffers[0];
    for (int i = 0; i < data2.bufferSize; i++) {
        r2[i] = input2[i];
    }
    
    // MFCC
    WM::MFCCProcessor mp1(400, 0.97f, 16000, 133.33f, 6855.6);
    WM::MFCCProcessor::CepstraBuffer cepstra_1;
    cepstra_1.assign(0);
    mp1.process(r1, 0, &cepstra_1);
    
    WM::MFCCProcessor mp2(400, 0.97f, 16000, 133.33f, 6855.6);
    WM::MFCCProcessor::CepstraBuffer cepstra_2;
    cepstra_2.assign(0);
    mp2.process(r2, 0, &cepstra_2);
    
    // Vector
    std::vector< std::vector<float> > ouput(data1.bufferSize, std::vector<float>(data2.bufferSize,0.0f));

//    for i = 1:size(MFCC1,2)
//    for j = 1:size(MFCC2,2)
//        output(i,j) = norm(MFCC1(:,i)-MFCC2(:,j));
//    end
//    end
    for (int i = 0; i<data1.bufferSize; i++) {
        for (int j = 0; j<data2.bufferSize; j++) {
            ouput[i][j] = 0.0f;
        }
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
