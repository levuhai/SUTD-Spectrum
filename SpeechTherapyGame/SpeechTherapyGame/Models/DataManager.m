//
//  DataManager.m
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "DataManager.h"
#import <FMDB/FMDB.h>
#import "Word.h"
#import "Score.h"

@implementation DataManager {
    NSString* _soundsDBPath;
    NSString* _statsDBPath;
    NSArray* _sliderValues;
}

static DataManager *sharedInstance = nil;

#pragma mark - Singleton
+ (id)shared {
    @synchronized(self)
    {
        if (sharedInstance == nil) {
            sharedInstance = [[DataManager alloc] init];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance; // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        _sliderValues = @[@0.35, @0.4, @0.45];
        
        _soundsDBPath = [self copyToDocuments:@"sound.sqlite"];
        NSLog(@"Sound DB Path: %@",_soundsDBPath);
        _statsDBPath = [self copyToDocuments:@"score.sqlite"];
        NSLog(@"Stats DB Path: %@",_statsDBPath);

        //[self insertRandomScore];
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *recordingFolder = [doc stringByAppendingString:@"/recordings"];
        [[NSFileManager defaultManager] createDirectoryAtPath:recordingFolder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return self;
}

- (NSString*)copyToDocuments:(NSString*)dbName {
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePathInDocument = [documentsDirectory stringByAppendingPathComponent:dbName];
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePathInDocument]) {
        NSString* sourcePath = [[NSBundle mainBundle] pathForResource:dbName
                                                               ofType:nil];
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath
                                                toPath:filePathInDocument
                                                 error:&error];
        
        NSLog(@"Error description-%@ \n", [error localizedDescription]);
        NSLog(@"Error reason-%@", [error localizedFailureReason]);
    }
    
    return filePathInDocument;
}
#pragma mark - Properties
//
// Syllable Level
- (void)setPractisingSyllableLv:(BOOL)practisingSyllableLv {
    [NSStandardUserDefaults setBool:practisingSyllableLv forKey:kKeySyllableLevel];
}
- (BOOL)practisingSyllableLv {
    if (![NSStandardUserDefaults hasValueForKey:kKeySyllableLevel]) {
        return YES;
    } else {
        return [NSStandardUserDefaults boolForKey:kKeySyllableLevel];
    }
}
//
// Word Level
- (void)setPractisingWordLv:(BOOL)practisingWordLv {
    [NSStandardUserDefaults setBool:practisingWordLv forKey:kKeyWordLevel];
}
- (BOOL)practisingWordLv {
    if (![NSStandardUserDefaults hasValueForKey:kKeyWordLevel]) {
        return YES;
    } else {
        return [NSStandardUserDefaults boolForKey:kKeyWordLevel];
    }
}
//
// Difficulty Index
- (void)setDifficultyIndex:(NSInteger)difficultyIndex{
    [NSStandardUserDefaults setInteger:difficultyIndex forKey:kKeyDifficulty];
}
- (NSInteger)difficultyIndex {
    if (![NSStandardUserDefaults hasValueForKey:kKeyDifficulty]) {
        return 1.0;
    } else {
        return [NSStandardUserDefaults integerForKey:kKeyDifficulty];
    }
}
//
// Difficulty value
- (float)difficultyValue {
    return [_sliderValues[self.difficultyIndex] floatValue];
}


#pragma mark - Private
- (FMDatabaseQueue*)_soundDBQueue {
    return [FMDatabaseQueue databaseQueueWithPath:_soundsDBPath];
}
- (FMDatabaseQueue*)_scoreDBQueue {
    return [FMDatabaseQueue databaseQueueWithPath:_statsDBPath];
}

#pragma mark - Word

- (NSMutableArray*)getWords {
    if (self.practisingSyllableLv && !self.practisingWordLv) {
        return [self getPhonemeLevel];
    } else if (!self.practisingSyllableLv && self.practisingWordLv) {
        return [self getWordLevel];
    } else  if (!self.practisingSyllableLv && !self.practisingWordLv) {
        return nil;
    } else {
        __block NSMutableArray* lvs = [NSMutableArray new];
        FMDatabaseQueue* db = [self _soundDBQueue];
        
        
        
        [db inDatabase:^(FMDatabase *db) {
            NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] GROUP BY [sound]"];
            FMResultSet *results = [db executeQuery:sql];
            while([results next]) {
                @autoreleasepool {
                    NSDictionary* dict = results.resultDictionary;
                    Word* lv = [[Word alloc] initWithDictionary:dict];
                    if (lv != nil) {
                        [lvs addObject:lv];
                    }
                    
                }
            }
            [results close];
        }];
        [db close];
        return lvs;
    }
}

- (NSMutableArray *)getWordLevel {
    __block NSMutableArray* lvs = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [sound] != [phonetic] GROUP BY [sound] ORDER BY [phoneme]"];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                NSDictionary* dict = results.resultDictionary;
                Word* lv = [[Word alloc] initWithDictionary:dict];
                if (lv != nil) {
                    [lvs addObject:lv];
                }
                
            }
        }
        [results close];
    }];
    [db close];
    return lvs;
}

