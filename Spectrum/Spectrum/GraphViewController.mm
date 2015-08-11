//
//  GraphViewController.m
//  Spectrum
//
//  Created by Hai Le on 28/6/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import "GraphViewController.h"
#import "AudioController.h"
#import "UIFont+Custom.h"
#import "UIColor+Flat.h"
#import "LPCView.h"
#import "LoadViewController.h"
#import "NSObject+UIPopover_Iphone.h"
#import "SaveViewController.h"
#import "Configs.h"
#import "NSMutableArray+Queue.h"
#include <math.h>

#define absX(x) (x<0?0-x:x)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)))

@interface GraphViewController ()<SWRevealViewControllerDelegate> {
    
    float *tempDataLP;
    float *tempDataBP;
    float *tempDataHP;
    
    CGFloat _lpf, _bpf, _hpf;
    
    NSTimer *_drawTimer;
    //LPCAudioController *_lpcController;
    FPPopoverController *loadPopOverController;
    LoadViewController * loadView;
    
    FPPopoverController *savePopOverController;
    SaveViewController * saveView;
    
    NSMutableArray * bufferFilter;
    NSMutableArray * bufferLPC;
    BOOL _bufferEnabled;
}

@end

@implementation GraphViewController

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
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(dismissSaveVC)
                                                name:@"DISMISS_SAVE_VC"
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(_didLoadRecordData:) name:@"LOAD_RECORD"
                                              object:nil];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    // Menu Button
    [self.menuButton.titleLabel setFont:[UIFont ioniconsOfSize:30]];
    [self.menuButton setTitle:@"\uf20e" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // Default mode
    self.mode = kRecordMode;
    self.lpcPractiseView.shouldFillColor = YES;
    self.lpcRecordView.shouldFillColor = YES;
    
    // init buffer
    _bufferEnabled = _segment.selectedSegmentIndex;
    bufferFilter = [[NSMutableArray alloc]initWithMaxItem:maxNumberOfBuffer];
    bufferLPC = [[NSMutableArray alloc]initWithMaxItem:maxNumberOfBuffer];
    
    // Graph View
    
    // Start drawing graph by default
    [self _startDrawing];
}

#pragma mark - Getters & Setters

- (void)setMode:(AppMode)mode {
    [self.lpcRecordView clearSavedData];
    
    _mode = mode;
    self.btnLoad.hidden = mode == kPractiseMode;
    self.lpcPractiseView.hidden = mode == kRecordMode;
    self.viewScore.hidden = mode == kRecordMode;
    self.segment.hidden = mode != kRecordMode;
}

#pragma mark - Actions

- (IBAction)segmentValueChanged:(UISegmentedControl*)sender {
    _bufferEnabled = sender.selectedSegmentIndex;
}

- (IBAction)menuTouched:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    
    // Present the view controller
    [self.revealViewController revealToggleAnimated:YES];
}

- (IBAction)recordClicked:(id)sender{
    self.btnRecord.selected = !self.btnRecord.selected;
    if (self.btnRecord.selected) {
        if (self.mode == kRecordMode) {
            [self saveData];
            [self openSaveView];
        }
        [self _stopDrawing];
    } else {
        [self.lpcRecordView clearSavedData];
        [self _startDrawing];
    }
}

- (IBAction)newClicked:(id)sender {
    self.btnLoad.hidden = !self.btnLoad.hidden;
    self.mode = kRecordMode;
}

- (IBAction)loadTouched:(id)sender {
    // show popover to load data.
    if (saveView) {
        [saveView dismissViewControllerAnimated:YES completion:^{
            saveView = nil;
        }];
    }
    loadView = [[LoadViewController alloc]initWithNibName:@"LoadViewController" bundle:nil];
   
    loadPopOverController = [[FPPopoverController alloc]initWithViewController:loadView
                                                                      delegate:self];
    loadPopOverController.contentSize = CGSizeMake(400,self.view.height-60);
    loadPopOverController.tint = FPPopoverWhiteTint;
    loadPopOverController.border = NO;
    [loadPopOverController setShadowsHidden:YES];
    loadPopOverController.arrowDirection = FPPopoverArrowDirectionDown;
    [loadPopOverController presentPopoverFromView:_btnLoad];
}

- (void)openSaveView {
    // Dismiss load popover if displayed
    if (loadView) {
        [loadView dismissViewControllerAnimated:YES completion:^{
            loadView = nil;
        }];
    }
    saveView = [[SaveViewController alloc]initWithNibName:@"SaveViewController" bundle:nil];
    
    saveView.data = [self findData];
    
    [self.lpcRecordView clearSavedData];
    [self.lpcPractiseView clearSavedData];
    
    [self.lpcRecordView loadData: [self _toPointer:saveView.data]];
    [self.lpcRecordView setNeedsDisplay];
    
    savePopOverController = [[FPPopoverController alloc]initWithViewController:saveView];
    savePopOverController.delegate = self;
    savePopOverController.contentSize = CGSizeMake(400,self.view.height-60);
    savePopOverController.tint = FPPopoverWhiteTint;
    savePopOverController.border = NO;
    [savePopOverController setShadowsHidden:YES];
    savePopOverController.arrowDirection = FPPopoverArrowDirectionDown;
    [savePopOverController presentPopoverFromView:_btnRecord];
}

