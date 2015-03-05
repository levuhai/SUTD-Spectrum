//
//  BandPassViewController.m
//  audioRecorder
//
//  Created by Hai Le on 27/2/14.
//  Copyright (c) 2014 Hai Le. All rights reserved.
//

#import "BandPassViewController.h"
#import "AudioController.h"
#import "ACScrollView.h"
#import "ACTextField.h"
#import "UIColor+Expanded.h"
#import "UIImage+Expanded.h"
#import <SWRevealViewController/SWRevealViewController.h>

@interface BandPassViewController () <UITextFieldDelegate,SWRevealViewControllerDelegate>  {
    AudioController *_audioController;
    NSTimer *_drawTimer;
    float* _data;
}
@end

@implementation BandPassViewController

- (void)viewWillAppear:(BOOL)animated {
    // Side Menu
    self.revealViewController.delegate = self;
    self.revealViewController.toggleAnimationDuration = 0.3;
    self.revealViewController.draggableBorderWidth = 150;
    self.revealViewController.frontViewShadowOffset = CGSizeMake(0, 0);
    self.revealViewController.bounceBackOnOverdraw = NO;
    self.revealViewController.frontViewShadowRadius = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _audioController = [AudioController sharedInstance];
    
    // Wave view
    waveView.plotType        = EZPlotTypeRolling;
    waveView.shouldFill      = YES;
    waveView.gain            = _audioController.bandPassGain;
    waveView.color           = _audioController.bandPassGraphColor;
    waveView.backgroundColor = [UIColor colorWithWhite:.3 alpha:1];
    waveView.gain            = _audioController.bandPassGain;
    
    // Display color view
    [colorView setBackgroundColor:_audioController.bandPassGraphColor];
    
    // Set value for sliders
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [colorView.backgroundColor getRed:&red
                                green:&green
                                 blue:&blue
                                alpha:&alpha];
    RSlider.value = red;
    BSlider.value = blue;
    GSlider.value = green;
    
    // Textfield
    [cutOffTextField setDelegate:self];
    [cutOffTextField setPlaceholderColor:[UIColor colorWithHexString:@"#16A085"]];
    [cutOffTextField setFloatingLabelActiveTextColor:[UIColor colorWithHexString:@"#1ABC9C"]];
    [cutOffTextField setType:ACTextFieldType];
    
    [noiseFloorTextField setDelegate:self];
    [noiseFloorTextField setPlaceholderColor:[UIColor colorWithHexString:@"#16A085"]];
    [noiseFloorTextField setFloatingLabelActiveTextColor:[UIColor colorWithHexString:@"#1ABC9C"]];
    [noiseFloorTextField setType:ACTextFieldType];
    
    [bandwidthTextField setDelegate:self];
    [bandwidthTextField setPlaceholderColor:[UIColor colorWithHexString:@"#16A085"]];
    [bandwidthTextField setFloatingLabelActiveTextColor:[UIColor colorWithHexString:@"#1ABC9C"]];
    [bandwidthTextField setType:ACTextFieldType];
    
    [filterOrderTextField setDelegate:self];
    [filterOrderTextField setPlaceholderColor:[UIColor colorWithHexString:@"#16A085"]];
    [filterOrderTextField setFloatingLabelActiveTextColor:[UIColor colorWithHexString:@"#1ABC9C"]];
    [filterOrderTextField setType:ACPickerFieldType];
    [filterOrderTextField setPickerData:[NSArray arrayWithObjects:
                                         @"2nd Order",
                                         @"3rd Order",
                                         @"4th Order",
                                         @"5th Order",
                                         @"6th Order",
                                         @"7th Order",
                                         @"8th Order",
                                         @"9th Order",
                                         @"10th Order",nil]];
    [filterOrderTextField setPickerIndex:_audioController.bandPassFilterOrder-2];
    
    [waveTypeTextField setDelegate:self];
    [waveTypeTextField setPlaceholderColor:[UIColor colorWithHexString:@"#16A085"]];
    [waveTypeTextField setFloatingLabelActiveTextColor:[UIColor colorWithHexString:@"#1ABC9C"]];
    [waveTypeTextField setType:ACPickerFieldType];
    [waveTypeTextField setPickerData:[NSArray arrayWithObjects:@"Buffer",@"Rolling",nil]];
    [waveTypeTextField setPickerIndex:1];
    
    // Set value text field
    cutOffTextField.text = [NSString stringWithFormat:@"%.0f",_audioController.bandPassCutOff];
    bandwidthTextField.text = [NSString stringWithFormat:@"%.0f",_audioController.bandPassBandWidth];
    noiseFloorTextField.text = [NSString stringWithFormat:@"%.0f",_audioController.bandPassGain];
    
    // Change thumb size
    UIImage *thumbImage = [UIImage whiteCircle];
    [RSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [BSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [GSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    // Side Menu
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    // Menu Button
    [self.menuButton.titleLabel setFont:[UIFont ioniconsOfSize:30]];
    [self.menuButton setTitle:@"\uf20e" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [self.menuButton setBackgroundColor:[UIColor turquoiseColor]];
    
    self.view.backgroundColor = [UIColor wetAsphaltColor];
    self.menuView.backgroundColor = [UIColor midnightBlueColor];
    [self _startDrawing];

}

- (void)viewWillDisappear:(BOOL)animated {
    _audioController.delegate = nil;
}

#pragma Actions

- (IBAction)RBGChanged:(id)sender {
    UIColor *color = [UIColor colorWithRed:RSlider.value
                                     green:GSlider.value
                                      blue:BSlider.value
                                     alpha:1];
    [self changeColor:color];
}

- (IBAction)menuTouched:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    
    // Present the view controller
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self _stopDrawing];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self _startDrawing];

    ACTextField* foo = (ACTextField*)textField;
    float value;
    if (textField.text.length == 0) {
        value = 50;
        textField.text = [NSString stringWithFormat:@"%.0f",value];
    } else {
        value = [textField.text floatValue];
    }
    
    if (textField == cutOffTextField) {
        _audioController.bandPassCutOff = value;
        [_audioController resetBandPassFilter];
    } else if (textField == noiseFloorTextField) {
        _audioController.bandPassGain = value;
        waveView.gain = value;
    } else if (textField == bandwidthTextField) {
        _audioController.bandPassBandWidth = value;
        [_audioController resetBandPassFilter];
    }
    else if (textField == filterOrderTextField) {
        _audioController.bandPassFilterOrder = foo.pickerIndex + 2;
        [_audioController resetBandPassFilter];
    }
    else if (textField == waveTypeTextField) {
        waveView.shouldFill = foo.pickerIndex;
        waveView.plotType = foo.pickerIndex;
    }
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - AudioControllerDelegate

- (void)bandPassDidFinish:(float *)data withBufferSize:(UInt32)bufferSize{
    [waveView updateBuffer:data withBufferSize:bufferSize];
}

#pragma mark - Private Category

- (void)changeColor:(UIColor*)color {
    [colorView setBackgroundColor:color];
    _audioController.bandPassGraphColor = color;
    waveView.color = color;
}

- (void)_startDrawing {
    [_audioController start];
    
    if (!_drawTimer) {
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval: 1/50.0f
                                                      target: self
                                                    selector: @selector(_drawGraph)
                                                    userInfo: nil
                                                     repeats: YES];
    }
}

- (void)_stopDrawing {
    [_audioController stop];
    
    [_drawTimer invalidate];
    _drawTimer = nil;
}

- (void)_drawGraph {
    int bufferSize;
    _data = [_audioController getLowPassDataWithBufferSize:&bufferSize];
    [waveView updateBuffer:_data withBufferSize:bufferSize];
}

@end
