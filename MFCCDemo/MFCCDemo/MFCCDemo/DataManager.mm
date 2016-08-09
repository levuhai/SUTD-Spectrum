//
//  DataManager.m
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "DataManager.h"
#import <FMDB/FMDB.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "SUTDMFCCHelperFunctions.hpp"
#import "Word.h"
#import "PassFilter.h"
#import "BMTNFilter.h"
#import "BMMultiLevelBiquad.h"

#define DITHER_16_MAX_ERROR 3.0/323768.0f
#define DELTA 4*DITHER_16_MAX_ERROR

@implementation DataManager {
    NSString* _soundsDBPath;
    NSString* _soundFolder;
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
        
        [fm copyItemAtPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/sounds"] toPath:_soundFolder error:nil];
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
                //NSLog(@"%@",file);
                
                // Read full file
                // Read full file
                NSString* temp = [NSString stringWithFormat:@"%@/%@",subFolder,file];
                NSString *fullPath = [_soundFolder stringByAppendingPathComponent:temp];
                
                // Read cropped file
                NSString *croppedPath = [fullPath stringByReplacingOccurrencesOfString:@"_full" withString:@""];
                // Buffer reader
                float *mBuffer;
                UInt64 sLen, mLen;
                float *sBuffer;
                
                // Read full file
                AEAudioFileLoaderOperation *fullFileOperation;
                fullFileOperation = [[AEAudioFileLoaderOperation alloc]
                                     initWithFileURL:[PassFilter urlForPath:fullPath]
                                     targetAudioDescription:[PassFilter monoFloatFormatWithSampleRate:44100.0f]];
                [fullFileOperation start];
                if ( fullFileOperation.error ) {
                    // Load failed! Clean up, report error, etc.
                    return;
                }
                
                mBuffer = (float*)fullFileOperation.bufferList->mBuffers[0].mData;
                mLen = fullFileOperation.lengthInFrames;
                
                // Read cropped file
                AEAudioFileLoaderOperation *croppedFileOperation;
                croppedFileOperation = [[AEAudioFileLoaderOperation alloc]
                                     initWithFileURL:[PassFilter urlForPath:croppedPath]
                                     targetAudioDescription:[PassFilter monoFloatFormatWithSampleRate:44100.0f]];
                [croppedFileOperation start];
                if ( croppedFileOperation.error ) {
                    // Load failed! Clean up, report error, etc.
                    return;
                }
                
                sBuffer = (float*)croppedFileOperation.bufferList->mBuffers[0].mData;
                sLen = croppedFileOperation.lengthInFrames;
                
                // Writer
                NSString* filterP = [fullPath stringByReplacingOccurrencesOfString:@"_full" withString:@"_filtered"];
                const char *cha = [filterP cStringUsingEncoding:NSUTF8StringEncoding];
                filterSound(mBuffer, mLen, cha);
                //writeToAudioFile(cha, 1, false, mLen, mBuffer);

                
                for (int i = 0; i < mLen-3-1; i+=1) {
                    if (approxEqual(mBuffer[i+0],sBuffer[0], DELTA)
                        && approxEqual(mBuffer[i+1],sBuffer[1], DELTA)
                        && approxEqual(mBuffer[i+2],sBuffer[2], DELTA)
                        && approxEqual(mBuffer[i+4],sBuffer[4], DELTA)) {
                        //printf("\n");
                        //printf("%f %f %f ::::: %f %f %f",mBuffer[i+0],mBuffer[i+1],mBuffer[i+2],sBuffer[0],sBuffer[1],sBuffer[2]);
                        //printf("\n");
                        //NSLog(@"equal");
                        BOOL equal = YES;
                        int j = 0;
                        while (equal) {
                            if (approxEqual(mBuffer[i+j],sBuffer[j], DELTA) && j < sLen) {
                                j++;
                            } else {
                                if (j < sLen*0.6) {
                                    //i = j;
                                    equal = NO;
                                }
                                break;
                            }
                        }
                        if (equal) {
                            
                            
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
                            NSString* phonetic = cols[1];
                            
                            // Phonetic
                            NSString* sound;
                            if (cols.count == 5) sound = cols[2]; else sound = cols[1];
                            
                            // Position
                            int pos = 0;
                            NSString* position = cols[0];
                            if ([position isEqual: @"i"]) pos = 0;
                            else if ([position isEqual: @"m"]) pos = 1;
                            else if ([position isEqual: @"e"]) pos = 2;
                            
                            // Full Path
                            NSString* f = [NSString stringWithFormat:@"%@/%@",phoneme,file];
                            
                            // Cropped Path
                            NSString* c = [f stringByReplacingOccurrencesOfString:@"_full" withString:@""];
                            
                            // Img Path
                            NSString* imgPath = @"";
                            if (cols.count == 5) {
                                imgPath = [NSString stringWithFormat:@"%@/%@_%@.png",phoneme,position,sound];
                            }
                            
                            // Sample Path
                            NSString* samplePath = [NSString stringWithFormat:@"%@/%@_%@.wav",phoneme,position,sound];
                            
                            NSString *query = [NSString stringWithFormat:@"INSERT INTO [db] ([phoneme],[sound],[phonetic],[position],[full_path],[full_len],[cropped_path],[cropped_len],[cropped_start],[cropped_end],[type],[img_path],[sample_path]) VALUES ('%@','%@','%@',%d,'%@',%llu,'%@',%llu,%d,%d,%d,'%@','%@')",phoneme,sound,phonetic,pos,f,mLen,c,sLen,start,end,type,imgPath,samplePath];
                            [queries addObject:query];
                            break;
                        }
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

inline BOOL approxEqual(float x, float y, float delta) {
    return fabsf(x-y)<= delta;
}

#pragma mark - Private
- (FMDatabaseQueue*)_soundDBQueue {
    return [FMDatabaseQueue databaseQueueWithPath:_soundsDBPath];
}

#pragma mark - Word

- (NSMutableArray*)getWords {
    __block NSMutableArray* lvs = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db]"];
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

- (NSMutableArray*)getWordGroup:(NSString*)sound {
    //    // Select unique words from DB
    //    __block NSMutableArray* uniqueWords = [self getWords];
    //
    FMDatabaseQueue* db = [self _soundDBQueue];
    //
    //    assert(uniqueWords.count > 0);
    //
    //    // Random index
    //    int rndValue = 0 + arc4random() % (uniqueWords.count - 0);
    
    // Select all sounds from randomized word
    __block NSMutableArray* result = [NSMutableArray new];
    db = [self _soundDBQueue];
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [sound] = '%@'",sound];
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

- (NSMutableArray*)getUniqueWords {
    __block NSMutableArray* lvs = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] GROUP BY [sound] ORDER BY [phoneme]"];
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

- (NSMutableArray*)getRandomWords {
    // Select unique words from DB
    __block NSMutableArray* uniqueWords = [NSMutableArray new];
    FMDatabaseQueue* db = [self _soundDBQueue];
    
    [db inDatabase:^(FMDatabase *db) {
        NSString * sql = [NSString stringWithFormat:@"SELECT DISTINCT phonetic FROM [db]"];
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
        NSString * sql = [NSString stringWithFormat:@"SELECT * FROM [db] WHERE [phonetic] = '%@'",uniqueWords[rndValue]];
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


@end
