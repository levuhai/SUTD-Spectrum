//
//  ViewController.m
//  MFCCDemo
//
//  Created by Hai Le on 9/23/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import "ViewController.h"
#include "MFCCProcessor.hpp"
#include <boost/scoped_array.hpp>
#include "WordMatch.h"
#include "Types.h"
#include "AudioFileReader.hpp"
#include "MFCCProcessor.hpp"
#include "MFCCUtils.h"
#include "CAHostTimeBase.h"
#include "CAStreamBasicDescription.h"

#include <algorithm>
#include <stdexcept>
#include <vector>

#define kAudioFile1 [[NSBundle mainBundle] pathForResource:@"good1" ofType:@"wav"]
#define kAudioFile2 [[NSBundle mainBundle] pathForResource:@"good2" ofType:@"wav"]

//const float kDefaultComparisonThreshold = 3.09f;
const float kDefaultTrimBeginThreshold = -27.0f;
const float kDefaultTrimEndThreshold = -40.0f;

@interface ViewController () {
    WMAudioFilePreProcessInfo _fileAInfo;
    WMAudioFilePreProcessInfo _fileBInfo;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ==================================================================
    // Read audio files from file paths
    NSURL *urlA = [NSURL URLWithString:kAudioFile1];
    [self _getPreProcessInfo:urlA
              beginThreshold:kDefaultTrimBeginThreshold
                endThreshold:kDefaultTrimEndThreshold
                        info:&_fileAInfo];
    
    NSURL *urlB = [NSURL URLWithString:kAudioFile2];
    [self _getPreProcessInfo:urlB
              beginThreshold:kDefaultTrimBeginThreshold
                endThreshold:kDefaultTrimEndThreshold
                        info:&_fileBInfo];
}

#pragma mark - Private
- (void)_getPreProcessInfo:(NSURL*)url beginThreshold:(float)bt endThreshold:(float)et info:(WMAudioFilePreProcessInfo*) fileInfo{

    CFURLRef cfurl = (CFURLRef)CFBridgingRetain(url);
    
    AudioFileReaderRef reader(new WM::AudioFileReader(cfurl));
    
    WMAudioFilePreProcessInfo fileInf = reader->preprocess(kDefaultTrimBeginThreshold,
                                    kDefaultTrimEndThreshold,
                                    1.0f);
    NSLog(@"For file %@", url);
    NSLog(@"Peak: %f", fileInf.max_peak);
    NSLog(@"Begin: %f", fileInf.threshold_start_time);
    NSLog(@"End: %f", fileInf.threshold_end_time);
    NSLog(@"Norm Factor: %f", fileInf.normalization_factor);
    
    *fileInfo = fileInf;
    
    AudioFileReaderRef reader_a(new WM::AudioFileReader(cfurl));
    FeatureTypeDTW::Features mfcc_features_a = get_mfcc_features(reader_a,
                                                                 fileInfo);
    
}

@end
