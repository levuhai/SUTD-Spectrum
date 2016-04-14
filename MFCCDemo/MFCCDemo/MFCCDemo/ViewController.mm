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
#import <MZFormSheetController/MZFormSheetController.h>
#include "WordMatch.h"
#include "Types.h"
#include "AudioFileReader.hpp"
#include "MFCCProcessor.hpp"
#include "MFCCUtils.h"
#include "CAHostTimeBase.h"
#include <Accelerate/Accelerate.h>
#import "SelectionTable.h"
#import "DataManager.h"
#import "Word.h"
#include "SUTDMFCCHelperFunctions.hpp"

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
#define SUTDMFCC_FEATURE_LENGTH 12

//const float kDefaultComparisonThreshold = 3.09f;
const float kDefaultTrimBeginThreshold = -200.0f;
const float kDefaultTrimEndThreshold = -200.0f;

@interface ViewController () {
    WMAudioFilePreProcessInfo _fileAInfo;
    WMAudioFilePreProcessInfo _fileBInfo;
    BOOL _lastRecordingState;
    BOOL _currentRecordingState;
    int _currentIndex;
    NSString* _currentAudioPath;
    NSString* _currentRecordPath;
    Word* _currentWord;
    
    std::vector<float> centroids; // dataY
    std::vector<float> indices; // dataX
    std::vector<float> matchedFrameQuality;
    std::vector< std::vector<float> > normalisedOutput;
    std::vector< std::vector<float> > trimmedNormalisedOutput;
    std::vector< std::vector<float> > bestFitLine;
    std::vector< std::vector<float> > nearLineMatrix;
    std::vector<float> fitQuality;
    
    MFCCController* _trimVC;
    MFCC1Controller* _trim1VC;
    MatrixController* _matrixVC;
    MatrixController* _matrix2VC;
    
    float _startTrimPercentage;
    float _endTrimPercentage;
    NSMutableArray* words;
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
//    _trim1VC = [storyboard instantiateViewControllerWithIdentifier:@"MFCCController"];
    CGRect f = _scrollView.frame;
//    f.origin.x = self.view.frame.size.width;
//    _trim1VC.view.frame = f ;
//    [self.scrollView addSubview:_trim1VC.view];
//    [self addChildViewController:_trim1VC];
//    [_trim1VC didMoveToParentViewController:self];
    // Third page
    _matrixVC = [storyboard instantiateViewControllerWithIdentifier:@"MatrixController"];
    f = _scrollView.frame;
    f.origin.x = self.view.frame.size.width;
    _matrixVC.view.frame = f ;
    [self.scrollView addSubview:_matrixVC.view];
    [self addChildViewController:_matrixVC];
    [_matrixVC didMoveToParentViewController:self];
    // Forth page
    _matrix2VC = [storyboard instantiateViewControllerWithIdentifier:@"MatrixController"];
    f = _scrollView.frame;
    f.origin.x = self.view.frame.size.width*2;
    _matrix2VC.view.frame = f ;
    [self.scrollView addSubview:_matrix2VC.view];
    [self addChildViewController:_matrix2VC];
    [_matrix2VC didMoveToParentViewController:self];
    
    // Set content size;
    CGSize contentSize = _scrollView.frame.size;
    contentSize.width = self.view.frame.size.width*3;
    _scrollView.contentSize = contentSize;
    
    [self _setupAudioController];
}

#pragma mark - Actions

- (IBAction)selectTouched:(id)sender {
    SelectionTable *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"selection"];
    vc.showRecordedSounds = NO;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.cornerRadius = 0.0;
    formSheet.presentedFormSheetSize = CGSizeMake(self.view.bounds.size.width-40, self.view.bounds.size.height-200);
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
        SelectionTable* t = (SelectionTable*)presentedFSViewController;
        _currentWord = t.selectedWord;
        _lbWord.text = [[_currentWord.croppedPath lastPathComponent] stringByDeletingPathExtension];
        _currentAudioPath = [[NSBundle mainBundle] pathForResource:[_currentWord.fullPath stringByDeletingPathExtension] ofType:@"wav" inDirectory:@"sounds"];
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        //do sth
        NSLog(@"asdfsadf");
    }];
    
}

- (IBAction)selectRecordTouched:(id)sender {
    SelectionTable *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"selection"];
    vc.showRecordedSounds = YES;
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    formSheet.shouldDismissOnBackgroundViewTap = NO;
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.cornerRadius = 0.0;
    formSheet.presentedFormSheetSize = CGSizeMake(self.view.bounds.size.width-40, self.view.bounds.size.height-200);
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController){
        SelectionTable* t = (SelectionTable*)presentedFSViewController;
        _currentRecordPath = t.selectedRecordPath;
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        //do sth
        NSLog(@"asdfsadf");
    }];
    
}

- (IBAction)compareTouched:(id)sender {
    [self _compareFileA:_currentRecordPath fileB:_currentAudioPath];//[self testFilePath]
    [self playRecordClicked:nil];
}

