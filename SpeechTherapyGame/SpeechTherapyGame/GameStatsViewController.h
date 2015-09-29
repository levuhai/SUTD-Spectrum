//
//  GameStatsViewController.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameStatsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView* lineGraphContainer;
@property (weak, nonatomic) IBOutlet UIView* barGraphContainer;

@property (strong, nonatomic) NSMutableArray* lineGraphData;
@property (strong, nonatomic) NSMutableArray* barGraphData;

@end
