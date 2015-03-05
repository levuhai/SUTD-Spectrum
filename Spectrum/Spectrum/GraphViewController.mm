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

#define absX(x) (x<0?0-x:x)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)))

@interface GraphViewController ()<SWRevealViewControllerDelegate> {
    
    float *tempDataLP;
    float *tempDataBP;
    float *tempDataHP;
    
    CGFloat _lpf, _bpf, _hpf;
    
    NSTimer *_drawTimer;
    //LPCAudioController *_lpcController;
    RTSpinKitView *_spinner;
    BOOL _isDrawing;
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
    // Do any additional setup after loading the view.
    _spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleBounce];
    _spinner.height = self.startButton.height + 4;
    _spinner.width = self.startButton.width + 4;
    _spinner.center = self.startButton.center;
    [_spinner setColor:[UIColor greenSeaColor]];
    [self.view insertSubview:_spinner belowSubview:self.startButton];
    
    [self _startDrawing];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    // Menu Button
    [self.menuButton.titleLabel setFont:[UIFont ioniconsOfSize:30]];
    [self.menuButton setTitle:@"\uf20e" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // Start Button
    [self.startButton.titleLabel setFont:[UIFont ioniconsOfSize:25]];
    [self.startButton setTitle:@"\uf461" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // Save Button
    [self.saveButton.titleLabel setFont:[UIFont ioniconsOfSize:30]];
    [self.saveButton setTitle:@"\uf420" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    
    //[self.menuButton setBackgroundColor:[UIColor turquoiseColor]];
    self.menuView.backgroundColor = [UIColor midnightBlueColor];
    self.graphView.backgroundColor = [UIColor wetAsphaltColor];
    [self.graphView.layer setCornerRadius:10.0f];
    self.graphView.layer.masksToBounds = YES;
    self.graphView.layer.borderColor =[UIColor darkGrayColor].CGColor;
    self.graphView.layer.borderWidth = 1;
}

- (void)viewDidAppear:(BOOL)animated {
    _spinner.center = _startButton.center;
    _spinner.x += 1;
    _spinner.y += 1;
}

#pragma mark - Actions 
- (IBAction)saveTouched:(id)sender {
    [self.fftView saveGraph];
    [self.graphView saveData];
}

- (IBAction)startTouched:(id)sender {
    if (!_isDrawing) {
        [self _startDrawing];
        [_spinner startAnimating];
        [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    } else {
        [self _stopDrawing];
        [_spinner stopAnimating];
        [self.startButton setTitleColor:_spinner.color forState:UIControlStateNormal];
        [self.startButton setTitleColor:_spinner.color forState:UIControlStateHighlighted];
    }
}

- (IBAction)menuTouched:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    
    // Present the view controller
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark - Private Category

- (void)_startDrawing {
    [[AudioController sharedInstance] start];
    // Setup LPC
    [self.fftView startDrawing];
    
    if (!_drawTimer) {
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval: 1/40.0f
                                                      target: self
                                                    selector: @selector(_drawGraph)
                                                    userInfo: nil
                                                     repeats: YES];
    }
    _isDrawing = YES;
}

- (void)_stopDrawing {
    [[AudioController sharedInstance] stop];
    
    [_drawTimer invalidate];
    _drawTimer = nil;
    _isDrawing = NO;
}

- (void)_drawGraph {
    [[AudioController sharedInstance] getFilterDataWithLowPass:&_lpf bandPass:&_bpf highPass:&_hpf];
   // [_lpcController calculateFormants];
    dispatch_async(dispatch_get_main_queue(),^{
        //if (_lpf == _lpf && _bpf == _bpf) {
        [self.graphView addLowPass:_lpf bandPass:_bpf highPass:_hpf];
        [self.graphView setNeedsDisplay];
            //[self.graphView addFirstF:[_lpcController firstFFreq]
             //                 secondF:[_lpcController secondFFreq]];
        
        //}
        
    });
   
}

#pragma mark - SWRevealViewControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    if (position == FrontViewPositionRight) {
        [self _stopDrawing];
    } else if (position == FrontViewPositionLeft) {
        [self _startDrawing];
    }
}

@end
