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

@interface ManagerGateViewController : UIViewController
@property (nonatomic, weak) MZFormSheetController* container;
@property (nonatomic, weak) HomeSceneViewController* homeSceneVC;

@property (nonatomic, weak) IBOutlet MBCircularProgressBarView* progressBar;

@end
