//
//  DataManager.m
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "DataManager.h"
#import <FMDB/FMDB.h>
#import <EZAudio/EZAudio.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "BMTNFilter.h"
#import "BMMultiLevelBiquad.h"
#import "Word.h"
#import "PassFilter.h"

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
                //                AEAudioFileLoaderOperation* full
                //                = [self _readFilePath:fullPath
                //                            audioDesc:ASBD];
                
                // Read cropped file
                NSString *croppedPath = [fullPath stringByReplacingOccurrencesOfString:@"_full" withString:@""];
                //                AEAudioFileLoaderOperation* cropped
                //                = [self _readFilePath:croppedPath
                //                            audioDesc:ASBD];
                //                if (!cropped || !full) {
                //                    continue;
                //                }
                // Buffer reader
                
                EZAudioFile* f = [[EZAudioFile alloc] initWithURL:[self _urlForPath:fullPath]];
                EZAudioFloatData *data1 = [f getWaveformDataWithNumberOfPoints:(int)f.totalClientFrames];
                EZAudioFile* c = [[EZAudioFile alloc] initWithURL:[self _urlForPath:croppedPath]];
                EZAudioFloatData *data2 = [c getWaveformDataWithNumberOfPoints:(int)c.totalClientFrames];
                
                float *mBuffer;
                UInt64 sLen, mLen;
                float *sBuffer;
                
                
                mBuffer = [data1 bufferForChannel:0];
                sLen = c.totalClientFrames;
                mLen = f.totalClientFrames;
                sBuffer = [data2 bufferForChannel:0];
                
                // Filter
                float* toneOut = new float[mLen], *noiseOut = new float[mLen];
                BMTNFilter filter;
                BMTNFilter_processBuffer(&filter, mBuffer, toneOut, noiseOut, mLen);
                BMTNFilter_destroy(&filter);
                
                // Writer
                NSString* filterP = [fullPath stringByReplacingOccurrencesOfString:@"_full" withString:@"_filtered"];
                const char *cha = [filterP cStringUsingEncoding:NSUTF8StringEncoding];
                writeToAudioFile(cha, 1, false, mLen, noiseOut);
                //[PassFilter filter:mBuffer length:mLen path:fullPath];
                
                for (int i = 0; i < mLen-3-1; i+=1) {
                    if (approxEqual(mBuffer[i+0],sBuffer[0], DELTA)
                        && approxEqual(mBuffer[i+1],sBuffer[1], DELTA)
                        && approxEqual(mBuffer[i+2],sBuffer[2], DELTA)
                        && approxEqual(mBuffer[i+4],sBuffer[4], DELTA)) {
                        printf("\n");
                        printf("%f %f %f ::::: %f %f %f",mBuffer[i+0],mBuffer[i+1],mBuffer[i+2],sBuffer[0],sBuffer[1],sBuffer[2]);
                        printf("\n");
                        NSLog(@"equal");
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

void writeToAudioFile(const char *fName,int mChannels,bool compress_with_m4a, UInt64 frames, float* data)
{
    OSStatus err; // to record errors from ExtAudioFile API functions
    
    // create file path as CStringRef
    CFStringRef fPath;
    fPath = CFStringCreateWithCString(kCFAllocatorDefault,
                                      fName,
                                      kCFStringEncodingMacRoman);
    
    
    // specify total number of samples per channel
    UInt32 totalFramesInFile = frames;
    
    /////////////////////////////////////////////////////////////////////////////
    ////////////// Set up Audio Buffer List For Interleaved Audio ///////////////
    /////////////////////////////////////////////////////////////////////////////
    
    AudioBufferList outputData;
    outputData.mNumberBuffers = 1;
    outputData.mBuffers[0].mNumberChannels = mChannels;
    outputData.mBuffers[0].mDataByteSize = sizeof(float)*totalFramesInFile*mChannels;
    
    
    
    /////////////////////////////////////////////////////////////////////////////
    //////// Synthesise Noise and Put It In The AudioBufferList /////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    // create an array to hold our audio
    float audioFile[totalFramesInFile*mChannels];
    
    // fill the array with random numbers (white noise)
    for (int i = 0;i < totalFramesInFile*mChannels;i++)
    {
        audioFile[i] = data[i];
        // (yes, I know this noise has a DC offset, bad)
    }
    
    // set the AudioBuffer to point to the array containing the noise
    outputData.mBuffers[0].mData = &audioFile;
    
    
    /////////////////////////////////////////////////////////////////////////////
    ////////////////// Specify The Output Audio File Format /////////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    
    // the client format will describe the output audio file
    AudioStreamBasicDescription clientFormat;
    
    // the file type identifier tells the ExtAudioFile API what kind of file we want created
    AudioFileTypeID fileType;
    
    // if compress_with_m4a is tru then set up for m4a file format
    if (compress_with_m4a)
    {
        // the file type identifier tells the ExtAudioFile API what kind of file we want created
        // this creates a m4a file type
        fileType = kAudioFileM4AType;
        
        // Here we specify the M4A format
        clientFormat.mSampleRate         = 44100.0;
        clientFormat.mFormatID           = kAudioFormatMPEG4AAC;
        clientFormat.mFormatFlags        = kMPEG4Object_AAC_Main;
        clientFormat.mChannelsPerFrame   = mChannels;
        clientFormat.mBytesPerPacket     = 0;
        clientFormat.mBytesPerFrame      = 0;
        clientFormat.mFramesPerPacket    = 1024;
        clientFormat.mBitsPerChannel     = 0;
        clientFormat.mReserved           = 0;
    }
    else // else encode as PCM
    {
        // this creates a wav file type
        fileType = kAudioFileWAVEType;
        
        // This function audiomatically generates the audio format according to certain arguments
        FillOutASBDForLPCM(clientFormat,44100.0,mChannels,32,32,true,false,false);
    }
    
    
    
    /////////////////////////////////////////////////////////////////////////////
    ///////////////// Specify The Format of Our Audio Samples ///////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    // the local format describes the format the samples we will give to the ExtAudioFile API
    AudioStreamBasicDescription localFormat;
    FillOutASBDForLPCM (localFormat,44100.0,mChannels,32,32,true,false,false);
    
    
    
    /////////////////////////////////////////////////////////////////////////////
    ///////////////// Create the Audio File and Open It /////////////////////////
    /////////////////////////////////////////////////////////////////////////////
    
    // create the audio file reference
    ExtAudioFileRef audiofileRef;
    
    // create a fileURL from our path
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,fPath,kCFURLPOSIXPathStyle,false);
    
    // open the file for writing
    err = ExtAudioFileCreateWithURL((CFURLRef)fileURL, fileType, &clientFormat, NULL, kAudioFileFlags_EraseFile, &audiofileRef);
    
    if (err != noErr)
    {
        //cout << "Problem when creating audio file: " << err << "\n";
    }
    
    
    /////////////////////////////////////////////////////////////////////////////
    ///// Tell the ExtAudioFile API what format we'll be sending samples in /////
    /////////////////////////////////////////////////////////////////////////////
    
    // Tell the ExtAudioFile API what format we'll be sending samples in
    err = ExtAudioFileSetProperty(audiofileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(localFormat), &localFormat);
    
    if (err != noErr)
    {
        //cout << "Problem setting audio format: " << err << "\n";
    }
    
    /////////////////////////////////////////////////////////////////////////////
    ///////// Write the Contents of the AudioBufferList to the AudioFile ////////
    /////////////////////////////////////////////////////////////////////////////
    
    UInt32 rFrames = (UInt32)totalFramesInFile;
    // write the data
    err = ExtAudioFileWrite(audiofileRef, rFrames, &outputData);
    
    if (err != noErr)
    {
        //cout << "Problem writing audio file: " << err << "\n";
    }
    
    
    /////////////////////////////////////////////////////////////////////////////
    ////////////// Close the Audio File and Get Rid Of The Reference ////////////
    /////////////////////////////////////////////////////////////////////////////
    
    // close the file
    ExtAudioFileDispose(audiofileRef);
    
    
    NSLog(@"Done!");
}

#pragma mark - Private
- (NSURL*)_urlForPath:(NSString*)path {
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [path stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *url = [NSURL URLWithString:result];
    return url;
}

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
