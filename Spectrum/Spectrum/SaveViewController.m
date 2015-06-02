//
//  SaveViewController.m
//  Spectrum
//
//  Created by Mr.J on 5/30/15.
//  Copyright (c) 2015 Earthling Studio. All rights reserved.
//

#import "SaveViewController.h"
#import "LPCView.h"

@interface SaveViewController ()

@end


@implementation SaveViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
    _btnSave.layer.cornerRadius = 5;
    _btnSave.clipsToBounds = YES;
    _btnCancel.layer.cornerRadius = 5;
    _btnCancel.clipsToBounds = YES;
    _btnCancel.layer.borderWidth = 0.5;
    _btnCancel.layer.borderColor = [UIColor grayColor].CGColor;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions
- (IBAction)saveTouched:(id)sender {
    
    // convert to data to NSArray
    if (_data) {
        // save data
        NSDictionary * dict = @{@"data":_data,@"name":_tfName.text};
        NSUserDefaults * userDefaults   = [NSUserDefaults standardUserDefaults];
        NSMutableArray * dataOfUserDefaults           = [[userDefaults objectForKey:@"data"] mutableCopy];
        if (!dataOfUserDefaults) {
            dataOfUserDefaults = [[NSMutableArray alloc]init];
        }
        [dataOfUserDefaults addObject:dict];
        
        [userDefaults setObject:[dataOfUserDefaults copy] forKey:@"data"];
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"Save record successfully");
        [self dismissViewControllerAnimated:YES completion:^{
            //handle did dismiss
        }];
    }
    
}

- (IBAction)cancelTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //handle did dismiss
    }];
}

+ (void)addToArrayData:(NSNumber *)number {
    
}

@end
