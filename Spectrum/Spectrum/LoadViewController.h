//
//  LoadViewController.h
//  Spectrum
//
//  Created by Mr.J on 5/30/15.
//  Copyright (c) 2015 Earthling Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * listRecord;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
