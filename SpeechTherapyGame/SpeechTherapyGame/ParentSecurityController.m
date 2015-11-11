//
//  ManagerGateViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 10/16/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "ParentSecurityController.h"
#import "GameManagerMasterView.h"

@interface ParentSecurityController ()
{
    NSTimer* _timer;
    NSArray* _numbers;
    int _selectedIndex;
}
@end

@implementation ParentSecurityController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Randomize buttons
    NSArray* arr = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    _numbers = [self _shuffleArray:arr];
    _selectedIndex = arc4random_uniform(6);
    self.lbInstruction.text = [NSString stringWithFormat:@"Press the number \"%@\"\nfor 3 seconds",[self _textFromNumber:[_numbers[_selectedIndex] intValue]]];
    
    // Init buttons
    for (int i = 0; i<6; i++) {
        NSString* title = _numbers[i];
        NSString* name = [NSString stringWithFormat:@"button%d",i+1];
        UIButton* button = (UIButton*)[self valueForKey:name];
        
        button.clipsToBounds = YES;
        button.layer.borderColor = button.titleLabel.textColor.CGColor;
        button.layer.borderWidth = 5.0f;
        button.layer.cornerRadius = button.width*0.5;
        [button setTitle:title forState:UIControlStateNormal];
        
        if (i == _selectedIndex) {
            [button addTarget:self
                       action:@selector(correctPressed)
             forControlEvents:UIControlEventTouchDown];
            [button addTarget:self
                       action:@selector(correctReleased)
             forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self
                       action:@selector(wrongPressed)
             forControlEvents:UIControlEventTouchDown];
        }
    }
}

#pragma mark - Actions
- (IBAction)wrongPressed {
    [_container dismissAnimated:YES completionHandler:nil];
}

- (IBAction)correctPressed {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                              target:self
                                            selector:@selector(_progress)
                                            userInfo:nil
                                             repeats:YES];
}

- (IBAction)correctReleased {
    [_timer invalidate];
    _timer = nil;
    _progressView.progress = 0.0;

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Private

- (void)_progress {
    _progressView.progress += 1/180.0f;
    if (_progressView.progress >= 1) {
        [_container dismissAnimated:NO completionHandler:^(UIViewController * _Nonnull presentedFSViewController) {
            [_homeSceneVC showGameManager];
        }];
    }
}

- (NSString*)_textFromNumber:(int)num {
    NSString* result = @"Zero";
    switch (num) {
        case 1:
            result = @"One";
            break;
        case 2:
            result = @"Two";
            break;
        case 3:
            result = @"Three";
            break;
        case 4:
            result = @"Four";
            break;
        case 5:
            result = @"Five";
            break;
        case 6:
            result = @"Six";
            break;
        case 7:
            result = @"Seven";
            break;
        case 8:
            result = @"Eight";
            break;
        default:
            result = @"Nine";
            break;
    }
    return result;
}

- (NSArray*)_shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform((u_int32_t)i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}


@end
