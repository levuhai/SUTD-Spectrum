//
//  SUTDMFCCHelperFunctions.c
//  MFCCDemo
//
//  Created by Hans on 14/4/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#include "SUTDMFCCHelperFunctions.hpp"

#define SUTDMFCC_MATCH_THRESHOLD 7.0f

/*
 * take a and b as vectors in the space R^n
 * return the euclidean distance
 */
float euclideanDistance(FeatureTypeDTW::FeatureVector a, FeatureTypeDTW::FeatureVector b, size_t n){
    
    float distanceSquared = 0.0f;
    
    for(size_t i=0; i<n; i++){
        float diff = a[i] - b[i];
        distanceSquared += diff*diff;
    }
    
    return sqrtf(distanceSquared);
}

/*
 * Compute a matrix of similarity, the euclidean distance between each pair 
 * feature vectors in a and b
 */
void similarityMatrix(FeatureTypeDTW::Features a, FeatureTypeDTW::Features b, size_t featureLength, float** matrix){
    
    for (int i = 0; i<a.size(); i++)
        for (int j = 0; j<b.size(); j++)
            matrix[i][j] = euclideanDistance(a[i], b[j],featureLength);
}

/* 
 * zero out values that are too large to be similar 
 * then invert the remaining values so that they become larger
 * when the match is more similar.
 */
void normaliseMatrix(const float** M, std::vector< std::vector<float> >& MN, size_t sizeA, size_t sizeB){
    
    for (int i = 0; i<sizeA; i ++) {
        for (int j = 0; j<sizeB; j++) {
            
            // zero out values above the threshold
            if (M[i][j] > SUTDMFCC_MATCH_THRESHOLD) {
                MN[i][j] = 0.0f;
            }
            
            // invert values above the threshold
            else {
                MN[i][j] = (SUTDMFCC_MATCH_THRESHOLD - M[i][j])/SUTDMFCC_MATCH_THRESHOLD;
            }
        }
    }
    
}