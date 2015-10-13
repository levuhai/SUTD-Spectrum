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
const float kDefaultTrimBeginThreshold = -27.0f;
const float kDefaultTrimEndThreshold = -40.0f;

@interface ViewController () {
    WMAudioFilePreProcessInfo _fileAInfo;
    WMAudioFilePreProcessInfo _fileBInfo;
}

@property (nonatomic, weak) IBOutlet MatrixOuput *matrixView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ==================================================================
    // Read audio files from file paths
    NSURL *urlA = [NSURL URLWithString:kAudioFile1];
    FeatureTypeDTW::Features featureA = [self _getPreProcessInfo:urlA
              beginThreshold:kDefaultTrimBeginThreshold
                endThreshold:kDefaultTrimEndThreshold
                        info:&_fileAInfo];
    
    NSURL *urlB = [NSURL URLWithString:kAudioFile2];
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
    float *buffer = new float[featureA.size()];
    float slope;
    float intercept;
    
    for (int i = 0; i < featureA.size(); i++) {
        float *temp = normalizeOutput[i];
        float a = 0.0f;
        float sum = 0.0f;
        for (int j = 0; j < featureB.size(); j++) {
            a += normalizeOutput[i][j]*(j+1);
            sum+= temp[j];
        }
        dataY[i] = a / sum;
        dataX[i] = i+1;
    }
    
    getLinearFit(dataX, dataY, buffer, featureA.size(), &slope, &intercept);
    
//    % estimate quality of match at each part of the word
//    timeTolerance = 10; % check values in the region +-timeTolerance frames of deviation from the best fit line
//    fitQuality = zeros(size(MFCC2,2),1);
    float *fitQuality = new float[featureB.size()];
    float timeTolerance = 10;
    
    float fitLocation, toleranceWindowExcessLeft, toleranceWindowExcessRight, toleranceWindowStart, toleranceWindowEnd, maxGraph = 0.0f;
    for (int j = 1; j <= featureB.size(); j++) {
//        % find the location of the best fit line in the output matrix
//        fitLocation = round(fitresult(j));
        fitLocation = roundf(linearFun(j, slope, intercept));
        
//    % find out if the tolerance region around the fit line hangs over
//        % the left or right edge of the matrix
//        toleranceWindowExcessLeft = max(timeTolerance - fitLocation + 1,0);
//    toleranceWindowExcessRight = max(timeTolerance + fitLocation - size(MFCC1,2),0);
        toleranceWindowExcessLeft = fmax(timeTolerance - fitLocation + 1,0);
        toleranceWindowExcessRight = fmax(timeTolerance + fitLocation - featureB.size(),0);
        
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
//    [self.matrixView inputNormalizedDataW:(int)featureB.size()
//                                  matrixH:(int)featureA.size()
//                                     data:normalizeOutput
//                                     rect:self.view.bounds
//                                   maxVal:maxVal];
    [self.matrixView inputFitQualityW:(int)featureB.size()
                                 data:fitQuality
                                 rect:self.view.bounds
                               maxVal:maxGraph];
    [self.matrixView setNeedsDisplay];
}

#pragma mark - Private
inline float linearFun(float x, float slope, float intercept) {
    return x*slope + intercept;
}

void getLinearFit(float* Xdata, float* Ydata, float* buffer, size_t length, float* slope, float* intercept)
{
    float xSum, ySum, xxSum, xySum;
    
    //    for (size_t i = 0; i < length; i++)
    //    {
    //        xSum += xData[i];
    vDSP_sve(Xdata,1,&xSum,length);
    
    //        ySum += data[i];
    vDSP_sve(Ydata,1,&ySum,length);
    
    //        xxSum += xData[i] * xData[i];
    vDSP_svesq(Xdata,1,&xxSum,length);
    
    //        xySum += xData[i] * data[i];
    vDSP_vmul(Xdata,1,Ydata,1,Xdata,1,length); // buffer[i] = x[i]*y[i]
    vDSP_sve(buffer,1,&xySum,length);
    //    }
    
    
    *slope = (length * xySum - xSum * ySum) / (length * xxSum - xSum * xSum);
    *intercept = (ySum - (*slope)*xSum) / length;
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


@end
