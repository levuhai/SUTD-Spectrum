//
//  ViewController.m
//  MFCCDemo
//
//  Created by Hai Le on 9/23/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import "ViewController.h"
#import "MatrixOuput.h"
#include "MFCCProcessor.hpp"
#include <boost/scoped_array.hpp>
#include "WordMatch.h"
#include "Types.h"
#include "AudioFileReader.hpp"
#include "MFCCProcessor.hpp"
#include "MFCCUtils.h"
#include "CAHostTimeBase.h"
#include <Accelerate/Accelerate.h>

// TAAE headers
#import "TheAmazingAudioEngine.h"
#import "TPOscilloscopeLayer.h"
#import "AERecorder.h"

#include <algorithm>
#include <stdexcept>
#include <vector>
#include <math.h>

#define kAudioFile1 [[NSBundle mainBundle] pathForResource:@"good1" ofType:@"wav"]
#define kAudioFile2 [[NSBundle mainBundle] pathForResource:@"good2" ofType:@"wav"]
#define kAudioFile3 [[NSBundle mainBundle] pathForResource:@"test" ofType:@"wav"]
#define MAX_NUM_FRAMES 500

//const float kDefaultComparisonThreshold = 3.09f;
const float kDefaultTrimBeginThreshold = -25.0f;
const float kDefaultTrimEndThreshold = -25.0f;

@interface ViewController () {
    WMAudioFilePreProcessInfo _fileAInfo;
    WMAudioFilePreProcessInfo _fileBInfo;
    BOOL _lastRecordingState;
    BOOL _currentRecordingState;
    std::vector<float> centroids; // dataY
    std::vector<float> indices; // dataX
    std::vector< std::vector<float> > normalisedOutput;
    std::vector<float> fitQuality;
}

@property (nonatomic, weak) IBOutlet MatrixOuput *matrixView;
@property (nonatomic, weak) IBOutlet MatrixOuput *fitQualityView;

@property (nonatomic, strong) TPOscilloscopeLayer *inputOscilloscope;
@property (nonatomic, strong) CALayer *inputLevelLayer;
@property (nonatomic, weak) NSTimer *levelsTimer;
@property (nonatomic, strong) AERecorder *recorder;
@property (nonatomic, strong) AEAudioFilePlayer *player;


@end

@implementation ViewController

AudioStreamBasicDescription AEAudioStreamBasicDescriptionMono = {
    .mFormatID          = kAudioFormatLinearPCM,
    .mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
    .mChannelsPerFrame  = 1,
    .mBytesPerPacket    = sizeof(float),
    .mFramesPerPacket   = 1,
    .mBytesPerFrame     = sizeof(float),
    .mBitsPerChannel    = 8 * sizeof(float),
    .mSampleRate        = 44100.0,
};

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",[self applicationDocuments]);
    [self _setupAudioController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.levelsTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                        target:self
                                                      selector:@selector(_updateLevels:)
                                                      userInfo:nil
                                                       repeats:YES];
}

#pragma mark - Private
// =============================================================================
// Setup Audio Controller and Oscilloscope View
- (void)_setupAudioController {
    // Amazing Audio Controller
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:AEAudioStreamBasicDescriptionMono inputEnabled:YES];
    _audioController.preferredBufferDuration = 0.005;
    _audioController.useMeasurementMode = YES;
    [_audioController start:NULL];
    
    // Oscilloscope
    self.inputOscilloscope = [[TPOscilloscopeLayer alloc] initWithAudioDescription:_audioController.audioDescription];
    _inputOscilloscope.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44-10);
    _inputOscilloscope.lineColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [self.headerView.layer addSublayer:_inputOscilloscope];
    [_audioController addInputReceiver:_inputOscilloscope];
    [_inputOscilloscope start];
    
    // Volume
    self.inputLevelLayer = [CALayer layer];
    _inputLevelLayer.backgroundColor = [[UIColor colorWithWhite:0.0 alpha:0.3] CGColor];
    _inputLevelLayer.frame = CGRectMake(0,
                                        _headerView.bounds.size.height-10,
                                        _headerView.bounds.size.width,
                                        10);
    [_headerView.layer addSublayer:_inputLevelLayer];
}

