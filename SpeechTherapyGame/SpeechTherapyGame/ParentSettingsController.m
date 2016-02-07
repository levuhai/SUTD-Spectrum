//
//  ParentSettingsController.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/6/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "ParentSettingsController.h"

@interface ParentSettingsController ()

@end

@implementation ParentSettingsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *sliderTrackImage = [[UIImage imageNamed:@"sliderBar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 17)];
    
    [self.sliderDifficulty setMinimumTrackImage: sliderTrackImage forState: UIControlStateNormal];
    [self.sliderDifficulty setMaximumTrackImage: sliderTrackImage forState: UIControlStateNormal];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"sliderButton"] forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"sliderButton"] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
