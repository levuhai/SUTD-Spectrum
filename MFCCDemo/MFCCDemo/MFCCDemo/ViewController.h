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
@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIView* footerView;
@property (nonatomic, strong) IBOutlet UIButton* playrecord;
@property (nonatomic, weak) IBOutlet UILabel *lbScore;
@property (nonatomic, weak) IBOutlet UILabel *lbWord;
@property (nonatomic, weak) IBOutlet UILabel *lbRecord;

/**
 A flag indicating whether we are recording or not
 */
@property (nonatomic, assign) BOOL isRecording;

@end

