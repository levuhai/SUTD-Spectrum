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
        _soundsDBPath = [self copyToDocuments:@"sound.sqlite"];
        NSLog(@"Sound DB Path: %@",_soundsDBPath);
        _statsDBPath = [self copyToDocuments:@"score.sqlite"];
        NSLog(@"Stats DB Path: %@",_statsDBPath);

        //[self insertRandomScore];
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

#pragma mark - Private
- (FMDatabaseQueue*)_soundDBQueue {
    return [FMDatabaseQueue databaseQueueWithPath:_soundsDBPath];
}
- (FMDatabaseQueue*)_scoreDBQueue {
    return [FMDatabaseQueue databaseQueueWithPath:_statsDBPath];
}

#pragma mark - Word

- (NSMutableArray*)getWords {
    __block NSMutableArray* lvs = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] GROUP BY [w_text]"];
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

- (NSMutableArray *)getWordLevel {
    __block NSMutableArray* lvs = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [w_phonetic] != [w_text] GROUP BY [w_text]"];
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
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [w_phonetic] = [w_text] GROUP BY [w_text]"];
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
    __block NSMutableArray* uniqueWords = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT DISTINCT w_text FROM [db]"];
        FMResultSet *results = [db executeQuery:sql];
        while([results next]) {
            @autoreleasepool {
                [uniqueWords addObject:[results stringForColumnIndex:0]];
            }
        }
        [results close];
    }];
    [db close];
    
    
    // Random index
    int rndValue = 0 + arc4random() % (uniqueWords.count - 0);
    
    // Select all sounds from randomized word
    __block NSMutableArray* result = [NSMutableArray new];
    db = [self _soundDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [w_text] = '%@'",uniqueWords[rndValue]];
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
