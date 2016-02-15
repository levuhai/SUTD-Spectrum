//
//  MFCCAudioController.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/1/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "MFCCAudioController.h"

#include "MFCCProcessor.hpp"
#include <boost/scoped_array.hpp>
#include "WordMatch.h"
#include "Types.h"
#include "AudioFileReader.hpp"
#include "MFCCProcessor.hpp"
#include "MFCCUtils.h"
#include "CAHostTimeBase.h"
#include <Accelerate/Accelerate.h>
#import "Word.h"

#include <algorithm>
#include <stdexcept>
#include <vector>
#include <math.h>

@implementation MFCCAudioController

const float kDefaultTrimBeginThreshold = -200.0f;
const float kDefaultTrimEndThreshold = -200.0f;

+ (float)scoreFileA:(NSString*)pathA fileB:(Word*)pathB {
    float _startTrimPercentage;
    float _endTrimPercentage;
    
    std::vector<float> centroids; // dataY
    std::vector<float> indices; // dataX
    std::vector<float> matchedFrameQuality;
    std::vector< std::vector<float> > normalisedOutput;
    std::vector< std::vector<float> > trimmedNormalisedOutput;
    std::vector< std::vector<float> > bestFitLine;
    std::vector< std::vector<float> > nearLineMatrix;
    std::vector<float> fitQuality;
    
    WMAudioFilePreProcessInfo _fileAInfo;
    WMAudioFilePreProcessInfo _fileBInfo;
    
    //------------------------------------------------------------------------------
    // Read audio files from file paths
    NSURL *urlA = [NSURL URLWithString:pathA];
    FeatureTypeDTW::Features featureA = [MFCCAudioController _getPreProcessInfo:urlA
                                                  beginThreshold:kDefaultTrimBeginThreshold
                                                    endThreshold:kDefaultTrimEndThreshold
                                                            info:&_fileAInfo];
    
    NSURL *urlB = [NSURL URLWithString:[pathB fullFilePath]];
    FeatureTypeDTW::Features featureB = [MFCCAudioController _getPreProcessInfo:urlB
                                                  beginThreshold:kDefaultTrimBeginThreshold
                                                    endThreshold:kDefaultTrimEndThreshold
                                                            info:&_fileBInfo];
    
    
    int sizeA = (int)featureA.size();
    int sizeB = (int)featureB.size();
    if (sizeA <= sizeB) {
        featureA = [MFCCAudioController _getPreProcessInfo:urlB
                             beginThreshold:kDefaultTrimBeginThreshold
                               endThreshold:kDefaultTrimEndThreshold
                                       info:&_fileAInfo];
        featureB = [MFCCAudioController _getPreProcessInfo:urlA
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
    // TODO: maxDiff
    maxDiff = 7;//maxDiff*0.5;
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
    Word* w = pathB;
    int start = sizeB*(float)w.start/(float)w.fullLen;
    int end = sizeB*(float)w.end/(float)w.fullLen;
    
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
    
    fitQuality.resize(featureB.size());
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
    float timeTolerance = 10;
    for (int y = 0; y < trimmedNormalisedOutput.size();y++) {
        for (int x = start-1; x < end;x++) {
            if (pointToLineDistance(x-start+1,y,slope,intercept)>timeTolerance) {
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
    
    float sumScore = 0.0f;
    for (int i = start-1; i<end; i++) {
        sumScore+= fitQuality[i];
    }
    float score = sumScore/(end-start+1);
    return score;
}

+ (FeatureTypeDTW::Features)_getPreProcessInfo:(NSURL*)url beginThreshold:(float)bt endThreshold:(float)et info:(WMAudioFilePreProcessInfo*) fileInfo{
    
    CFURLRef cfurl = (CFURLRef)CFBridgingRetain(url);
    
    AudioFileReaderRef reader(new WM::AudioFileReader(cfurl));
    
    WMAudioFilePreProcessInfo fileInf = reader->preprocess(kDefaultTrimBeginThreshold,
                                                           kDefaultTrimEndThreshold,
                                                           1.0f);
//    NSLog(@"For file %@", url);
//    NSLog(@"Peak: %f", fileInf.max_peak);
//    NSLog(@"Begin: %f", fileInf.threshold_start_time);
//    NSLog(@"End: %f", fileInf.threshold_end_time);
//    NSLog(@"Norm Factor: %f", fileInf.normalization_factor);
    
    *fileInfo = fileInf;
    
    AudioFileReaderRef reader_a(new WM::AudioFileReader(cfurl));
    return get_mfcc_features(reader_a, fileInfo);
    
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

@end
