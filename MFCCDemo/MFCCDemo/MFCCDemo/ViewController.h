//
//  ViewController.h
//  MFCCDemo
//
//  Created by Hai Le on 9/23/15.
//  Copyright (c) 2015 Hai Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

@interface ViewController : UIViewController

// Audio Controller
@property (nonatomic, strong) AEAudioController* audioController;

// Others UI Elements
@property (nonatomic, strong) IBOutlet UIView* headerView;
@property (nonatomic, strong) IBOutlet UIView* footerView;
@property (nonatomic, weak) IBOutlet UIView *recordingState;
@property (nonatomic, weak) IBOutlet UILabel *lbRecordingState;

/**
 A flag indicating whether we are recording or not
 */
@property (nonatomic, assign) BOOL isRecording;

@end

