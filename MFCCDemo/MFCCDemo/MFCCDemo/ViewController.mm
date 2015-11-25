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

#import "MFCCController.h"
#import "MFCC1Controller.h"
#import "MatrixController.h"

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
const float kDefaultTrimBeginThreshold = -100.0f;
const float kDefaultTrimEndThreshold = -100.0f;

@interface ViewController () {
    WMAudioFilePreProcessInfo _fileAInfo;
    WMAudioFilePreProcessInfo _fileBInfo;
    BOOL _lastRecordingState;
    BOOL _currentRecordingState;
    NSString* _currentAudioPath;
    
    std::vector<float> centroids; // dataY
    std::vector<float> indices; // dataX
    std::vector<float> matchedFrameQuality;
    std::vector< std::vector<float> > normalisedOutput;
    std::vector< std::vector<float> > trimmedNormalisedOutput;
    std::vector< std::vector<float> > bestFitLine;
    std::vector<float> fitQuality;
    
    MFCCController* _trimVC;
    MFCC1Controller* _trim1VC;
    MatrixController* _matrixVC;
    MatrixController* _matrix2VC;
}

@property (nonatomic, weak) IBOutlet MatrixOuput *matrixView;
@property (nonatomic, weak) IBOutlet MatrixOuput *bestFitView;
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
    _currentAudioPath = kAudioFile1;
    NSLog(@"%@",[self applicationDocuments]);
    
    // Setup UIScrollView
    // Trimming
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // First page
    _trimVC = [storyboard instantiateViewControllerWithIdentifier:@"TrimmingController"];
    _trimVC.view.frame = _scrollView.frame;
    [self.scrollView addSubview:_trimVC.view];
    [self addChildViewController:_trimVC];
    [_trimVC didMoveToParentViewController:self];
    // Second page
    _trim1VC = [storyboard instantiateViewControllerWithIdentifier:@"MFCCController"];
    CGRect f = _scrollView.frame;
    f.origin.x = self.view.frame.size.width;
    _trim1VC.view.frame = f ;
    [self.scrollView addSubview:_trim1VC.view];
    [self addChildViewController:_trim1VC];
    [_trim1VC didMoveToParentViewController:self];
    // Third page
    _matrixVC = [storyboard instantiateViewControllerWithIdentifier:@"MatrixController"];
    f = _scrollView.frame;
    f.origin.x = self.view.frame.size.width*2;
    _matrixVC.view.frame = f ;
    [self.scrollView addSubview:_matrixVC.view];
    [self addChildViewController:_matrixVC];
    [_matrixVC didMoveToParentViewController:self];
    // Forth page
    _matrix2VC = [storyboard instantiateViewControllerWithIdentifier:@"MatrixController"];
    f = _scrollView.frame;
    f.origin.x = self.view.frame.size.width*3;
    _matrix2VC.view.frame = f ;
    [self.scrollView addSubview:_matrix2VC.view];
    [self addChildViewController:_matrix2VC];
    [_matrix2VC didMoveToParentViewController:self];
    
    // Set content size;
    CGSize contentSize = _scrollView.frame.size;
    contentSize.width = self.view.frame.size.width*4;
    _scrollView.contentSize = contentSize;
    
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

#pragma mark - Actions

- (IBAction)compareTouched:(id)sender {
    [self _compareFileA:[self test1FilePath] fileB:_currentAudioPath];//[self testFilePath]
}

- (IBAction)changeSoundTouched:(UIButton*)sender {
    switch (sender.tag) {
        case 11:
            _currentAudioPath = kAudioFile1;
            break;
        case 12:
            _currentAudioPath = kAudioFile2;
            break;
        case 13:
            _currentAudioPath = kAudioFile3;
            break;
        default:
            break;
    }
    for (int i =11; i<=13;i++) {
        UIButton* button = (UIButton*)[self.view viewWithTag:i];
        button.selected = NO;
    }
    sender.selected = YES;
    
}

- (IBAction)toggleRecording:(id)sender
{
    if ( _recorder ) {
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        self.recorder = nil;
        //self.btnPlay.enabled = YES;
        //_recordButton.selected = NO;
    } else {
        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
        NSString *path = [self test1FilePath];
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
        //self.btnPlay.enabled = NO;
        [_audioController addOutputReceiver:_recorder];
        [_audioController addInputReceiver:_recorder];
    }
}

- (IBAction)playClicked:(id)sender {
    UIButton* button = (UIButton*)sender;
    if ( _player ) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
        button.selected = NO;
    } else {
        NSString *path = (button.tag==3?[self test1FilePath]:_currentAudioPath);
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
            button.selected = NO;
            weakSelf.player = nil;
        };
        [_audioController addChannels:@[_player]];
        
        button.selected = YES;
    }
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
    
    if (self.headerView) {
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
}

