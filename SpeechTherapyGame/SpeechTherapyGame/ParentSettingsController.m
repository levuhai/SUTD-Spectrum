//
//  ParentSettingsController.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/6/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "ParentSettingsController.h"
#import "NSUserDefaults+Convenience.h"
#import "AudioPlayer.h"
#import "DataManager.h"

@interface ParentSettingsController () {
    
}

@end

@implementation ParentSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImage *sliderTrackImage = [[UIImage imageNamed:@"sliderBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 17)];
    
    [self.sliderDifficulty setMinimumTrackImage: sliderTrackImage
                                       forState: UIControlStateNormal];
    [self.sliderDifficulty setMaximumTrackImage: sliderTrackImage
                                       forState: UIControlStateNormal];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"sliderButton"]
                                forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"sliderButton"]
                                forState:UIControlStateHighlighted];
    [self.sliderDifficulty setMinimumValue:kMinSliderValue];
    [self.sliderDifficulty setMaximumValue:kMaxSliderValue];
    [self.sliderDifficulty setValue:[[DataManager shared] difficultyValue]];
    self.sliderValue.text = [NSString stringWithFormat:@"%.3f",self.sliderDifficulty.value];
    
    // Volume control
    float musicVol = [[AudioPlayer shared] musicVolume];
    float soundVol = [[AudioPlayer shared] soundVolume];
    [self _updateSoundVolDisplay:soundVol];
    [self _updateMusicVolDisplay:musicVol];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChanged:(UISlider *)sender {
    // round the slider position to the nearest index of the numbers array
    float index = self.sliderDifficulty.value;
    //[self.sliderDifficulty setValue:index animated:NO];
    [[DataManager shared] setDifficultyValue:index];
    self.sliderValue.text = [NSString stringWithFormat:@"%.3f",index];
}

- (IBAction)btnPressed:(UIButton*)btn {
    float musicVol = [[AudioPlayer shared] musicVolume];
    float soundVol = [[AudioPlayer shared] soundVolume];
    
    if (btn == self.btnBGMMinus) {
        musicVol -= 0.2f;
        musicVol = MIN(1, musicVol);
        musicVol = MAX(0, musicVol);
        [[AudioPlayer shared] setMusicVolume:musicVol];
        [self _updateMusicVolDisplay:musicVol];
    }
    else if (btn == self.btnBGMPlus) {
        musicVol += 0.2f;
        musicVol = MIN(1, musicVol);
        musicVol = MAX(0, musicVol);
       [[AudioPlayer shared] setMusicVolume:musicVol];
        [self _updateMusicVolDisplay:musicVol];
    }
    else if (btn == self.btnSFXMinus) {
        soundVol -= 0.2f;
        soundVol = MIN(1, soundVol);
        soundVol = MAX(0, soundVol);
        [[AudioPlayer shared] setSoundVolume:soundVol];
        [self _updateSoundVolDisplay:soundVol];
    }
    else if (btn == self.btnSFXPlus) {
        soundVol += 0.2f;
        soundVol = MIN(1, soundVol);
        soundVol = MAX(0, soundVol);
        [[AudioPlayer shared] setSoundVolume:soundVol];
        [self _updateSoundVolDisplay:soundVol];
    }
    
}

- (void)_updateMusicVolDisplay:(float)_currentBgmVol {
    int b = _currentBgmVol/0.2f;
    for (int i = 0; i<=4; i++) {
        UIImageView* v = (UIImageView*)[self.view viewWithTag:(int)i+20];
        if (i >= b) {
            [v setImage:[UIImage imageNamed:@"btnProgress0"]];
        } else {
            [v setImage:[UIImage imageNamed:@"btnProgress1"]];
        }
    }
}

- (void)_updateSoundVolDisplay:(float)_currentSoundVol {
    int a = _currentSoundVol/0.2f;
    for (int i = 0; i<=4; i++) {
        UIImageView* v = (UIImageView*)[self.view viewWithTag:(int)i+10];
        if (i >= a) {
            [v setImage:[UIImage imageNamed:@"btnProgress0"]];
        } else {
            [v setImage:[UIImage imageNamed:@"btnProgress1"]];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
