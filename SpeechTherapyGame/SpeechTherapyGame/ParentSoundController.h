//
//  SoundManagerViewController.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentSoundController : UIViewController

@property (weak, nonatomic) IBOutlet UIView* leftContainer;
@property (weak, nonatomic) IBOutlet UIView* rightContainer;
@property (weak, nonatomic) IBOutlet UIButton *btWordLv;
@property (weak, nonatomic) IBOutlet UIButton *btnSyllableLv;
@property (weak, nonatomic) IBOutlet UITableView* tableView;

@end