// =============================================================================
// Update Volume

static inline float _translate(float val, float min, float max) {
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
                                        _translate(inputAvg,-40,0) * (_headerView.bounds.size.width),
                                        10);
    
    
    [CATransaction commit];
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
    

    int sizeA = (int)featureA.size();
    int sizeB = (int)featureB.size();
    if (sizeA <= sizeB) {
        featureA = [self _getPreProcessInfo:urlB
                             beginThreshold:kDefaultTrimBeginThreshold
                               endThreshold:kDefaultTrimEndThreshold
                                       info:&_fileAInfo];
        featureB = [self _getPreProcessInfo:urlA
                             beginThreshold:kDefaultTrimBeginThreshold
                               endThreshold:kDefaultTrimEndThreshold
                                       info:&_fileBInfo];
        
        
    }
    sizeA = (int)featureA.size();
    sizeB = (int)featureB.size();
    
    //------------------------------------------------------------------------------
    // Init SortedOutput[a*b]
    float *sortedOutput = new float[sizeA*sizeB];
   
    // Init Output[a][b]
    float **output = new float*[sizeA];
    for(int i = 0; i < sizeA; ++i) {
        output[i] = new float[sizeB];
    }
    
    // Set up matrix of MFCC similarity
    for (int i = 0; i<sizeA; i ++) {
        for (int j = 0; j<sizeB; j++) {
            float diff = 0;
            for (int k = 0; k<12; k++) {
                diff += (featureA[i][k] - featureB[j][k])*(featureA[i][k] - featureB[j][k]);
            }
            output[i][j] = sqrtf(diff);
            // Copy all the data from output into sorted output
            //NSLog(@"%f",output[i][j]);
            sortedOutput[i*sizeB+j] = output[i][j];
        }
    }
    
    // Sort
    vDSP_vsort(sortedOutput,sizeA*sizeB,1);
     NSLog(@"min %f max %f",sortedOutput[0],sortedOutput[sizeA*sizeB-1]);
    
    // Output count
    float keepPct = 0.25f;
    float outputCount = sizeA*sizeB;
    float maxDiff = sortedOutput[(int)roundf(keepPct*outputCount)];
     NSLog(@"diff %f",maxDiff);
    //maxDiff = 7;
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
        
    // make sure normalisedOutput is empty and has the correct size
    normalisedOutput.clear();
    normalisedOutput.resize(sizeA);
    for (size_t i = 0; i<normalisedOutput.size(); i++){
        //normalisedOutput[i].clear();
        normalisedOutput[i].resize(sizeB);
    }
    
    float maxVal = 0.0f; // Use to calculate alpha of matrix
    for (int i = 0; i<sizeA; i ++) {
        for (int j = 0; j<sizeB; j++) {
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
    
/* -------------------------------------------------------------------------
 % find the contiguous region of MFCC1 that has the most matches to
 % MFCC2
 %
 %   find the total match quality for each frame of MFCC1
 matchedFrameQuality = zeros(size(MFCC1,2),1);
 for i = 1:size(MFCC1,2)
    matchedFrameQuality(i) = max(normalizedOutput(i,:));
 end
 */
    matchedFrameQuality.clear();
    matchedFrameQuality.resize(sizeA);
    for (int i = 0; i < sizeA; i++) {
        matchedFrameQuality[i] = *std::max_element(normalisedOutput[i].begin(), normalisedOutput[i].end());
    }
/* -------------------------------------------------------------------------
 %
 %   find the sliding window in MFCC1 of length equal to the entire MFCC2 that
 %   has the best match
 maxWindowSum = 0;
 maxWindowStart = 1;
 windowLength = size(MFCC2,2);
 for i = 1:(size(MFCC1,2)-size(MFCC2,2))
    slidingSum = 0;
    for j = i:(i + (windowLength-1))
       slidingSum = slidingSum + matchedFrameQuality(j);
    end
    if slidingSum > maxWindowSum
       maxWindowSum = slidingSum;
       maxWindowStart = i;
    end
 end
 */
    // TODO: if sizeA < sizeB ?
    
    float maxWindowSum = 0.0f;
    size_t windowLength = sizeB;
    int maxWindowStart = 0;
    
    //float windowSum = 0.0f;
    //int maxWindowSum = 0, maxWindowStart = 0, windowLength = sizeB;
//    for (size_t i = 0; i < windowLength; i++) {
//        windowSum += matchedFrameQuality[i];
//    }
//    for (size_t i = 0; i < sizeA - sizeB; i++) {
//        if (windowSum > maxWindowSum) {
//            maxWindowSum = windowSum;
//            maxWindowStart = i;
//        }
//        windowSum -= matchedFrameQuality[i];
//        windowSum += matchedFrameQuality[i+windowLength];
//    }
    for (int i = 0; i < sizeA - sizeB; i++) {
        float slidingSum = 0;
        for (int j = i; j < i+sizeB-1; j++) {
            slidingSum += matchedFrameQuality[j];
        }
        if (slidingSum > maxWindowSum) {
            maxWindowSum = slidingSum;
            maxWindowStart = i;
        }
    }
    
/* -------------------------------------------------------------------------
 %
 % the best MFCC2 length section of MFCC1 goes from maxWindowStart to
 % (maxWindowStart + (windowLength-1))
 %
 % now we will see if the match can be improved by lengthening the
 % window.
 %
 % scan back from the window start until we reach numZerosIgnorable consecutive frames
 % with match quality below windowExtensionThreshold
 */
    /* i = maxWindowStart;
     maxWindowEnd = maxWindowStart + windowLength - 1;
     numFound = 0;
     numZerosIgnorable = 2;
     while i > 0 && numFound <= numZerosIgnorable
        if matchedFrameQuality(i) < windowExtensionThreshold
           % we found a frame below the threshold
           numFound = numFound + 1;
        else
           % if this frame isn't below the threshold, reset the count
           numFound = 0;
        end
        i = i - 1;
     end
     */
    int i = maxWindowStart;
    size_t maxWindowEnd = maxWindowStart + windowLength ;
    int numFound = 0, numZerosIgnorable = 2;
    float windowExtensionThreshold = 0.15;
    while (i > 0 && numFound <= numZerosIgnorable) {
        if (matchedFrameQuality[i] < windowExtensionThreshold) {
            numFound += 1;
        } else {
            numFound = 0;
        }
        i -= 1;
    }
/*
 if numFound > numZerosIgnorable % we actually found a region of low match quality
 maxWindowStart = i + 1 + numZerosIgnorable;
 else % we didn't find the low match quality region but we reached the beginning of the array
 maxWindowStart = 1; % 0 in c++
 end
 */
    float newWindowStart;
    if (numFound > numZerosIgnorable) {
        newWindowStart = i + 1 + numZerosIgnorable;
    } else {
        newWindowStart = 0;
    }
    windowLength += maxWindowStart - newWindowStart;
    maxWindowStart = newWindowStart;

/* -------------------------------------------------------------------------
 %
 % now scan forward from the end of the maxWindow
 i = maxWindowStart + windowLength;
 numFound = 0;
 numZerosIgnorable = 3;
 while i <= size(matchedFrameQuality,1) && numFound < numZerosIgnorable
    if matchedFrameQuality(i) < windowExtensionThreshold
       % we found a frame below the threshold
       numFound = numFound + 1;
    else
       % if this frame isn't below the threshold, reset the count
       numFound = 0;
    end
    i = i + 1;
 end
 */
    
    i = maxWindowStart + windowLength ;
    numFound = 0;
    numZerosIgnorable = 3;
    while (i < matchedFrameQuality.size() && numFound < numZerosIgnorable) {
        if (matchedFrameQuality[i] < windowExtensionThreshold) {
            numFound += 1;
        } else {
            numFound = 0;
        }
        i += 1;
    }
    
/* -------------------------------------------------------------------------
 if numFound >= numZerosIgnorable % we actually found a region of low match quality
    maxWindowEnd = i - 1 - numZerosIgnorable;
 else % we didn't find the low match quality region but we reached the end of the array
    maxWindowEnd = size(matchedFrameQuality,1);
 end
 */
    if (numFound >= numZerosIgnorable)
        maxWindowEnd = i - 1 - numZerosIgnorable;
    else
        maxWindowEnd = matchedFrameQuality.size();
 
/* -------------------------------------------------------------------------
 %
 % we now know that the region between maxWindowStart and maxWindowEnd
 % is the region for which MFCC1 has good matching with MFCC2. We can
 % trum the normalizedOutput to discard the values outside this region
 trimmedNormalisedOutput = zeros(maxWindowEnd-maxWindowStart + 1,size(MFCC2,2));
 for i = maxWindowStart:maxWindowEnd
    for j = 1:size(MFCC2,2)
       trimmedNormalisedOutput(i - maxWindowStart + 1,j) = normalizedOutput(i,j);
    end
 end
 */
    // make sure normalisedOutput is empty and has the correct size
    trimmedNormalisedOutput.clear();
    trimmedNormalisedOutput.resize(maxWindowEnd-maxWindowStart + 1);
    for (size_t i = 0; i<trimmedNormalisedOutput.size(); i++){
        //normalisedOutput[i].clear();
        trimmedNormalisedOutput[i].resize(sizeB);
    }
    
    for (size_t i = maxWindowStart; i < maxWindowEnd; i++) {
        for (int j = 0; j < sizeB; j++) {
            trimmedNormalisedOutput[i - maxWindowStart + 1][j] = normalisedOutput[i][j];
        }
    }
 
/* -------------------------------------------------------------------------
 % find the centroid location in each row of the matrix using a weighted
 % average
 centroids = zeros(size(trimmedNormalisedOutput,1),1);
 for i = 1:size(trimmedNormalisedOutput,1)
    centroids(i) = trimmedNormalisedOutput(i,:)*(1:size(MFCC2,2))'/sum(trimmedNormalisedOutput(i,:));
 end
 */
    centroids.clear();
    indices.clear();
    for (int i = 0; i < trimmedNormalisedOutput.size(); i++) {
        float weightedSum = 0.0f;
        float sum = 0.0f;
        for (int j = 0; j < sizeB; j++) {
            weightedSum += trimmedNormalisedOutput[i][j]*(float)j;
            sum += trimmedNormalisedOutput[i][j];
        }
        // only push the result if the sum is nonzero
        if (sum > 0.0f){
            centroids.push_back(weightedSum/sum);
            indices.push_back(i); // index from 0, not 1 so don't use i+1 here
        }
    }
    
/* -------------------------------------------------------------------------
 % fit a linear function to the list of centroids
 [xData, yData] = prepareCurveData( [], centroids );
 
 % Set up fittype and options.
 ft = fittype( 'poly1' ); % linear regression
 opts = fitoptions( ft );
 opts.Lower = [-Inf -Inf]; % unbounded
 opts.Upper = [Inf Inf]; % unbounded
 
 % Fit model to data.
 [fitresult, gof] = fit( xData, yData, ft, opts );
 */
    float slope;
    float intercept;
    getLinearFit(&indices[0], &centroids[0], indices.size(), &slope, &intercept);

/* -------------------------------------------------------------------------
//    % estimate quality of match at each part of the word
//    timeTolerance = 10; % check values in the region +-timeTolerance frames of deviation from the best fit line
//    fitQuality = zeros(size(MFCC2,2),1);
*/
    
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
        for (int i = toleranceWindowStart-1; i<MIN(toleranceWindowEnd,trimmedNormalisedOutput.size()); i++) {
            if (trimmedNormalisedOutput[i][j] > max) {
                max = trimmedNormalisedOutput[i][j];
            }
        }
        // For graph drawing scale
        if (max > maxGraph) {
            maxGraph = max;
        }
        fitQuality[j-1] = max;
    }
    
    
    // Best fit line
    bestFitLine.clear();
    bestFitLine.resize(trimmedNormalisedOutput.size());
    for (size_t i = 0; i<bestFitLine.size(); i++){
        //normalisedOutput[i].clear();
        bestFitLine[i].resize(trimmedNormalisedOutput[0].size());
    }
    for (int i = 0; i < trimmedNormalisedOutput.size();i++) {
        for (int j = 0; j < trimmedNormalisedOutput[0].size();j++) {
            bestFitLine[i][j] = 0;
        }
        int y = roundf(linearFun(i, slope, intercept));
        if (y<0) y = 0;
        if (y>trimmedNormalisedOutput[0].size()) y = 0;
        bestFitLine[i][y] = 1;
    }

    // Page 1
    [_trimVC.graph1 inputMFCC:featureA start:(int)maxWindowStart end:(int)maxWindowEnd];
    [_trimVC.graph2 inputMFCC:featureB start:0 end:0];
    
    // Page 2
    [_trim1VC.graph1 inputMFCC:featureA start:(int)maxWindowStart end:(int)maxWindowEnd];
    
    // Page 3
    _matrixVC.upperView.graphColor = [UIColor greenColor];
    [_matrixVC.upperView inputNormalizedDataW:(int)bestFitLine[0].size()
                                  matrixH:(int)bestFitLine.size()
                                     data:bestFitLine
                                     rect:self.view.bounds
                                   maxVal:1];
    [_matrixVC.lowerView inputNormalizedDataW:(int)trimmedNormalisedOutput[0].size()
                                  matrixH:(int)trimmedNormalisedOutput.size()
                                     data:trimmedNormalisedOutput
                                     rect:self.view.bounds
                                   maxVal:maxGraph];
    // Page 4
    [_matrix2VC.upperView inputFitQualityW:(int)fitQuality.size()
                                     data:fitQuality
                                     rect:self.view.bounds
                                   maxVal:maxGraph];
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

- (NSString*)test2FilePath {
    NSString* x = [NSString stringWithFormat:@"%@/%@",
                   [self applicationDocumentsDirectory],
                   @"test2.wav"];
    NSLog(@"%@",x);
    return x;
}

- (NSString*)test1FilePath {
    NSString* x = [NSString stringWithFormat:@"%@/%@",
                   [self applicationDocumentsDirectory],
                   @"test1.wav"];
    NSLog(@"%@",x);
    return x;
}

@end