// =============================================================================
// Update Volume

static inline float translate(float val, float min, float max) {
    if ( val < min ) val = min;
    if ( val > max ) val = max;
    return (val - min) / (max - min);
}

- (void)_updateLevels:(NSTimer*)timer {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    Float32 inputAvg, inputPeak;
    [_audioController inputAveragePowerLevel:&inputAvg peakHoldLevel:&inputPeak];
    
    _inputLevelLayer.frame = CGRectMake(0,
                                        _headerView.bounds.size.height-10,
                                        translate(inputAvg,-40,0) * (_headerView.bounds.size.width),
                                        10);
    
    
    [CATransaction commit];
}

#pragma mark - Actions

- (IBAction)compareTouched:(id)sender {
    [self _compareFileA:kAudioFile2 fileB:[self testFilePath]];
}

- (IBAction)toggleRecording:(id)sender
{
    if ( _recorder ) {
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        self.recorder = nil;
        self.btnPlay.enabled = YES;
        //_recordButton.selected = NO;
    } else {
        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
        NSString *path = [self testFilePath];
        NSError *error = nil;
        if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileWAVEType error:&error] ) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[NSString stringWithFormat:@"Couldn't start recording: %@", [error localizedDescription]]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            self.recorder = nil;
            return;
        }
        
        //_recordButton.selected = YES;
        self.btnPlay.enabled = NO;
        [_audioController addOutputReceiver:_recorder];
        [_audioController addInputReceiver:_recorder];
    }
}

- (IBAction)playClicked:(id)sender {
    if ( _player ) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
        self.btnPlay.selected = NO;
    } else {
        NSString *path = [self testFilePath];
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:path] ) return;
        
        NSError *error = nil;
        self.player = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL fileURLWithPath:path] error:&error];
        
        if ( !_player ) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[NSString stringWithFormat:@"Couldn't start playback: %@", [error localizedDescription]]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
            return;
        }
        
        _player.removeUponFinish = YES;
        __weak ViewController *weakSelf = self;
        _player.completionBlock = ^{
            ViewController *strongSelf = weakSelf;
            strongSelf->_btnPlay.selected = NO;
            weakSelf.player = nil;
        };
        [_audioController addChannels:@[_player]];
        
        _btnPlay.selected = YES;
    }
}

- (FeatureTypeDTW::Features)_getPreProcessInfo:(NSURL*)url beginThreshold:(float)bt endThreshold:(float)et info:(WMAudioFilePreProcessInfo*) fileInfo{
    
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
    return get_mfcc_features(reader_a, fileInfo);
    
}

