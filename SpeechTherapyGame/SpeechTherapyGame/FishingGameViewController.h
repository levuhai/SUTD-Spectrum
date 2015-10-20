//
//  FishingGameViewController.h
//  SpeechTherapyGame
//
//  Created by Vit on 10/15/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>


@interface FishingGameViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView* countDownCircleContainer;
@property (nonatomic, weak) IBOutlet UIImageView* micImage;
@property (nonatomic, weak) IBOutlet MBCircularProgressBarView* countDownCircleView;

- (void) updateProgressValue: (GLfloat) value duration:(GLfloat) duration;
- (void) shouldShowCountDown:(BOOL) value;

@end