- (NSMutableArray *)getPhonemeLevel {
    __block NSMutableArray* lvs = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [phonetic] = [sound] GROUP BY [sound]"];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                NSDictionary* dict = results.resultDictionary;
                Word* lv = [[Word alloc] initWithDictionary:dict];
                if (lv != nil) {
                    [lvs addObject:lv];
                }
                
            }
        }
        [results close];
    }];
    [db close];
    return lvs;
}

- (NSMutableArray *)getUniquePhoneme {
    __block NSMutableArray* unique = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT DISTINCT p_text FROM [db]"];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                [unique addObject:[results stringForColumnIndex:0]];
            }
        }
        [results close];
    }];
    [db close];
    
    return unique;
}

- (NSMutableArray *)getUniqueWordsFromPhoneme:(NSString *)p {
    // Select all sounds from randomized word
    __block NSMutableArray* result = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [p_text] = '%@' GROUP BY [w_text] ORDER BY [w_phonetic]",p];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                NSDictionary* dict = results.resultDictionary;
                Word* w = [[Word alloc] initWithDictionary:dict];
                if (w != nil) {
                    [result addObject:w];
                }
                
            }
        }
        [results close];
    }];
    [db close];
    
    return result;
}

- (NSMutableArray *)getWordsFromPhoneme:(NSString *)p {
    // Select all sounds from randomized word
    __block NSMutableArray* result = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [p_text] = '%@'",p];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                NSDictionary* dict = results.resultDictionary;
                Word* w = [[Word alloc] initWithDictionary:dict];
                if (w != nil) {
                    [result addObject:w];
                }
                
            }
        }
        [results close];
    }];
    [db close];
    
    return result;
}

- (NSMutableArray*)getRandomWords {
    // Select unique words from DB
    __block NSMutableArray* uniqueWords = [self getWords];
    
    FMDatabaseQueue* db = [self _soundDBQueue];
    // Random index
    int rndValue = 0 + arc4random() % (uniqueWords.count - 0);
    
    // Select all sounds from randomized word
    __block NSMutableArray* result = [NSMutableArray new];
    db = [self _soundDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        Word* w = (Word*)uniqueWords[rndValue];
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [sound] = '%@'",w.sound];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                NSDictionary* dict = results.resultDictionary;
                Word* w = [[Word alloc] initWithDictionary:dict];
                if (w != nil) {
                    [result addObject:w];
                }
            }
        }
        [results close];
    }];
    [db close];
    
    return result;
}

#pragma mark - Score

- (void)insertScore:(Score*)score {
    FMDatabaseQueue* db = [self _scoreDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        NSString* query = [NSString stringWithFormat:@"INSERT INTO [score] ([phoneme],[sound],[date], [score], [date_string], [record_file]) VALUES ('%@','%@',%f,%.2f,'%@','%@')",score.phoneme, score.sound, [score.date timeIntervalSince1970], score.score, score.dateString, score.recordPath];
        [db executeUpdate:query];
    }];
    [db close];
}

- (void)insertRandomScore {
    for (int i = 0; i < 100; i++) {
        FMDatabaseQueue* db = [self _scoreDBQueue];
        [db inDatabase:^(FMDatabase *db) {
            Score *randomScore = [[Score alloc] initRandomScore];
            NSString* query = [NSString stringWithFormat:@"INSERT INTO [score] ([phoneme],[sound],[date], [score]) VALUES ('%@','%@',%f,%.2f)",randomScore.phoneme, randomScore.sound, [randomScore.date timeIntervalSince1970], randomScore.score];
            [db executeUpdate:query];
        }];
        [db close];
    }
}

- (NSMutableArray*)getScoresBySound:(NSString*)sound {
    // Select all sounds from randomized word
    __block NSMutableArray* result = [NSMutableArray new];
    FMDatabaseQueue* db = [self _scoreDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [score] WHERE [sound] = '%@'",sound];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                NSDictionary* dict = results.resultDictionary;
                Score* w = [[Score alloc] initWithDictionary:dict];
                if (w != nil) {
                    [result addObject:w];
                }
                
            }
        }
        [results close];
    }];
    [db close];
    
    return result;
}

- (NSMutableArray*)getScoresByDateString:(NSString*)dateStr {
    // Select all sounds from randomized word
    __block NSMutableArray* result = [NSMutableArray new];
    FMDatabaseQueue* db = [self _scoreDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [score] WHERE [date_string] = '%@'",dateStr];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                NSDictionary* dict = results.resultDictionary;
                Score* w = [[Score alloc] initWithDictionary:dict];
                if (w != nil) {
                    [result addObject:w];
                }
                
            }
        }
        [results close];
    }];
    [db close];
    
    return result;
}

- (NSMutableArray *)getScoresFrom:(NSDate *)from to:(NSDate*)to {
    // Select all sounds from randomized word
    __block NSMutableArray* result = [NSMutableArray new];
    FMDatabaseQueue* db = [self _scoreDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        float t = [to timeIntervalSince1970];
        float f = [from timeIntervalSince1970];
        if (to == nil) {
            t = FLT_MAX;
        }
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [score] WHERE [date] >= %f AND [date] <= %f ORDER BY [date]",f,t];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                NSDictionary* dict = results.resultDictionary;
                Score* w = [[Score alloc] initWithDictionary:dict];
                if (w != nil) {
                    [result addObject:w];
                }
                
            }
        }
        [results close];
    }];
    [db close];
    
    return result;
}


@end