- (void)_compareFileA:(NSString*)pathA fileB:(NSString*)pathB {
    //------------------------------------------------------------------------------
    // Read audio files from file paths
    NSURL *urlA = [NSURL URLWithString:pathA];
    FeatureTypeDTW::Features featureA = [self _getPreProcessInfo:urlA
                                                  beginThreshold:kDefaultTrimBeginThreshold
                                                    endThreshold:kDefaultTrimEndThreshold
                                                            info:&_fileAInfo];
    
    NSURL *urlB = [NSURL URLWithString:pathB];
    FeatureTypeDTW::Features featureB = [self _getPreProcessInfo:urlB
                                                  beginThreshold:kDefaultTrimBeginThreshold
                                                    endThreshold:kDefaultTrimEndThreshold
                                                            info:&_fileBInfo];
    
    //------------------------------------------------------------------------------
    // Init SortedOutput[a*b]
    float *sortedOutput = new float[featureA.size()*featureB.size()];
    // Init Output[a][b]
    float **output = new float*[featureA.size()];
    for(int i = 0; i < featureA.size(); ++i) {
        output[i] = new float[featureB.size()];
    }
    
    // Set up matrix of MFCC similarity
    for (int i = 0; i<featureA.size(); i ++) {
        for (int j = 0; j<featureB.size(); j++) {
            float diff = 0;
            for (int k = 0; k<12; k++) {
                diff += (featureA[i][k] - featureB[j][k])*(featureA[i][k] - featureB[j][k]);
            }
            output[i][j] = sqrtf(diff);
            // Copy all the data from output into sorted output
            //NSLog(@"%f",output[i][j]);
            sortedOutput[i*featureB.size()+j] = output[i][j];
        }
    }
    
    // Sort
    vDSP_vsort(sortedOutput,featureA.size()*featureB.size(),1);
    
    // Output count
    float keepPct = 0.3f;
    float outputCount = featureA.size()*featureB.size();
    float maxDiff = sortedOutput[(int)roundf(keepPct*outputCount)];
    
    /*
     % initialize a new matrix to store the normalized output values
     normalizedOutput = output;
     % convert from output to normalized output.
     for i = 1:size(MFCC1,2)
     for j = 1:size(MFCC2,2)
     if output(i,j) > maxDiff
     % anything that isn't in the top keepPct%, set to 0
     normalizedOutput(i,j) = 0;
     else
     % anything that is in the top keepPct%, normalize to put it
     % between 0 and 1, with 1 being perfect match and 0 being
     % no match at all.
     normalizedOutput(i,j) = (maxDiff-output(i,j))/maxDiff;
     end
     end
     end
     */
    // Initialize new matrix to store normalized output values
    //float **normalizeOutput = new float*[featureA.size()];
    //    for(int i = 0; i < featureA.size(); ++i) {
    //        normalisedOutput[i] = new float[featureB.size()];
    //    }
    
    
    // make sure normalisedOutput is empty and has the correct size
    normalisedOutput.clear();
    normalisedOutput.resize(featureA.size());
    for (size_t i = 0; i<normalisedOutput.size(); i++){
        //normalisedOutput[i].clear();
        normalisedOutput[i].resize(featureB.size());
    }
    
    float maxVal = 0.0f; // Use to calculate alpha of matrix
    for (int i = 0; i<featureA.size(); i ++) {
        for (int j = 0; j<featureB.size(); j++) {
            if (output[i][j] > maxDiff) {
                normalisedOutput[i][j] = 0.0f;
            } else {
                float value = (maxDiff - output[i][j])/maxDiff;
                normalisedOutput[i][j] = value;
                
                if (value > maxVal) {
                    maxVal = value;
                }
            }
        }
    }
    
    
    centroids.clear();
    indices.clear();
    for (int i = 0; i < featureA.size(); i++) {
        float weightedSum = 0.0f;
        float sum = 0.0f;
        for (int j = 0; j < featureB.size(); j++) {
            weightedSum += normalisedOutput[i][j]*(float)j;
            sum += normalisedOutput[i][j];
        }
        // only push the result if the sum is nonzero
        if (sum > 0.0f){
            centroids.push_back(weightedSum/sum);
            indices.push_back(i); // index from 0, not 1 so don't use i+1 here
        }
    }
    
    float slope;
    float intercept;
    getLinearFit(&indices[0], &centroids[0], indices.size(), &slope, &intercept);
    
    //    % estimate quality of match at each part of the word
    //    timeTolerance = 10; % check values in the region +-timeTolerance frames of deviation from the best fit line
    //    fitQuality = zeros(size(MFCC2,2),1);
    //float *fitQuality = new float[featureB.size()];
    
    fitQuality.resize(featureB.size());
    float timeTolerance = 10;
    
    float fitLocation, toleranceWindowExcessLeft, toleranceWindowExcessRight, toleranceWindowStart, toleranceWindowEnd, maxGraph = 0.0f;
    for (int j = 0; j < featureB.size(); j++) {
        //        % find the location of the best fit line in the output matrix
        //        fitLocation = round(fitresult(j));
        fitLocation = roundf(linearFun(j, slope, intercept));
        
        //    % find out if the tolerance region around the fit line hangs over
        //        % the left or right edge of the matrix
        //        toleranceWindowExcessLeft = max(timeTolerance - fitLocation + 1,0);
        //    toleranceWindowExcessRight = max(timeTolerance + fitLocation - size(MFCC1,2),0);
        toleranceWindowExcessLeft = fmax(timeTolerance - fitLocation + 1,0);
        toleranceWindowExcessRight = fmax(timeTolerance + fitLocation - featureA.size(),0);
        
        //    % taking the overhang at the edges into account, compute the
        //    % boundaries of the tolerance region
        //    toleranceWindowStart = fitLocation - timeTolerance + toleranceWindowExcessLeft;
        //    toleranceWindowEnd = fitLocation + timeTolerance - toleranceWindowExcessRight;
        toleranceWindowStart = fitLocation - timeTolerance + toleranceWindowExcessLeft;
        toleranceWindowEnd = fitLocation + timeTolerance - toleranceWindowExcessRight;
        
        //    % the fit quality for the jth window is the best match value in the
        //        % region fitLocation (+-) timeTolerance
        //        fitQuality(j) = max(normalizedOutput(toleranceWindowStart:toleranceWindowEnd,j));
        float max = 0.0;
        for (int i = toleranceWindowStart-1; i<toleranceWindowEnd; i++) {
            if (normalisedOutput[i][j] > max) {
                max = normalisedOutput[i][j];
            }
        }
        // For graph drawing scale
        if (max > maxGraph) {
            maxGraph = max;
        }
        fitQuality[j-1] = max;
    }
    
    // Draw normalized data
    [self.matrixView inputNormalizedDataW:(int)featureB.size()
                                  matrixH:(int)featureA.size()
                                     data:normalisedOutput
                                     rect:self.view.bounds
                                   maxVal:maxVal];
    [self.fitQualityView inputFitQualityW:(int)featureB.size()
                                     data:fitQuality
                                     rect:self.view.bounds
                                   maxVal:MAX(maxGraph,1)];
    [self.matrixView setNeedsDisplay];
    [self.fitQualityView setNeedsDisplay];
}

