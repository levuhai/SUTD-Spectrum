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
#include "CAStreamBasicDescription.h"
#include <Accelerate/Accelerate.h>

#include <algorithm>
#include <stdexcept>
#include <vector>
#include <math.h>

#define kAudioFile1 [[NSBundle mainBundle] pathForResource:@"good1" ofType:@"wav"]
#define kAudioFile2 [[NSBundle mainBundle] pathForResource:@"good2" ofType:@"wav"]

//const float kDefaultComparisonThreshold = 3.09f;
const float kDefaultTrimBeginThreshold = -25.0f;
const float kDefaultTrimEndThreshold = -25.0f;

@interface ViewController () <EZMicrophoneDelegate, EZRecorderDelegate> {
    WMAudioFilePreProcessInfo _fileAInfo;
    WMAudioFilePreProcessInfo _fileBInfo;
    BOOL _lastRecordingState;
    BOOL _currentRecordingState;
}

@property (nonatomic, weak) IBOutlet MatrixOuput *matrixView;
@property (nonatomic, weak) IBOutlet MatrixOuput *fitQualityView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupMicrofone];
}

#pragma mark - Private
- (IBAction)compareTouched:(id)sender {
    [self _compareFileA:kAudioFile1 fileB:[self testFilePath]];
}
- (IBAction)toggleRecording:(id)sender
{
    if ([sender isOn])
    {
        //
        // Create the recorder
        //
        
        self.recorder = [EZRecorder recorderWithURL:[self testFilePathURL]
                                       clientFormat:[self.microphone audioStreamBasicDescription]
                                           fileType:EZRecorderFileTypeWAV
                                           delegate:self];
        //self.playButton.enabled = YES;
    } else {
        [self.recorder closeAudioFile];
    }
    self.isRecording = (BOOL)[sender isOn];
    self.lbRecordingState.text = self.isRecording ? @"Recording" : @"Not Recording";
}

- (void)_setupMicrofone {
    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    
    //
    // Start the microphone
    //
    [self.microphone startFetchingAudio];
}

- (float)_getDecibelsFromVolume:(float**)buffer withBufferSize:(UInt32)bufferSize {
    
    // Decibel Calculation.
    
    float one = 1.0;
    float meanVal = 0.0;
    float tiny = 0.1;
    float lastdbValue = 0.0;
    
    vDSP_vsq(buffer[0], 1, buffer[0], 1, bufferSize);
    
    vDSP_meanv(buffer[0], 1, &meanVal, bufferSize);
    
    vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
    
    
    // Exponential moving average to dB level to only get continous sounds.
    
    float currentdb = 1.0 - (fabs(meanVal) / 100);
    
    if (lastdbValue == INFINITY || lastdbValue == -INFINITY || std::isnan(lastdbValue)) {
        lastdbValue = 0.0;
    }
    
    float dbValue = ((1.0 - tiny) * lastdbValue) + tiny * currentdb;
    
    lastdbValue = dbValue;
    
    return dbValue;
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
    // ==================================================================
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
    
    // ==================================================================
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
    float **normalizeOutput = new float*[featureA.size()];
    for(int i = 0; i < featureA.size(); ++i) {
        normalizeOutput[i] = new float[featureB.size()];
    }
    
    float maxVal = 0.0f; // Use to calculate alpha of matrix
    for (int i = 0; i<featureA.size(); i ++) {
        for (int j = 0; j<featureB.size(); j++) {
            if (output[i][j] > maxDiff) {
                normalizeOutput[i][j] = 0.0f;
            } else {
                float value = (maxDiff - output[i][j])/maxDiff;
                normalizeOutput[i][j] = value;
                
                if (value > maxVal) {
                    maxVal = value;
                }
            }
        }
    }
    
    // centroids
    float *dataY = new float[featureA.size()]; // = cendroids
    float *dataX = new float[featureA.size()];
    for (int i = 0; i < featureA.size(); i++) {
        float *temp = normalizeOutput[i];
        float a = 0.0f;
        float sum = 0.0f;
        for (int j = 0; j < featureB.size(); j++) {
            a += normalizeOutput[i][j]*(j);
            sum+= temp[j];
        }
        dataY[i] = a / sum;
        dataX[i] = i+1;
    }
    //    // centroids
    //    std::vector<float> centroids; // dataY
    //    std::vector<float> indices; // dataX
    //
    //
    //
    //    for (int i = 0; i < featureA.size(); i++) {
    //        float centroid = 0.0f;
    //        float sum = 0.0f;
    //        for (int j = 0; j < featureB.size(); j++) {
    //            centroid += normalizeOutput[i][j]*(float)j;
    //            sum += normalizeOutput[i][j];
    //        }
    //        centroids.push_back(centroid/sum);
    //        indices.push_back(i); // index from 0, not 1 so don't use i+1 here
    //    }
    //
    //    float* dataY = &centroids[0];
    //    float* dataX = &indices[0];
    float *buffer = new float[featureA.size()];
    float slope;
    float intercept;
    getLinearFit(dataX, dataY, buffer, featureA.size(), &slope, &intercept);
    
    //    % estimate quality of match at each part of the word
    //    timeTolerance = 10; % check values in the region +-timeTolerance frames of deviation from the best fit line
    //    fitQuality = zeros(size(MFCC2,2),1);
    float *fitQuality = new float[featureB.size()];
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
            if (normalizeOutput[i][j] > max) {
                max = normalizeOutput[i][j];
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
                                     data:normalizeOutput
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

void getLinearFit(float* xData, float* yData, float* buffer, size_t length, float* slope, float* intercept)
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
#pragma mark - EZMicrophoneDelegate
//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone changedPlayingState:(BOOL)isPlaying
{
    
}

- (void)   microphone:(EZMicrophone *)microphone
        hasBufferList:(AudioBufferList *)bufferList
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
    if (self.isRecording)
    {
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
}

- (void)   microphone:(EZMicrophone *)microphone
     hasAudioReceived:(float **)buffer
       withBufferSize:(UInt32)bufferSize
 withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    __weak typeof (self) weakSelf = self;
//    float decibels = [self _getDecibelsFromVolume:buffer withBufferSize:bufferSize];
//    if (decibels > 0.072) {
//        [self _startRecording];
//    } else {
//        [self _stopRecording];
//    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        //[weakSelf.recordingAudioPlot updateBuffer:buffer[0]
          //                         withBufferSize:bufferSize];
        weakSelf.recordingState.backgroundColor = weakSelf.isRecording ? [UIColor greenColor] : [UIColor redColor];
//        weakSelf.lbRecordingState.text = _currentRecordingState ? @"Recording" : @"Not Recording";
    });
}

//------------------------------------------------------------------------------
#pragma mark - EZRecorderDelegate
//------------------------------------------------------------------------------

- (void)recorderDidClose:(EZRecorder *)recorder
{
    recorder.delegate = nil;
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
