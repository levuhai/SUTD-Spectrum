//
//  ViewController.h
//  MFCCDemo
//
//  Created by Hai Le on 9/23/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZAudio.h"

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *recordingState;
@property (nonatomic, weak) IBOutlet UILabel *lbRecordingState;

/**
 The recorder component
 */
@property (nonatomic, strong) EZRecorder *recorder;

/**
 The microphone component
 */
@property (nonatomic, strong) EZMicrophone *microphone;

/**
 A flag indicating whether we are recording or not
 */
@property (nonatomic, assign) BOOL isRecording;

@end

