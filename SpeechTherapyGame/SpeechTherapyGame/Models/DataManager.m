//
//  DataManager.m
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "DataManager.h"
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import <FMDB/FMDB.h>
#import "Word.h"
#import "Score.h"

@implementation DataManager {
    NSString* _soundsDBPath;
    NSString* _statsDBPath;
    NSArray* _sliderValues;
    
    NSString* _soundFolder;
}

static DataManager *sharedInstance = nil;

AudioStreamBasicDescription const ASBD = {
    .mFormatID          = kAudioFormatLinearPCM,
    .mFormatFlags       = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved,
    .mChannelsPerFrame  = 1,
    .mBytesPerPacket    = sizeof(float),
    .mFramesPerPacket   = 1,
    .mBytesPerFrame     = sizeof(float),
    .mBitsPerChannel    = 8 * sizeof(float),
    .mSampleRate        = 44100.0,
};

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
        _sliderValues = @[@0.3, @0.4, @0.5];
        
        _statsDBPath = [self copyToDocuments:@"score.sqlite"];
        NSLog(@"Stats DB Path: %@",_statsDBPath);

        //[self insertRandomScore];
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *recordingFolder = [doc stringByAppendingString:@"/recordings"];
        [[NSFileManager defaultManager] createDirectoryAtPath:recordingFolder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        
        // sounds folder
        _soundsDBPath = [doc stringByAppendingString:@"/sound.sqlite"];
        _soundFolder = [doc stringByAppendingString:@"/sounds"];
        
        [fm removeItemAtPath:_soundsDBPath error:nil];
        NSString* boneDBPath = [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"sqlite"];
        [fm copyItemAtPath:boneDBPath toPath:_soundsDBPath error:nil];
        [self _generateDB];
    }
    return self;
}

- (void)_generateDB {
    NSFileManager* fm = [NSFileManager defaultManager];
    // Read files in Sounds folder
    NSArray *sourceFolder =  [fm contentsOfDirectoryAtPath:_soundFolder error:nil];
    NSMutableArray* queries = [NSMutableArray new];
    
    for (NSString *subFolder in sourceFolder) {
        if (![subFolder isEqualToString:@".DS_Store"]) {
            NSString* subFolderPath = [_soundFolder stringByAppendingPathComponent:subFolder];
            NSArray *subFolderContents = [fm contentsOfDirectoryAtPath:subFolderPath error:nil];
            NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self ENDSWITH '_full.wav'"];
            NSArray *onlyWAVs = [subFolderContents filteredArrayUsingPredicate:fltr];
            
            // Add files to db
            for (NSString* file in onlyWAVs) {
                NSLog(@"%@",file);
                
                // Read full file
                NSString* temp = [NSString stringWithFormat:@"%@/%@",subFolder,file];
                NSString *fullPath = [_soundFolder stringByAppendingPathComponent:temp];
                AEAudioFileLoaderOperation* full
                = [self _readFilePath:fullPath
                            audioDesc:ASBD];
                
                // Read cropped file
                NSString *croppedPath = [fullPath stringByReplacingOccurrencesOfString:@"_full" withString:@""];
                AEAudioFileLoaderOperation* cropped
                = [self _readFilePath:croppedPath
                            audioDesc:ASBD];
                
                // If one of these 2 files is nil skip
                if (cropped == nil || full == nil) {
                    continue;
                }
                
                // Buffer reader
                float *mBuffer = (float*)full.bufferList->mBuffers[0].mData;
                float *sBuffer = (float*)cropped.bufferList->mBuffers[0].mData;
                for (int i = 0; i < full.lengthInFrames-3-1; i++) {
                    if (mBuffer[i+0] == sBuffer[0]
                        && mBuffer[i+1] == sBuffer[1]
                        && mBuffer[i+2] == sBuffer[2]) {
                        
                        BOOL equal = YES;
                        int j = 0;
                        while (equal) {
                            if (mBuffer[i+j]==sBuffer[j] && i+j <= full.lengthInFrames) {
                                j++;
                            } else {
                                break;
                            }
                        }
                        
                        // components of file name
                        NSArray* cols = [file componentsSeparatedByString:@"_"];
                        
                        // Info
                        
                        // Phoneme
                        NSString* phoneme = subFolder;
                        
                        // Type
                        int type; // 0: Word, 1: Syllable
                        if (cols.count == 5) type = 0; else type = 1;
                        
                        // Start, End
                        int start = i, end = i+j;
                        
                        // Sound
                        NSString* sound = cols[1];
                        
                        // Phonetic
                        NSString* phonetic;
                        if (cols.count == 5) phonetic = cols[2]; else phonetic = cols[1];
                        
                        // Position
                        int pos = 0;
                        NSString* position = cols[0];
                        if ([position isEqual: @"i"]) pos = 0;
                        if ([position isEqual: @"m"]) pos = 1;
                        if ([position isEqual: @"e"]) pos = 2;
                        
                        // Full Path
                        NSString* fullPath = [NSString stringWithFormat:@"%@/%@",phoneme,file];
                        
                        // Cropped Path
                        NSString* croppedPath = [fullPath stringByReplacingOccurrencesOfString:@"_full" withString:@""];
                        
                        // Img Path
                        NSString* imgPath = @"";
                        if (cols.count == 5) {
                            imgPath = [NSString stringWithFormat:@"%@/%@_%@.png",phoneme,position,sound];
                        }
                        
                        // Sample Path
                        NSString* samplePath = [NSString stringWithFormat:@"%@/%@_%@.wav",phoneme,position,sound];
                        
                        NSString *query = [NSString stringWithFormat:@"INSERT INTO [db] ([phoneme],[sound],[phonetic],[position],[full_path],[full_len],[cropped_path],[cropped_len],[cropped_start],[cropped_end],[type],[img_path],[sample_path]) VALUES ('%@','%@','%@',%d,'%@',%d,'%@',%d,%d,%d,%d,'%@','%@')",phoneme,sound,phonetic,pos,fullPath,full.lengthInFrames,croppedPath,cropped.lengthInFrames,start,end,type,imgPath,samplePath];
                        [queries addObject:query];
                        //}
                        break;
                    }
                }
            }
        }
    }
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:_soundsDBPath];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString* q in queries) {
            [db executeUpdate:q];
        }
    }];
}

- (AEAudioFileLoaderOperation*)_readFilePath:(NSString*)filePath
                                   audioDesc:(AudioStreamBasicDescription)ad {
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [filePath stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *url = [NSURL URLWithString:result];
    AEAudioFileLoaderOperation *operation = [[AEAudioFileLoaderOperation alloc] initWithFileURL:url
                                                                         targetAudioDescription:ad];
    [operation start];
    if ( operation.error ) {
        // Load failed! Clean up, report error, etc.
        return nil;
    }
    return operation;
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
