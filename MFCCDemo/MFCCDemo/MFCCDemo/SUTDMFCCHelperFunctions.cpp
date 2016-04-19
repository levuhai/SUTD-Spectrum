//
//  SUTDMFCCHelperFunctions.c
//  MFCCDemo
//
//  Created by Hans on 14/4/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#include "SUTDMFCCHelperFunctions.hpp"

#define SUTDMFCC_MATCH_THRESHOLD 7.0f
#define SUTDMFCC_FEATURE_LENGTH 12

/*
 * take a and b as vectors in the space R^n
 * return the euclidean distance
 */
float euclideanDistance(const FeatureTypeDTW::FeatureVector& a, const FeatureTypeDTW::FeatureVector& b){
    
    // the feature length should be 12
    assert(a.size() == SUTDMFCC_FEATURE_LENGTH);
    
    // both vectors must have the same length
    assert(a.size() == b.size());
    
    float distanceSquared = 0.0f;
    
    for(size_t i=0; i<a.size(); i++){
        float diff = a.at(i) - b.at(i);
        distanceSquared += diff*diff;
    }
    
    return sqrtf(distanceSquared);
}

/*
 * Compute a matrix of similarity, the euclidean distance between each pair
 * feature vectors in a and b
 */
void genSimilarityMatrix(const FeatureTypeDTW::Features& userVoice, const FeatureTypeDTW::Features& databaseVoice, std::vector< std::vector<float> >& M){
    
    assert(userVoice.size() == M.size());
    assert(databaseVoice.size() == M.at(0).size());
    
    for (int i = 0; i<userVoice.size(); i++)
        for (int j = 0; j<databaseVoice.size(); j++)
            M.at(i).at(j) = euclideanDistance(userVoice.at(i), databaseVoice.at(j));
}

/*
 * zero out values that are too large to be similar
 * then invert the remaining values so that they become larger
 * when the match is more similar.
 */
void normaliseMatrix(std::vector< std::vector<float> >& M){
    
    for (int i = 0; i<M.size(); i ++) {
        for (int j = 0; j<M.at(0).size(); j++) {
            
            // zero out values above the threshold
            if (M.at(i).at(j) > SUTDMFCC_MATCH_THRESHOLD) M.at(i).at(j) = 0.0f;
            
            
            // invert values above the threshold
            else
                M.at(i).at(j) = (SUTDMFCC_MATCH_THRESHOLD - M.at(i).at(j))/SUTDMFCC_MATCH_THRESHOLD;
            
        }
    }
}


/*
 * The user voice is indexed by row; the database voice is indexed by column
 *
 * The start and end column of the target phoneme in the database voice are
 * given as input.
 *
 * The start and end row of the match region centred around the closest
 * matching features are set as output.
 */
void bestMatchLocation(const std::vector< std::vector<float> >& M, size_t startColumn, size_t endColumn, size_t& startRow, size_t& endRow){
    assert(startColumn <= endColumn);
    assert(endColumn < M.at(0).size());
    
    
    /*
     * find the height of the match region
     */
    // use a square match region
    size_t matchRegionWidth = 1 + endColumn - startColumn;
    size_t matchRegionHeight = matchRegionWidth;
    
    
    /*
     * the height of the matrix must be at least the height of the match
     * region.
     */
    assert (M.size() >= matchRegionHeight);
    
    
    /*
     * We already returned in the previous if statement so everything below
     * this line will only happen if the match region is square.
     */
    
    float matchRegionMaxScore = 0.0;
    for(size_t k=0; k<=M.size()-matchRegionHeight; k++){
        
        float matchRegionScore = matchScore(M, startColumn, endColumn, k, k+matchRegionHeight-1);
        
        // if this is the match region with the highest score so far
        if(matchRegionScore > matchRegionMaxScore){
            startRow = k;
            matchRegionMaxScore = matchRegionScore;
        }
    }
    
    endRow = startRow + matchRegionHeight - 1;
}



float matchScore(const std::vector< std::vector<float> >& M,
                 size_t startColumn, size_t endColumn,
                 size_t startRow, size_t endRow){
    
    // check that the match region is square
    float height = endRow - startRow + 1;
    float width = endColumn - startColumn + 1;
    assert(height = width);
    
    float score = 0.0f, totalEmphasis = 0.0;
    float edgeLength = 1.0 + (float)endColumn - (float) startColumn;
    for(size_t i=0; i<height; i++)
        for(size_t j=0; j<width; j++){
            // emphasize values near the diagonal
            float emphasis = edgeLength - fabsf((float)j - (float)i);
            
            // keep track of how much emphasis we used
            totalEmphasis += emphasis;
            
            // calculate the emphasized score
            score += M.at(i+startRow).at(j+startColumn)*M.at(i+startRow).at(j+startColumn)*emphasis;
        }
    
    return score / totalEmphasis;
}