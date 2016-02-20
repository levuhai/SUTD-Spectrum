//
//  PhonemeCell.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/4/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* lbText;
@property (weak, nonatomic) IBOutlet UILabel* lbDate;
@property (weak, nonatomic) IBOutlet UILabel* lbScore;
@property (weak, nonatomic) IBOutlet UILabel* lbPhoneme;
@property (strong, nonatomic) NSString* filePath;

- (IBAction)playSound:(id)sender;

@end
