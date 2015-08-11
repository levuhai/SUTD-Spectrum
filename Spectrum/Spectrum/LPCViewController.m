//
//  LPCViewController.m
//  Spectrum
//
//  Created by Hai Le on 29/9/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import "LPCViewController.h"
#import <SWRevealViewController/SWRevealViewController.h>
#import "LPCView.h"
#import "LPCAudioController.h"
#import "UIImage+Expanded.h"

@interface LPCViewController () <SWRevealViewControllerDelegate, LPCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbBufferLengthValue;
@property (weak, nonatomic) IBOutlet UILabel *lbOrderValue;

@end

@implementation LPCViewController {
    NSTimer *_drawTimer;
}

- (void)viewWillAppear:(BOOL)animated {
    // Side Menu
    self.revealViewController.delegate = self;
    self.revealViewController.toggleAnimationDuration = 0.3;
    self.revealViewController.draggableBorderWidth = 150;
    self.revealViewController.frontViewShadowOffset = CGSizeMake(0, 0);
    self.revealViewController.bounceBackOnOverdraw = NO;
    self.revealViewController.frontViewShadowRadius = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Menu Button
    [self.menuButton.titleLabel setFont:[UIFont ioniconsOfSize:30]];
    [self.menuButton setTitle:@"\uf20e" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [self.menuButton setBackgroundColor:[UIColor turquoiseColor]];
    
    // Custom slider thumb size
    UIImage *thumbImage = [UIImage whiteCircle];
    [self.bufferLengthSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    int rounded = [[LPCAudioController sharedInstance] segmentLength];
    self.bufferLengthSlider.value = (float)rounded;
    self.lbBufferLengthValue.text = [NSString stringWithFormat:@"%dx512", rounded];
    
    [self.orderSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    rounded = [[LPCAudioController sharedInstance] order];
    self.orderSlider.value = (float)rounded;
    self.lbOrderValue.text = [NSString stringWithFormat:@"%d", rounded];
    
    self.view.backgroundColor = [UIColor wetAsphaltColor];
    self.menuView.backgroundColor = [UIColor midnightBlueColor];
    self.fftView.delegate = self;
    self.fftView.shouldFillColor = YES;
    [self _startDrawing];
}

- (void)_startDrawing {
    // Start LPC Instance
    [[LPCAudioController sharedInstance] start];
    
    if (!_drawTimer) {
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval: 1/kFPS
                                                      target: self
                                                    selector: @selector(_drawGraph)
                                                    userInfo: nil
                                                     repeats: YES];
    }
}

- (void)_stopDrawing {
    // Stop LPC Instance
    [[LPCAudioController sharedInstance] stop];
    
    // Invalidate Timer
    [_drawTimer invalidate];
    _drawTimer = nil;
}

- (void)_drawGraph {
    // LPC
    [self.fftView refresh];
    LPCAudioController* p = [LPCAudioController sharedInstance];
    self.FirstFormant.text = [NSString stringWithFormat:@"1stF: %.0f",p.firstFFreq];
    self.SecondFormant.text = [NSString stringWithFormat:@"2ndF: %.0f",p.secondFFreq];
    self.ThirdFormant.text = [NSString stringWithFormat:@"3rdF: %.0f",p.thirdFFreq];
    self.ForthFormant.text = [NSString stringWithFormat:@"4thF: %.0f",p.fourthFFreq];
    
    
}

- (IBAction)menuTouched:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    
    // Present the view controller
    [self.revealViewController revealToggleAnimated:YES];
}

- (IBAction)bufferLengthChanged:(id)sender {
    UISlider* slider = (UISlider*)sender;
    int rounded = roundl(slider.value);
    slider.value = (float)rounded;
    if (slider == self.bufferLengthSlider) {
        self.lbBufferLengthValue.text = [NSString stringWithFormat:@"%dx512", rounded];
        [[LPCAudioController sharedInstance] stop];
        [[LPCAudioController sharedInstance] setSegmentLength:rounded];
        [[LPCAudioController sharedInstance] start];
    } else {
        self.lbOrderValue.text = [NSString stringWithFormat:@"%d", rounded];
        [[LPCAudioController sharedInstance] stop];
        [[LPCAudioController sharedInstance] setOrder:rounded];
        [[LPCAudioController sharedInstance] start];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
