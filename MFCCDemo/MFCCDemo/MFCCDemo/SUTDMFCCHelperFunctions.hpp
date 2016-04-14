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

void similarityMatrix(FeatureTypeDTW::Features a, FeatureTypeDTW::Features b, size_t featureLength, float** matrix);

void normaliseMatrix(const float** M, std::vector< std::vector<float> >& MN, size_t sizeA, size_t sizeB);

#endif /* SUTDMFCCHelperFunctions_h */
