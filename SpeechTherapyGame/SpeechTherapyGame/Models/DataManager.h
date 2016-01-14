//
//  DataManager.h
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

// Singleton methods
+ (id) shared;

// Sounds DB
- (NSMutableArray*)getWords;
- (NSMutableArray*)getRandomWords;
- (NSMutableArray*)getWordsFromPhoneme:(NSString*)p;
- (NSMutableArray *)getUniqueWordsFromPhoneme:(NSString *)p;
- (NSMutableArray*)getUniquePhoneme;

// Stats DB
- (void)insertRandomScore;
- (NSMutableArray*)getScores;
- (NSMutableArray*)getScoresFrom:(NSDate*)from to:(NSDate*)to;

@end
