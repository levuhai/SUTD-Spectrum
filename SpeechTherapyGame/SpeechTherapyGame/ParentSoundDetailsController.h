//
//  ParentSoundDetailsController.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/20/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentSoundDetailsController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel* lbText;

- (void)reloadTableWithDateString:(NSString*)date;

@end
