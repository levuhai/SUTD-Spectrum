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
    BOOL _isDrawing;
    
    UIViewController *guideRecordView;
    SaveViewController * saveView;
    LoadViewController * loadView;
    
    FPPopoverController *saveViewController;
    NSMutableArray * bufferGraph;
}

@end

@implementation GraphViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSaveVC) name:@"DISMISS_SAVE_VC" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_didLoadRecordData:) name:@"LOAD_RECORD" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_didLoadScore:) name:@"LOAD_SCORE" object:nil];
//    [self _startDrawing];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    // Menu Button
    [self.menuButton.titleLabel setFont:[UIFont ioniconsOfSize:30]];
    [self.menuButton setTitle:@"\uf20e" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    
    //[self.menuButton setBackgroundColor:[UIColor turquoiseColor]];
    self.menuView.backgroundColor = [UIColor midnightBlueColor];
//    self.graphView.backgroundColor = [UIColor wetAsphaltColor];
//    [self.graphView.layer setCornerRadius:10.0f];
//    self.graphView.layer.masksToBounds = YES;
//    self.graphView.layer.borderColor =[UIColor darkGrayColor].CGColor;
//    self.graphView.layer.borderWidth = 1;
    
    [self loadRecordGuide];
    
    // Default mode
    self.mode = kRecordMode;
    self.lpcPractiseView.shouldFillColor = YES;
    self.lpcView.shouldFillColor = YES;
    
    // init buffer
    bufferGraph = [[NSMutableArray alloc]initWithMaxItem:maxNumberOfBuffer];
}

#pragma mark - Getters & Setters

- (void)setMode:(AppMode)mode {
    _mode = mode;
    _lpcView.isRecordMode = mode == kRecordMode;
    self.lpcPractiseView.hidden = mode == kRecordMode;
    self.viewScore.hidden = mode == kRecordMode;
}

#pragma mark - Actions 
- (IBAction)saveTouched:(id)sender {
    [self.lpcView saveData];
//    [self.graphView saveData];
}

- (IBAction)startTouched:(id)sender {
    if (!_isDrawing) {
        [self _startDrawing];
    } else {
        [self _stopDrawing];
    }
}

- (IBAction)menuTouched:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    
    // Present the view controller
    [self.revealViewController revealToggleAnimated:YES];
}

- (IBAction)recordDown:(id)sender{
    // start record
    [_lbName setText:@"New record"];
    if (self.mode == kRecordMode) {
        [self _startDrawing];
    }else{
        self.mode = kRecordMode;
    }
}

- (IBAction)recordUp:(id)sender{
    // save record
    [self saveData];
    // copy data to nsarray
    
    [self performSelector:@selector(_stopDrawing) withObject:nil afterDelay:1/kFPS];
    // open save view controller
    [self performSelector:@selector(openSaveView) withObject:nil afterDelay:1.0f];
    
}

- (void)loadRecordGuide {
    guideRecordView = [[UIViewController alloc]initWithNibName:@"GuideRecordViewController" bundle:nil];
    if (IS_iPAD) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:guideRecordView];
        popoverController.delegate = self;
        CGSize size = CGSizeMake(220, 115);
        popoverController.popoverContentSize = size; //your custom size.
        CGRect frame = CGRectMake(_btnRecord.frame.origin.x, _footerView.frame.origin.y, _btnRecord.frame.size.width, _btnRecord.frame.size.height);
        [popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else {
        FPPopoverController *popoverController = [[FPPopoverController alloc]initWithViewController:guideRecordView delegate:self];
        popoverController.contentSize = CGSizeMake(220, 115);
        popoverController.tint = FPPopoverWhiteTint;
        popoverController.border = NO;
        popoverController.arrowDirection = FPPopoverArrowDirectionDown;
        
        [popoverController presentPopoverFromPoint:CGPointMake(_btnRecord.centerX,_btnRecord.centerY-15)];
    }
}

- (void)openSaveView{
    if (guideRecordView) {
        [guideRecordView dismissViewControllerAnimated:YES completion:^{
            guideRecordView = nil;
        }];
    }
    if (loadView) {
        [loadView dismissViewControllerAnimated:YES completion:^{
            loadView = nil;
        }];
    }
    saveView = [[SaveViewController alloc]initWithNibName:@"SaveViewController" bundle:nil];
    saveView.data = [self findData];
    [self.lpcView clearData];
    
    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:saveView];
    [saveView setTitle:@"Save"];
    if (IS_iPAD) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigation];
        popoverController.delegate = self;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGSize size = CGSizeMake(screenRect.size.width/3, screenRect.size.height/3);
        popoverController.popoverContentSize = size; //your custom size.
        CGRect frame = CGRectMake(_btnRecord.frame.origin.x, _footerView.frame.origin.y, _btnRecord.frame.size.width, _btnLoad.frame.size.height);
        [popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else {
        saveViewController = [[FPPopoverController alloc]initWithViewController:navigation];
        saveViewController.delegate = self;
        saveViewController.contentSize = CGSizeMake(300,250);
        saveViewController.tint = FPPopoverWhiteTint;
        saveViewController.border = NO;
        saveViewController.arrowDirection = FPPopoverArrowDirectionDown;
        [saveViewController presentPopoverFromView:_btnRecord];
    }
    
    
}

