//
//  ParentSettingsController.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/6/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "ParentSettingsController.h"
#import "NSUserDefaults+Convenience.h"

@interface ParentSettingsController () {
    float _currentSoundVol;
    float _currentBgmVol;
}

@end

@implementation ParentSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *sliderTrackImage = [[UIImage imageNamed:@"sliderBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 17)];
    
    [self.sliderDifficulty setMinimumTrackImage: sliderTrackImage forState: UIControlStateNormal];
    [self.sliderDifficulty setMaximumTrackImage: sliderTrackImage forState: UIControlStateNormal];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"sliderButton"] forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"sliderButton"] forState:UIControlStateHighlighted];
    
    if (![NSStandardUserDefaults hasValueForKey:kKeyBGMVol]) {
        _currentBgmVol = 0.6;
        [NSStandardUserDefaults setFloat:_currentBgmVol forKey:kKeyBGMVol];
    } else {
        _currentBgmVol = [NSStandardUserDefaults floatForKey:kKeyBGMVol];
    }
    
    if (![NSStandardUserDefaults hasValueForKey:kKeySoundVol]) {
        _currentSoundVol = 0.6;
        [NSStandardUserDefaults setFloat:_currentSoundVol forKey:kKeySoundVol];
    } else {
        _currentSoundVol = [NSStandardUserDefaults floatForKey:kKeySoundVol];
    }
    [self _updateSFXVolDisplay];
    [self _updateBGMVolDisplay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPressed:(UIButton*)btn {
    if (btn == self.btnBGMMinus) {
        _currentBgmVol -= 0.2f;
        _currentBgmVol = MIN(1, _currentBgmVol);
        _currentBgmVol = MAX(0, _currentBgmVol);
        [NSStandardUserDefaults setFloat:_currentBgmVol forKey:kKeyBGMVol];
        [self _updateBGMVolDisplay];
    }
    else if (btn == self.btnBGMPlus) {
        _currentBgmVol += 0.2f;
        _currentBgmVol = MIN(1, _currentBgmVol);
        _currentBgmVol = MAX(0, _currentBgmVol);
        [NSStandardUserDefaults setFloat:_currentBgmVol forKey:kKeyBGMVol];
        [self _updateBGMVolDisplay];
    }
    else if (btn == self.btnSFXMinus) {
        _currentSoundVol -= 0.2f;
        _currentSoundVol = MIN(1, _currentSoundVol);
        _currentSoundVol = MAX(0, _currentSoundVol);
        [NSStandardUserDefaults setFloat:_currentSoundVol forKey:kKeySoundVol];
        [self _updateSFXVolDisplay];
    }
    else if (btn == self.btnSFXPlus) {
        _currentSoundVol += 0.2f;
        _currentSoundVol = MIN(1, _currentSoundVol);
        _currentSoundVol = MAX(0, _currentSoundVol);
        [NSStandardUserDefaults setFloat:_currentSoundVol forKey:kKeySoundVol];
        [self _updateSFXVolDisplay];
    }
    
}

- (void)_updateBGMVolDisplay {
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

- (void)_updateSFXVolDisplay {
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

@end
