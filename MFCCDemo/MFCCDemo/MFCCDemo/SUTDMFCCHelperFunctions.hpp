//
//  SUTDMFCCHelperFunctions.h
//  MFCCDemo
//
//  Created by Hans on 14/4/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#ifndef SUTDMFCCHelperFunctions_h
#define SUTDMFCCHelperFunctions_h

#include "MFCCUtils.h"

float euclideanDistance(FeatureTypeDTW::FeatureVector a, FeatureTypeDTW::FeatureVector b, size_t n);

void genSimilarityMatrix(FeatureTypeDTW::Features a, FeatureTypeDTW::Features b, size_t featureLength, std::vector< std::vector<float> >& M);

void normaliseMatrix(std::vector< std::vector<float> >& M);

void bestMatchLocation(const std::vector< std::vector<float> >& M, size_t startRow, size_t endRow, size_t* startColumn, size_t* endColumn, size_t numRows);

float matchDirection(const std::vector< std::vector<float> >& M,
                     size_t startColumn, size_t endColumn,
                     size_t startRow, size_t endRow);

float matchScore(const std::vector< std::vector<float> >& M,
                 size_t startColumn, size_t endColumn,
                 size_t startRow, size_t endRow);

#endif /* SUTDMFCCHelperFunctions_h */