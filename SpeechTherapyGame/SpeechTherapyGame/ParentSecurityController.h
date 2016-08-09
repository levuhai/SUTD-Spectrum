//
//  ManagerGateViewController.h
//  SpeechTherapyGame
//
//  Created by Vit on 10/16/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZFormSheetController.h"
#import "HomeSceneViewController.h"

@interface ParentSecurityController : UIViewController
@property (nonatomic, weak) MZFormSheetController* container;
@property (nonatomic, weak) HomeSceneViewController* homeSceneVC;

@property (nonatomic, weak) IBOutlet UILabel* lbInstruction;
@property (nonatomic, weak) IBOutlet UIProgressView* progressView;
@property (nonatomic, weak) IBOutlet UIButton* button1;
@property (nonatomic, weak) IBOutlet UIButton* button2;
@property (nonatomic, weak) IBOutlet UIButton* button3;
@property (nonatomic, weak) IBOutlet UIButton* button4;
@property (nonatomic, weak) IBOutlet UIButton* button5;
@property (nonatomic, weak) IBOutlet UIButton* button6;


@end