- (IBAction)stopRecording:(id)sender {
    if ( _recorder ) {
        [_recorder finishRecording];
        [_audioController removeOutputReceiver:_recorder];
        [_audioController removeInputReceiver:_recorder];
        self.recorder = nil;
        //self.btnPlay.enabled = YES;
        //_recordButton.selected = NO;
    }
}

- (IBAction)startRecording:(id)sender
{
     if ( !_recorder ) {
        self.recorder = [[AERecorder alloc] initWithAudioController:_audioController];
        NSString *path = [self testFilePath];
        NSError *error = nil;
        if ( ![_recorder beginRecordingToFileAtPath:path fileType:kAudioFileWAVEType bitDepth:32 channels:1 error:&error] ) {
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

- (IBAction)playRecordClicked:(UIButton*)button {
    if ( _player ) {
        [_audioController removeChannels:@[_player]];
        self.player = nil;
        button.selected = NO;
    } else {
        NSString *path = (button.tag==3?[self test1FilePath]:_currentRecordPath);
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
        if (button == nil) {
            NSLog(@"%f",self.player.duration*_startTrimPercentage);
            self.player.currentTime = self.player.duration*_startTrimPercentage;
            [self performSelector:@selector(_stop)
                       withObject:nil
                       afterDelay:self.player.duration*(_endTrimPercentage-_startTrimPercentage)];
        }
        
        button.selected = YES;
    }
}

- (IBAction)playClicked:(UIButton*)button {
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
- (void)_stop {
    [_audioController removeChannels:@[_player]];
    self.player = nil;
    self.playrecord.selected = NO;
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
}

// =============================================================================
// Update Volume

static inline float _translate(float val, float min, float max) {
    if ( val < min ) val = min;
    if ( val > max ) val = max;
    return (val - min) / (max - min);
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
    NSURL *urlA = [NSURL URLWithString:[pathA stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    FeatureTypeDTW::Features featureA = [self _getPreProcessInfo:urlA
                                                  beginThreshold:kDefaultTrimBeginThreshold
                                                    endThreshold:kDefaultTrimEndThreshold
                                                            info:&_fileAInfo];
    
    NSURL *urlB = [NSURL URLWithString:[pathB stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    FeatureTypeDTW::Features featureB = [self _getPreProcessInfo:urlB
                                                  beginThreshold:kDefaultTrimBeginThreshold
                                                    endThreshold:kDefaultTrimEndThreshold
                                                            info:&_fileBInfo];
    

    int sizeA = (int)featureA.size();
    int sizeB = (int)featureB.size();
//    if (sizeA <= sizeB) {
//        featureA = [self _getPreProcessInfo:urlB
//                             beginThreshold:kDefaultTrimBeginThreshold
//                               endThreshold:kDefaultTrimEndThreshold
//                                       info:&_fileAInfo];
//        featureB = [self _getPreProcessInfo:urlA
//                             beginThreshold:kDefaultTrimBeginThreshold
//                               endThreshold:kDefaultTrimEndThreshold
//                                       info:&_fileBInfo];
//        
//        
//    }
//    sizeA = (int)featureA.size();
//    sizeB = (int)featureB.size();
    
    //------------------------------------------------------------------------------
   
    // Init Output[a][b]
    float **output = new float*[sizeA];
    for(int i = 0; i < sizeA; ++i) {
        output[i] = new float[sizeB];
    }
    
    // Set up matrix of MFCC similarity
    for (int i = 0; i<sizeA; i++) {
        for (int j = 0; j<sizeB; j++) {
            output[i][j] = euclideanDistance(featureA[i], featureB[j],SUTDMFCC_FEATURE_LENGTH);
        }
    }
    
    float maxDiff = 7;

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
    long recoredSize = maxWindowEnd - maxWindowStart + 1;
    long originSize = sizeB;
    
    trimmedNormalisedOutput.clear();
    trimmedNormalisedOutput.resize(recoredSize);
    for (size_t i = 0; i<trimmedNormalisedOutput.size(); i++){
        //normalisedOutput[i].clear();
        trimmedNormalisedOutput[i].resize(originSize);
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
    // Start/End of phoneme
    Word* w = _currentWord;
    int start = sizeB*(float)w.targetStart/(float)w.fullLen;
    int end = sizeB*(float)w.targetEnd/(float)w.fullLen;
    
    centroids.clear();
    indices.clear();
    centroids.resize(originSize);
    indices.resize(originSize);
    
    for (int x = start-1; x < end; x++) {
        float weightedSum = 0.0f;
        float sum = 0.0f;
        for (int y = 0; y < recoredSize; y++) {
            weightedSum += trimmedNormalisedOutput[y][x]*(float)x;
            sum += trimmedNormalisedOutput[y][x];
        }
        // only push the result if the sum is nonzero
        if (sum > 0.0f){
            centroids.push_back(weightedSum/sum);
            indices.push_back(x-start); // index from 0, not 1 so don't use i+1 here
        }
//        else {
//            centroids.push_back(0);
//            indices.push_back(i);
//        }
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
    
    fitQuality.resize(sizeB);
    // Best fit line
    bestFitLine.clear();
    nearLineMatrix.clear();
    bestFitLine.resize(trimmedNormalisedOutput.size());
    nearLineMatrix.resize(trimmedNormalisedOutput.size());
    for (size_t i = 0; i<bestFitLine.size(); i++){
        //normalisedOutput[i].clear();
        bestFitLine[i].resize(trimmedNormalisedOutput[0].size());
        nearLineMatrix[i].resize(trimmedNormalisedOutput[0].size());
    }
    
    // Point near fit line
    float timeTolerance = 7;
    for (int y = 0; y < trimmedNormalisedOutput.size();y++) {
        for (int x = start-1; x < end;x++) {
            if (pointToLineDistance(x-start+1,y,slope,intercept)>timeTolerance && (slope <0 || slope >=0.75)) {
                nearLineMatrix[y][x] = 0;
            } else {
                nearLineMatrix[y][x] = trimmedNormalisedOutput[y][x];
            }
        }
    }
    
    for (int i = 0; i < nearLineMatrix[0].size();i++) {
        float max = 0;
        int selected = 0;
        for (int j = 0; j < nearLineMatrix.size();j++) {
            if (nearLineMatrix[j][i]>max) {
                max = nearLineMatrix[j][i];
                selected = j;
            }
        }
        trimmedNormalisedOutput[selected][i] = 999;
        fitQuality[i] = max;
    }
    
    
//    for (int i = 0; i < trimmedNormalisedOutput.size();i++) {
//        for (int j = 0; j < trimmedNormalisedOutput[0].size();j++) {
//            bestFitLine[i][j] = 0;
//        }
//        int y = roundf(linearFun(i, slope, intercept));
//        if (y<0) y = 0;
//        if (y>trimmedNormalisedOutput[0].size()) y = 0;
//        bestFitLine[i][y] = 1;
//    }

    _startTrimPercentage = maxWindowStart/(float)sizeA;
    _endTrimPercentage  = maxWindowEnd/(float)sizeA;
    // Page 1
    [_trimVC.graph1 inputMFCC:featureA start:(int)maxWindowStart end:(int)maxWindowEnd];
    [_trimVC.graph2 inputMFCC:featureB start:0 end:0];
    
    // Page 2
    //[_trim1VC.graph1 inputMFCC:featureA start:(int)maxWindowStart end:(int)maxWindowEnd];
    
    // Page 3
    _matrixVC.upperView.graphColor = [UIColor greenColor];
    [_matrixVC.upperView inputNormalizedDataW:(int)nearLineMatrix[0].size()
                                  matrixH:(int)nearLineMatrix.size()
                                     data:nearLineMatrix
                                     rect:self.view.bounds
                                   maxVal:1];
    [_matrixVC.lowerView inputNormalizedDataW:(int)trimmedNormalisedOutput[0].size()
                                  matrixH:(int)trimmedNormalisedOutput.size()
                                     data:trimmedNormalisedOutput
                                     rect:self.view.bounds
                                   maxVal:1];
    // Page 4
    [_matrix2VC.upperView inputFitQualityW:(int)fitQuality.size()
                                     data:fitQuality
                                     rect:self.view.bounds
                                   maxVal:2 start:start end:end];
    [self _score:start end:end];
}

- (void)_score:(int)start end:(int)end {
    float sum = 0.0f;
    for (int i = start; i<end; i++) {
        sum+= fitQuality[i];
        NSLog(@"fit %f",fitQuality[i]);
    }
    float score = sum/(end-start+1);
    self.lbScore.text = [NSString stringWithFormat:@"%.3f",score];
}

inline float linearFun(float x, float slope, float intercept) {
    return x*slope + intercept;
}

inline float pointToLineDistance(float x, float y, float slope, float intercept) {
    // ax + by + c = 0;
    float a = slope;
    float b = -1;
    float c = intercept;
    return fabsf(a*x + b*y + c)/sqrtf((a*a)+(b*b));
    
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

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

//------------------------------------------------------------------------------

- (NSURL *)testFilePathURL
{
    NSDate* d = [NSDate date];
    NSString* name = [NSString stringWithFormat:@"%.0f.wav",d.timeIntervalSince1970];
    _currentRecordPath = [NSString stringWithFormat:@"%@/%@",
                          [self applicationDocumentsDirectory],
                          name];
    return [NSURL fileURLWithPath:_currentRecordPath];
}

- (NSString *)testFilePath
{
    NSDate* d = [NSDate date];
    NSString* name = [NSString stringWithFormat:@"%.0f.wav",d.timeIntervalSince1970];
    _currentRecordPath = [NSString stringWithFormat:@"%@/%@",
                          [self applicationDocumentsDirectory],
                          name];
    return _currentRecordPath;
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
