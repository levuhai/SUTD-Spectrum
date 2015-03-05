//
//  LPCViewController.h
//  Spectrum
//
//  Created by Hai Le on 29/9/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LPCView;

@interface LPCViewController : UIViewController

@property (strong, nonatomic) IBOutlet LPCView *fftView;
@property (strong, nonatomic) IBOutlet UIButton* menuButton;
@property (strong, nonatomic) IBOutlet UIView* menuView;
@property (strong, nonatomic) IBOutlet UILabel* FirstFormant;
@property (strong, nonatomic) IBOutlet UILabel* SecondFormant;
@property (strong, nonatomic) IBOutlet UILabel* ThirdFormant;
@property (strong, nonatomic) IBOutlet UILabel* ForthFormant;

@end
