//
//  DataManager.h
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Score;

@interface DataManager : NSObject

// Singleton methods
+ (id) shared;
@property (nonatomic, assign) BOOL practisingWordLv;
@property (nonatomic, assign) BOOL practisingSyllableLv;
@property (nonatomic, assign) NSInteger difficultyIndex;
@property (nonatomic, readonly) float difficultyValue;

// Sounds DB
- (NSMutableArray*)getWords;
- (NSMutableArray*)getRandomWords;
- (NSMutableArray*)getWordsFromPhoneme:(NSString*)p;
- (NSMutableArray *)getUniqueWordsFromPhoneme:(NSString *)p;
- (NSMutableArray*)getUniquePhoneme;
- (NSMutableArray*)getWordLevel;
- (NSMutableArray*)getPhonemeLevel;

// Stats DB
- (void)insertScore:(Score*)score;
- (void)insertRandomScore;
- (NSMutableArray*)getScores;
- (NSMutableArray*)getScoresFrom:(NSDate*)from to:(NSDate*)to;

@end
