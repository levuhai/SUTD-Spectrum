//
//  PassFilter.m
//  MFCCDemo
//
//  Created by Hai Le on 4/25/16.
//  Copyright © 2016 Hai Le. All rights reserved.
//

#import "PassFilter.h"
#import <EZAudio/EZAudio.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "BMTNFilter.h"
#import "BMMultiLevelBiquad.h"

@implementation PassFilter

+ (NSURL*)urlForPath:(NSString*)path {
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *result = [path stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *url = [NSURL URLWithString:result];
    return url;
}

- (void)filter:(float*)data length:(size_t)len path:(NSString*)fullPath {
    // =========================================
    // High pass
    float* hiPass = new float[len];
    // create the filter struct
    BMMultiLevelBiquad hpf;
    
    // initialise the filter
    BMMultiLevelBiquad_init(&hpf,1, 44100, false, false);
    
    //To set it for 6db highpass at fc=2000Hz, do:
    BMMultiLevelBiquad_setHighPass12db(&hpf, 2000, 44100, 0);
    
    //To process a buffer of audio, do:
    BMMultiLevelBiquad_processBufferMono(&hpf, data, hiPass, len);
    
    // When you are done, free the memory used by the filter:
    BMMultiLevelBiquad_destroy(&hpf);
    
//                // Filter
//                float* toneOut = new float[mLen], *noiseOut = new float[mLen];
//                BMTNFilter filter;
//                BMTNFilter_processBuffer(&filter, hiPass, toneOut, noiseOut, mLen);
//                BMTNFilter_destroy(&filter);
    
    // Writer
    NSString* filterP = [fullPath stringByReplacingOccurrencesOfString:@"_full" withString:@"_filtered"];
    const char *cha = [filterP cStringUsingEncoding:NSUTF8StringEncoding];
    writeToAudioFile(cha, 1, false, len, hiPass);
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

@end