- (IBAction)loadTouched:(id)sender {
    // show popover to load data.
    if (guideRecordView) {
        [guideRecordView dismissViewControllerAnimated:YES completion:^{
            guideRecordView = nil;
        }];
    }
    if (saveView) {
        [saveView dismissViewControllerAnimated:YES completion:^{
            saveView = nil;
        }];
    }
    loadView = [[LoadViewController alloc]initWithNibName:@"LoadViewController" bundle:nil];
    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:loadView];
    [loadView setTitle:@"Load"];

    if (IS_iPAD) {
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigation];
        popoverController.delegate = self;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGSize size = CGSizeMake(screenRect.size.width/2, screenRect.size.height/2);
        popoverController.popoverContentSize = size; //your custom size.
        CGRect frame = CGRectMake(_btnLoad.frame.origin.x, _footerView.frame.origin.y, _btnLoad.frame.size.width, _btnLoad.frame.size.height);
        [popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    } else {
        FPPopoverController *popoverController = [[FPPopoverController alloc]initWithViewController:navigation delegate:self];
        popoverController.contentSize = CGSizeMake(300,250);
        popoverController.tint = FPPopoverWhiteTint;
        popoverController.border = NO;
        popoverController.arrowDirection = FPPopoverArrowDirectionDown;
        [popoverController presentPopoverFromView:_btnLoad];
    }
    
    
}

#pragma mark - Private Category

- (void)_startDrawing {
    [[AudioController sharedInstance] start];
    // Setup LPC
    [self.lpcView startDrawing];
    
    if (!_drawTimer) {
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval: 1/kFPS
                                                      target: self
                                                    selector: @selector(_drawGraph)
                                                    userInfo: nil
                                                     repeats: YES];
    }
    _isDrawing = YES;
}

- (void)_stopDrawing {
    [[AudioController sharedInstance] stop];
    [self.lpcView stopDrawing];
    
    [_drawTimer invalidate];
    _drawTimer = nil;
    _isDrawing = NO;
}

- (void)_drawGraph {
    [[AudioController sharedInstance] getFilterDataWithLowPass:&_lpf bandPass:&_bpf highPass:&_hpf];
    if(self.mode == kRecordMode){
        CGFloat sum = _lpf + _bpf + _hpf;
        [bufferGraph addItem:[NSNumber numberWithFloat:sum]];
    }
//    dispatch_async(dispatch_get_main_queue(),^{
//        [self.graphView addLowPass:_lpf bandPass:_bpf highPass:_hpf];
//        [self.graphView setNeedsDisplay];
//    });
   
}

- (void)_didLoadRecordData:(NSNotification *)notification
{
    NSDictionary *data = [[notification userInfo] copy];
    double * arrayPointer;
    if (data) {
        NSArray * arrayData = [data objectForKey:@"data"];
        NSString * name = [data objectForKey:@"name"];
        [_lbName setText:name];
        int bufferSize = _lpcView.width;
        arrayPointer = new double[bufferSize];
        // Copy the buffer
        for (int i = 0; i < _lpcView.width; i++) {
            arrayPointer[i] = [arrayData[i] doubleValue];
        }
    }
    self.mode = kPractiseMode;
    // Load Practise View
    [_lpcPractiseView loadData:arrayPointer];
    _lpcPractiseView.shouldFillColor = YES;
    [_lpcPractiseView setNeedsDisplay];
    
    // Start drawing LPC
    [_lpcView startDrawing];
}

- (void)_didLoadScore:(NSNotification *)notification
{
    double sum = 0;
    double threshold = 18;
    for (int i = 0; i < _lpcPractiseView.width; i++) {
        double itemA = [_lpcPractiseView getSaveDataAtIndex:i];
        double itemB = [_lpcView getPlotDataAtIndex:i];
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
- (void)dismissSaveVC {
    if (saveViewController) {
        [saveViewController dismissPopoverAnimated:YES];
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
    [self.lpcView saveData];
}

-(NSArray *)findData{
    int index = 0;
    float max = 0;
    for (int i = 0; i< [bufferGraph count]; i++) {
        float item = [[bufferGraph objectAtIndex:i] floatValue];
        if (max >= item) {
            index = i;
        }
    }
    [bufferGraph removeAllObjects];
    return [self.lpcView getArrayDataAtIndex:index];
}
- (NSArray *)copyDataToArray {
    
    NSMutableArray * arrayData = [[NSMutableArray alloc]init];
    for(int i = 0; i<self.lpcView.width ;i++){
        double b = [self.lpcView getDataAtIndex:i];
        [arrayData addObject:[NSNumber numberWithDouble:b]];
    }
    return [arrayData copy];
}

@end
