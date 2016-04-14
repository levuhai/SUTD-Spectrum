//
//  SUTDMFCCHelperFunctions.c
//  MFCCDemo
//
//  Created by Hans on 14/4/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#include "SUTDMFCCHelperFunctions.h"


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