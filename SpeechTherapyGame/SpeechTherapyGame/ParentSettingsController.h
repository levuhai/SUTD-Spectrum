//
//  ParentSettingsController.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/6/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentSettingsController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider* sliderDifficulty;
@property (nonatomic, weak) IBOutlet UILabel* sliderValue;
@property (nonatomic, weak) IBOutlet UIButton* btnSFXPlus;
@property (nonatomic, weak) IBOutlet UIButton* btnSFXMinus;
@property (nonatomic, weak) IBOutlet UIButton* btnBGMPlus;
@property (nonatomic, weak) IBOutlet UIButton* btnBGMMinus;

@end
