//
//  RecordViewCell.h
//  Spectrum
//
//  Created by Mr.J on 5/30/15.
//  Copyright (c) 2015 Earthling Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon_check;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UILabel *lbScore;

@end
