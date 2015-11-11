//
//  ScheduleViewController.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/7/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeSceneViewController;
@class MZFormSheetController;

@interface ScheduleViewController : UIViewController

@property (nonatomic, weak) MZFormSheetController* container;
@property (nonatomic, weak) HomeSceneViewController* homeSceneVC;


@end
