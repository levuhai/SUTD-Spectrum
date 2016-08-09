//
//  ParentSoundDetailsController.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/20/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParentSoundDetailsController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel* lbText;
@property (weak, nonatomic) IBOutlet UITableView* tableView;

- (void)reloadTableWithDateString:(NSString*)date;
- (void)reloadTableWithSound:(NSString*)sound;

@end
