//
//  GraphViewController.h
//  Spectrum
//
//  Created by Hai Le on 28/6/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "GraphView.h"
#import "LPCAudioController.h"
#import <SpinKit/RTSpinKitView.h>

@class LPCView;

@interface GraphViewController : UIViewController

@property (strong, nonatomic) IBOutlet GraphView* graphView;
@property (strong, nonatomic) IBOutlet UIButton* menuButton;
@property (strong, nonatomic) IBOutlet UIButton* saveButton;
@property (strong, nonatomic) IBOutlet UIButton* startButton;
@property (strong, nonatomic) IBOutlet UIView* menuView ;
@property (strong, nonatomic) IBOutlet LPCView *fftView;

- (IBAction)menuTouched:(id)sender;

@end
