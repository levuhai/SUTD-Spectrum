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
#import "GuideRecordViewController.h"


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
    BOOL _isPractising;
    
    GuideRecordViewController *guideRecordView;
    SaveViewController * saveView;
    LoadViewController * loadView;
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
    _spinner.spinnerSize = self.startButton.width;
    [_spinner setColor:[UIColor greenSeaColor]];
    [self.view insertSubview:_spinner belowSubview:self.startButton];
    
//    [self _startDrawing];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    // Menu Button
    [self.menuButton.titleLabel setFont:[UIFont ioniconsOfSize:30]];
    [self.menuButton setTitle:@"\uf20e" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // Start Button
    int iconSize = 25;
    if (IS_IPAD)
        iconSize = 35;
    [self.startButton.titleLabel setFont:[UIFont ioniconsOfSize:iconSize]];
    [self.startButton setTitle:@"\uf461" forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // Save Button
    [self.saveButton.titleLabel setFont:[UIFont ioniconsOfSize:iconSize+5]];
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
    
    if (IS_IPAD) {
        [self loadRecordGuide];
    }
    
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

- (IBAction)recordDown:(id)sender{
    // start record
    if (!_isDrawing) {
        [self _startDrawing];
        [_spinner startAnimating];
        [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
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
    guideRecordView = [[GuideRecordViewController alloc]initWithNibName:@"GuideRecordViewController" bundle:nil];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:guideRecordView];
    popoverController.delegate = self;
    CGSize size = CGSizeMake(220, 85);
    popoverController.popoverContentSize = size; //your custom size.
    CGRect frame = CGRectMake(_btnRecord.frame.origin.x, _footerView.frame.origin.y, _btnRecord.frame.size.width, _btnLoad.frame.size.height);
    [popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
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
    saveView.data = [self copyDataToArray];
    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:saveView];
    [saveView setTitle:@"Save"];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigation];
    popoverController.delegate = self;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize size = CGSizeMake(screenRect.size.width/3, screenRect.size.height/3);
    popoverController.popoverContentSize = size; //your custom size.
    CGRect frame = CGRectMake(_btnRecord.frame.origin.x, _footerView.frame.origin.y, _btnRecord.frame.size.width, _btnLoad.frame.size.height);
    [popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
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
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigation];
    popoverController.delegate = self;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize size = CGSizeMake(screenRect.size.width/2, screenRect.size.height/2);
    popoverController.popoverContentSize = size; //your custom size.
    CGRect frame = CGRectMake(_btnLoad.frame.origin.x, _footerView.frame.origin.y, _btnLoad.frame.size.width, _btnLoad.frame.size.height);
    [popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
}

- (IBAction)loadTouchIphone:(id)sender {
    // show popover to load data.
    loadView = [[LoadViewController alloc]initWithNibName:@"LoadViewController" bundle:nil];
    UINavigationController * navigation = [[UINavigationController alloc]initWithRootViewController:loadView];
    [loadView setTitle:@"Load"];
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navigation];
    popoverController.delegate = self;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGSize size = CGSizeMake(screenRect.size.width/2, screenRect.size.height/2);
    popoverController.popoverContentSize = size; //your custom size.
    CGRect frame = CGRectMake(_btnLoad.frame.origin.x, _footerView.frame.origin.y, _btnLoad.frame.size.width, _btnLoad.frame.size.height);
    [popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

#pragma mark - Private Category

- (void)_startDrawing {
    [[AudioController sharedInstance] start];
    // Setup LPC
    [self.fftView startDrawing];
    
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
    [self.fftView stopDrawing];
    
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

#pragma mark - Save & Load data
- (void)saveData {
    [self.fftView saveGraph];
}

- (NSArray *)copyDataToArray {
    
    NSMutableArray * arrayData = [[NSMutableArray alloc]init];
    for(int i = 0; i<self.fftView.width ;i++){
        double b = [self.fftView getDataAtIndex:i];
        [arrayData addObject:[NSNumber numberWithDouble:b]];
    }
    return [arrayData copy];
}
@end
