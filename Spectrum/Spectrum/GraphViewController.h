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
#import "FPPopoverController.h"

@class LPCView;

typedef enum : NSUInteger {
    kRecordMode = 0,
    kPractiseMode
} AppMode;

@interface GraphViewController : UIViewController<UIPopoverControllerDelegate,FPPopoverControllerDelegate>

//@property (strong, nonatomic) IBOutlet GraphView* graphView;
@property (strong, nonatomic) IBOutlet UIButton* menuButton;
@property (strong, nonatomic) IBOutlet UIView* menuView ;
@property (strong, nonatomic) IBOutlet LPCView *lpcView;
@property (strong, nonatomic) IBOutlet LPCView *lpcPractiseView;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (weak, nonatomic) IBOutlet UIButton *btnLoad;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *viewScore;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *lbScore;
@property (nonatomic, assign) AppMode mode;

- (IBAction)menuTouched:(id)sender;

@end
