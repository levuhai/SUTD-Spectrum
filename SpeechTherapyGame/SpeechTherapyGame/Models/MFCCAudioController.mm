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
#include "SUTDMFCCHelperFunctions.hpp"

#include <algorithm>
#include <stdexcept>
#include <vector>
#include <math.h>

@implementation MFCCAudioController

const float kDefaultTrimBeginThreshold = -200.0f;
const float kDefaultTrimEndThreshold = -200.0f;


+ (float)scoreUserVoiceMemoryTest:(NSString*)userVoicePath dbVoice:(Word*)databaseVoiceWord {
    
    
    WMAudioFilePreProcessInfo userVoiceFileInfo;
    WMAudioFilePreProcessInfo databaseVoiceFileInfo;
    
    
    /*
     * Read audio files from file paths
     */
    NSURL *userVoiceURL = [NSURL URLWithString:userVoicePath];
    FeatureTypeDTW::Features userVoiceFeatures = [self _getPreProcessInfo:userVoiceURL
                                                           beginThreshold:kDefaultTrimBeginThreshold
                                                             endThreshold:kDefaultTrimEndThreshold
                                                                     info:&userVoiceFileInfo];
    
    
    NSURL *databaseVoiceURL = [NSURL URLWithString:[databaseVoiceWord fullFilePath]];
    FeatureTypeDTW::Features databaseVoiceFeatures = [self _getPreProcessInfo:databaseVoiceURL
                                                               beginThreshold:kDefaultTrimBeginThreshold
                                                                 endThreshold:kDefaultTrimEndThreshold
                                                                         info:&databaseVoiceFileInfo];
    
    for(size_t i=0; i < 100; i++){
        std::vector<float> foo (1000);
        for(size_t j=0; j<foo.size(); j++)
            foo.at(j) = MAXFLOAT;
    }
    
    return 0.0f;
}

+ (float)scoreUserVoice:(NSString*)userVoicePath dbVoice:(Word*)databaseVoiceWord {
    
    
    WMAudioFilePreProcessInfo userVoiceFileInfo;
    WMAudioFilePreProcessInfo databaseVoiceFileInfo;
    
    
    /*
     * Read audio files from file paths
     */
    NSURL *userVoiceURL = [NSURL URLWithString:userVoicePath];
    FeatureTypeDTW::Features userVoiceFeatures = [self _getPreProcessInfo:userVoiceURL
                                                           beginThreshold:kDefaultTrimBeginThreshold
                                                             endThreshold:kDefaultTrimEndThreshold
                                                                     info:&userVoiceFileInfo];
    

    NSURL *databaseVoiceURL = [NSURL URLWithString:[databaseVoiceWord fullFilePath]];
    FeatureTypeDTW::Features databaseVoiceFeatures = [self _getPreProcessInfo:databaseVoiceURL
                                                               beginThreshold:kDefaultTrimBeginThreshold
                                                                 endThreshold:kDefaultTrimEndThreshold
                                                                         info:&databaseVoiceFileInfo];
    
    
    // where does the target phoneme start and end in the database word?
    size_t targetPhonemeStartInDB = databaseVoiceFeatures.size()*(float)databaseVoiceWord.targetStart/(float)databaseVoiceWord.fullLen;
    size_t targetPhonemeEndInDB = databaseVoiceFeatures.size()*(float)databaseVoiceWord.targetEnd/(float)databaseVoiceWord.fullLen;
    
    
    
    // Clamp the target phoneme location within the valid range of indices.
    // Note that the size_t type is not signed so we don't need to clamp at
    // zero.
    if(targetPhonemeStartInDB >= databaseVoiceFeatures.size())
        targetPhonemeStartInDB = databaseVoiceFeatures.size()-1;
    if(targetPhonemeEndInDB >= databaseVoiceFeatures.size())
        targetPhonemeEndInDB = databaseVoiceFeatures.size()-1;
    
    
    
    // if the user voice recording is shorter than the target phoneme, we  pad it with copies of its last element to get a square match region.
    size_t targetPhonemeLength = 1 + targetPhonemeEndInDB - targetPhonemeStartInDB;
    if(userVoiceFeatures.size() < targetPhonemeLength)
        userVoiceFeatures.resize(targetPhonemeLength,userVoiceFeatures.back());
    
    
    /*
     * ensure that the similarity matrix arrays have enough space to store
     * the matrix
     */
    /*
     * initialize the similarity matrix
     */
    std::vector< std::vector<float> > similarityMatrix;
    if(similarityMatrix.size() != userVoiceFeatures.size())
        similarityMatrix.resize(userVoiceFeatures.size());
    for(size_t i=0; i<userVoiceFeatures.size(); i++)
        if(similarityMatrix[i].size() != databaseVoiceFeatures.size())
            similarityMatrix[i].resize(databaseVoiceFeatures.size());
    
    
    // calculate the matrix of similarity
    genSimilarityMatrix(userVoiceFeatures, databaseVoiceFeatures, similarityMatrix);
    
    
    // normalize the output
    normaliseMatrix(similarityMatrix);
    
    // TODO: change this value
    /*
     * Phonemes that depend on the vowel sounds before and after do
     * better with split-region scoring
     */
    bool splitRegionScoring = [self _needSplitRegion:databaseVoiceWord];// for S this is false, for K it is true.
    
    
    // find the vertical location of a square match region, centred on the
    // target phoneme and the rows in the user voice that best match it.
    size_t matchRegionStartInUV, matchRegionEndInUV;
    bestMatchLocation(similarityMatrix, targetPhonemeStartInDB, targetPhonemeEndInDB, matchRegionStartInUV, matchRegionEndInUV, splitRegionScoring);
    
    float score;
    if(splitRegionScoring)
        score = matchScoreSplitRegion(similarityMatrix,
                                      targetPhonemeStartInDB, targetPhonemeEndInDB,
                                      matchRegionStartInUV, matchRegionEndInUV);
    else
        score = matchScoreSingleRegion(similarityMatrix,
                                       targetPhonemeStartInDB, targetPhonemeEndInDB,
                                       matchRegionStartInUV, matchRegionEndInUV, true);
    
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
    CFRelease(cfurl);
    return get_mfcc_features(reader_a, fileInfo);
    
}

+ (BOOL)_needSplitRegion:(Word*)w {
    NSArray* consonants = @[@"k",@"t"];
    if ([consonants containsObject:w.phoneme]) {
        return YES;
    }
    return NO;
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
