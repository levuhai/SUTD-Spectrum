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
void bestMatchLocation(const std::vector< std::vector<float> >& M, size_t startColumn, size_t endColumn, size_t* startRow, size_t* endRow, size_t numRows){
    assert(startColumn <= endColumn);
    assert(endColumn < M.at(0).size());
    assert(numRows <= M.size());
    
    // initialize variables related to length and height of match region
    size_t targetPhonemeLength = 1 + endColumn - startColumn;
    size_t matchRegionHeight = targetPhonemeLength < numRows ? targetPhonemeLength : numRows;
    
    
    // get the total match score for each row
    std::vector<float> rowScores(matchRegionHeight);
    for(size_t i=0; i<matchRegionHeight; i++){
        rowScores.at(i) = 0.0f;
        for(size_t j=startColumn;j<=endColumn;j++)
            rowScores.at(i) += M.at(i).at(j);
    }
    
    
    // find the vertical location of the match region with the highest score
    float matchRegionScore, matchRegionMaxScore = 0.0f;
    for(size_t k=0; k<=numRows-matchRegionHeight; k++){
        matchRegionScore = 0.0f;
        
        for(size_t i=0; i<matchRegionHeight; i++){
            // add emphasis to the scores of rows in the centre of the region
            // to bias the match region toward centreing itself on the
            // best matching features
            float rowEmphasis = i < matchRegionHeight/2 ? i+matchRegionHeight : 2*matchRegionHeight - (i + 1);
            
            matchRegionScore += rowScores.at(i+k) * rowEmphasis;
        }
        
        // if the current placement has the highest score so far, record its
        // startRow
        if (matchRegionScore > matchRegionMaxScore) {
            matchRegionMaxScore = matchRegionScore;
            *startRow = k;
        }
    }
    
    *endRow = *startRow + matchRegionHeight;
}


/*
 * estimates the degree of directionality in the match region between
 * the specified start and end row and columns in the matrix M.
 *
 * return values > 0 indicate forward direction
 * return values near 0 indicate non-directional feature matches
 * return values < 0 indicate reverse directional feature matching
 */
float matchDirection(const std::vector< std::vector<float> >& M,
                     size_t startColumn, size_t endColumn,
                     size_t startRow, size_t endRow){
    // height corresponds to user voice length, width to database phoneme
    size_t matchRegionHeight = 1 + endRow - startRow;
    size_t matchRegionWidth = 1 + endColumn - startColumn;
    assert(matchRegionWidth >= matchRegionHeight);
    
    /*
     * This function works by measuring the similarity in corresponding
     * elements in neighboring diagonal rows inside the match region.
     * If the diagonal rows slanting in the upward direction
     * (looking from L to R) are more similar to their neighbors than
     * the rows slanted in the downward direction then the features
     * match in forward order.
     *
     * Taking diagonal rows in both diagonal directions produces a square
     * subsection of the matrix M, but it is a square tilted at a 45 degree
     * angle. We call this tilted square the working diamond.  It is centred
     * in the match region and has odd numbered height and width.
     *
     * We extract the working diamond from M and copy it into its own matrix,
     * which is rotated by 45 degrees so that we can iterate over its rows
     * and columns without needing to calculate array indices in a diagonal
     * direction.
     */
    
    
    /*
     * find the height of the working diamond
     */
    size_t workingDiamondHeight = matchRegionHeight;
    // force the height to be an odd number
    if (matchRegionHeight % 2 == 1) matchRegionHeight--;
    size_t workingDiamondWidth = workingDiamondHeight;
    
    /*
     * find the central column of the working diamond
     */
    size_t workingDiamondCentreColumn = startColumn + (workingDiamondWidth/2);
    // slide it over to centre if the match region is not square
    workingDiamondCentreColumn += (matchRegionWidth - workingDiamondWidth)/2;
    
    /*
     * Copy the working diamond into a square matrix so that its diagonal rows
     * can be indexed more easily
     */
    size_t diamondSquareLength = 1 + (workingDiamondHeight/2);
    std::vector< std::vector<float> > diamondSquare(diamondSquareLength);
    for(size_t i=0; i<diamondSquareLength; i++)
        diamondSquare.at(i).resize(diamondSquareLength);
    for(size_t i=0; i<diamondSquareLength; i++)
        for(size_t j=0; j<diamondSquareLength; j++)
            diamondSquare.at(i).at(j) = M.at(startRow+i+j).at(workingDiamondCentreColumn+i-j);
    
    /*
     * Find the squared difference between elements in adjacent rows
     */
    float forwardSquaredDifference = 0.0001;
    for(size_t i=0; i<diamondSquareLength-1; i++)
        for(size_t j=0; j<diamondSquareLength; j++){
            float d = diamondSquare.at(i).at(j)-diamondSquare.at(i+1).at(j);
            forwardSquaredDifference += d*d;
        }
    
    /*
     * Find the squared difference between elements in adjacent columns
     */
    float backwardSquaredDifference = 0.0001;
    for(size_t i=0; i<diamondSquareLength; i++)
        for(size_t j=0; j<diamondSquareLength-1; j++){
            float d = diamondSquare.at(i).at(j)-diamondSquare.at(i).at(j+1);
            backwardSquaredDifference += d*d;
        }
    
    return logf(backwardSquaredDifference/forwardSquaredDifference);
}

float matchScore(const std::vector< std::vector<float> >& M,
                 size_t startColumn, size_t endColumn,
                 size_t startRow, size_t endRow){
    float score = 0.0f;
    for(size_t i=startRow; i<=endRow; i++)
        for(size_t j=startColumn; j<=endColumn; j++)
            score += M.at(i).at(j)*M.at(i).at(j);
    
    float height = endRow - startRow + 1;
    float width = endColumn - startColumn + 1;
    
    return sqrt(score) / (height*width);
}