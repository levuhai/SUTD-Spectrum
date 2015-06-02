//
//  SaveViewController.h
//  Spectrum
//
//  Created by Mr.J on 5/30/15.
//  Copyright (c) 2015 Earthling Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaveViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (strong,nonatomic) NSArray * data;

+ (void)addToArrayData:(NSNumber *)number;
@end
