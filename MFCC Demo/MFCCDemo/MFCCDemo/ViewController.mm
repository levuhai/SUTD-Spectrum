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
#include "WordMatch.h"

#define kAudioFile1 [[NSBundle mainBundle] pathForResource:@"good1" ofType:@"wav"]
#define kAudioFile2 [[NSBundle mainBundle] pathForResource:@"good2" ofType:@"wav"]

@interface ViewController ()

@property (nonatomic, strong) EZAudioFile *audioFile1;
@property (nonatomic, strong) EZAudioFile *audioFile2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url1 = [NSURL URLWithString:kAudioFile1];
    self.audioFile1 = [EZAudioFile audioFileWithURL:url1];
    
    NSURL *url2 = [NSURL URLWithString:kAudioFile2];
    self.audioFile2 = [EZAudioFile audioFileWithURL:url2];
    
    EZAudioFloatData* data1 = [self.audioFile1 getWaveformData];
    EZAudioFloatData* data2 = [self.audioFile2 getWaveformData];
    
    float *input1 = data1.buffers[0];
    
    WM::MFCCProcessor mp(400, 0.97f, 16000, 133.33f, 6855.6);
//    WM::MFCCProcessor::CepstraBuffer cepstra_1;
//    cepstra_1.assign(0);
//    mp.process(input1, 0, &cepstra_1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
