//
//  ParentMasterVC.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 11/2/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZFormSheetController.h"

@interface ParentMasterController : UIViewController

@property (nonatomic, weak) IBOutlet UIView* detailView;
@property (nonatomic, weak) IBOutlet UIButton* btnDashboard;
@property (nonatomic, weak) IBOutlet UIButton* btnSounds;
@property (nonatomic, weak) IBOutlet UIButton* btnSettings;

@end