#pragma mark - Private Category

- (void)_startDrawing {
    // Start Filter Instance
    [[AudioController sharedInstance] start];
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
    // Stop Filter Instance
    [[AudioController sharedInstance] stop];
    // Stop LPC Instance
    [[LPCAudioController sharedInstance] stop];
    
    // Invalidate Timer
    [_drawTimer invalidate];
    _drawTimer = nil;
}

- (void)_drawGraph {
    LPCAudioController *lpc = [LPCAudioController sharedInstance];
    // Filter
    [[AudioController sharedInstance] getFilterDataWithLowPass:&_lpf
                                                      bandPass:&_bpf
                                                      highPass:&_hpf];

    // LPC
    [self.lpcRecordView refresh];
    // Formants
    float c = 50.0f;
    [self.formantView addLowPass:lpc.firstFFreq/c bandPass:lpc.secondFFreq/c highPass:lpc.thirdFFreq/c];
    [self.formantView setNeedsDisplay];
    
    // Buffer
    if(self.mode == kRecordMode){
        if (_bufferEnabled) {
            // Filter Buffer
            CGFloat sum = _lpf + _bpf + _hpf;
            [bufferFilter addItem:[NSNumber numberWithFloat:sum]];
            
            // LPC Buffer
            [bufferLPC addItem:[self.lpcRecordView currentRawData]];
        }
    } else {
        // Calculating score
        double sum = 0;
        double threshold = 18;
        for (int i = 0; i < _lpcPractiseView.width; i++) {
            double itemA = [_lpcPractiseView savedPlotDataAtIndex:i];
            double itemB = [_lpcRecordView currentPlotDataAtIndex:i];
            double diff = fabs(itemA-itemB);
            if (diff>=threshold) {
                diff=_lpcPractiseView.height;
            }
            sum+= diff;
        }
        
        double percent = 1- (sum/_lpcPractiseView.height/ _lpcPractiseView.width);
        _lbScore.text = [NSString stringWithFormat:@"%.0f%%",percent * 100];
        [_progressView setProgress:percent];
    }
}

- (double*)_toPointer:(NSArray*) arrayData {
    double * arrayPointer;
    if (arrayData) {
        int bufferSize = _lpcRecordView.width;
        arrayPointer = new double[bufferSize];
        // Copy the buffer
        for (int i = 0; i < _lpcRecordView.width; i++) {
            arrayPointer[i] = [arrayData[i] doubleValue];
        }
    }
    return arrayPointer;
}

- (void)_didLoadRecordData:(NSNotification *)notification
{
    NSDictionary *data = [[notification userInfo] copy];
    double * arrayPointer;
    if (data) {
        NSArray * arrayData = [data objectForKey:@"data"];
        NSString * name = [data objectForKey:@"name"];
        [_lbName setText:name];
        int bufferSize = _lpcRecordView.width;
        arrayPointer = new double[bufferSize];
        // Copy the buffer
        for (int i = 0; i < _lpcRecordView.width; i++) {
            arrayPointer[i] = [arrayData[i] doubleValue];
        }
    }
    self.mode = kPractiseMode;
    // Load Practise View
    [_lpcPractiseView loadData:arrayPointer];
    _lpcPractiseView.shouldFillColor = YES;
    [_lpcPractiseView setNeedsDisplay];
    
    // Start drawing LPC
    [self _startDrawing];
    self.btnRecord.selected = NO;
}

- (void)dismissSaveVC {
    if (savePopOverController) {
        [savePopOverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - SWRevealViewControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionRight) {
        //[self _stopDrawing];
    } else if (position == FrontViewPositionLeft) {
        //[self _startDrawing];
    }
}

#pragma mark - Save & Load data
- (void)saveData {
    [self.lpcRecordView saveData];
}

-(NSArray *)findData {
    if (!_bufferEnabled) {
        return _lpcRecordView.currentRawData;
    }
    int index = 0;
    float max = 0;
    for (int i = 0; i< [bufferFilter count]; i++) {
        float item = [[bufferFilter objectAtIndex:i] floatValue];
        if (item >= max) {
            index = i;
            max = item;
        }
    }
    [bufferFilter removeAllObjects];
    NSArray * array = [[bufferLPC objectAtIndex:index] copy];
    [bufferLPC removeAllObjects];
    return array;
}

@end