inline float linearFun(float x, float slope, float intercept) {
    return x*slope + intercept;
}

void getLinearFit(float* xData, float* yData, size_t length, float* slope, float* intercept)
{
    float ssxx, ssxy, yMean, xMean, xSqSum, ySqSum, xyProdSum;
    
    // find the mean of the y and x values
    vDSP_meanv(yData,1,&yMean,length);
    vDSP_meanv(xData,1,&xMean,length);
    
    // sum the squares of x and y
    vDSP_svesq(yData,1,&ySqSum,length);
    vDSP_svesq(xData,1,&xSqSum,length);
    
    // sum the product of x and y
    //
    // multiply x * y and buffer the result into x
    vDSP_vmul(xData,1,yData,1,xData,1,length);
    vDSP_sve(xData,1,&xyProdSum,length);
    
    // ssxx is defined on line (17) of the mathworld link above
    ssxx = xSqSum - (float)length*xMean*xMean;
    
    // ssxy is defined on line (21)
    ssxy = xyProdSum - (float)length*yMean*xMean;
    
    *slope = ssxy/ssxx;
    *intercept = yMean - (*slope * xMean);
}

//------------------------------------------------------------------------------
#pragma mark - Utility
//------------------------------------------------------------------------------

- (NSArray *)applicationDocuments
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

//------------------------------------------------------------------------------

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

//------------------------------------------------------------------------------

- (NSURL *)testFilePathURL
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                   [self applicationDocumentsDirectory],
                                   @"test.wav"]];
}

- (NSString*)testFilePath {
    NSString* x = [NSString stringWithFormat:@"%@/%@",
                   [self applicationDocumentsDirectory],
                   @"test.wav"];
    NSLog(@"%@",x);
    return x;
}

@end
