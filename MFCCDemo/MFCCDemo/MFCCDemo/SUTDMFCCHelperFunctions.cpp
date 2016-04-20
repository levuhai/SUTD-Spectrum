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
    
    for(size_t i=0; i<2; i++){
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
void bestMatchLocation(const std::vector< std::vector<float> >& M, size_t startColumn, size_t endColumn, size_t& startRow, size_t& endRow, bool splitRegion){
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
        
        float matchRegionScore;
        // calcuate the score using the split region method
        if (splitRegion)
            matchRegionScore = matchScoreSplitRegion(M, startColumn, endColumn, k, k+matchRegionHeight-1);
        // calculate the score using the single region method
        else
            matchRegionScore = matchScoreSingleRegion(M, startColumn, endColumn, k, k+matchRegionHeight-1,true);
        
        // if this is the match region with the highest score so far
        if(matchRegionScore > matchRegionMaxScore){
            startRow = k;
            matchRegionMaxScore = matchRegionScore;
        }
    }
    
    endRow = startRow + matchRegionHeight - 1;
}



float matchScoreSingleRegion(const std::vector< std::vector<float> >& M,
                 size_t startColumn, size_t endColumn,
                 size_t startRow, size_t endRow, bool emphasizeDiagonal){
    
    // check that the match region is square
    size_t height = endRow - startRow + 1;
    size_t width = endColumn - startColumn + 1;
    assert(height = width);
    assert(endRow >= startRow);
    
    float score = 0.0f, totalEmphasis = 0.0;
    float edgeLength = 1.0 + (float)endColumn - (float) startColumn;
    for(size_t i=0; i<height; i++)
        for(size_t j=0; j<width; j++){
            
            // intialize the emphasis to give equal weight everywhere
            float emphasis = 1.0f;
            
            // if required, emphasize values near the diagonal more heavily
            if(emphasizeDiagonal)
                emphasis = edgeLength - fabsf((float)j - (float)i);
            
            // keep track of how much emphasis we used
            totalEmphasis += emphasis;
            
            // calculate the emphasized score
            score += M.at(i+startRow).at(j+startColumn)*M.at(i+startRow).at(j+startColumn)*emphasis;
        }
    
    return score / totalEmphasis;
}


float matchScoreSplitRegion(const std::vector< std::vector<float> >& M,
                            size_t startColumn, size_t endColumn,
                            size_t startRow, size_t endRow){
    
    // check that the match region is square
    size_t height = endRow - startRow + 1;
    size_t width = endColumn - startColumn + 1;
    assert(height = width);
    assert(endRow >= startRow);
    size_t size = height;
    
    // if the height is 1 then the region can not actually be split; just
    // fall back on the single-region function
    if(height == 1)
        return matchScoreSingleRegion(M,startColumn,endColumn,startRow,endRow,false);
    
    /*
     *  We split the match region into four regions as follows:
     *
     *       1 | 2
     *       -----
     *       3 | 4
     *
     *  The score is given by r1*r4 - r2*r3
     *
     *  For split-region phonemes with perfect match, only regions 1 and 4
     *  have matching phonemes. If
     */
    
    
    // get the size of region 1
    size_t r1Size = size/2;
    
    // get score for region 1
    size_t r1sc = startColumn;
    size_t r1ec = startColumn + r1Size-1;
    size_t r1sr = startRow;
    size_t r1er = startRow + r1Size-1;
    float r1 = matchScoreSingleRegion(M, r1sc, r1ec, r1sr, r1er, false);

    // get score for region 2
    size_t r2sc = r1ec+1;
    size_t r2ec = endColumn;
    size_t r2sr = r1sr;
    size_t r2er = r1er;
    float r2 = matchScoreSingleRegion(M, r2sc, r2ec, r2sr, r2er, false);
    
    // get score for region 3
    size_t r3sc = r1sc;
    size_t r3ec = r1ec;
    size_t r3sr = r1er+1;
    size_t r3er = endRow;
    float r3 = matchScoreSingleRegion(M, r3sc, r3ec, r3sr, r3er, false);
    
    // get score for region 2
    size_t r4sc = r1ec+1;
    size_t r4ec = endColumn;
    size_t r4sr = r1er+1;
    size_t r4er = endRow;
    float r4 = matchScoreSingleRegion(M, r4sc, r4ec, r4sr, r4er, false);
    
    // get score
    float score = (r1*r3) - (r2*r4);
    
    // don't allow negative scores
    if (score < 0) score = 0;
    
    /*
     * The values of r1 and r3 are about 0.3 when there is a perfect match.
     * Multiplying r1*r3 gives a score of 0.09, for a perfect match. If there
     * is some spill into r2 and r4, this will be lower. Based on this
     * idea, we estimate that the score for split region matches is about 1/4
     * as high as the score for single region matches. We compensate for that
     * difference below.
     */
    score *= 4.0;
    
    return score;
}