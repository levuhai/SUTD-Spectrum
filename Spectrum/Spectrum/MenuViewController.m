//
//  MenuViewController.m
//  Spectrum
//
//  Created by Hai Le on 1/7/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import "MenuViewController.h"
#import "GraphViewController.h"
#import "HighPassViewController.h"
#import "SWRevealViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.tableView.backgroundColor = [UIColor colorFromHexCode:@"eff0f2"];
}

- (void)viewWillAppear:(BOOL)animated {
    
//    NSIndexPath *indexPath;
//    
//    UINavigationController *nav = (UINavigationController*) self.revealViewController.frontViewController;
//    if ([nav.visibleViewController.title isEqual:@"CG"]){
//        if (indexPath.row == 1) {
//            indexPath = [NSIndexPath indexPathForRow:1 inSection: 0];
//        }
//    } else if ([nav.visibleViewController.title isEqual:@"HPS"]){
//        if (indexPath.row == 2) {
//           indexPath = [NSIndexPath indexPathForRow:2 inSection: 0];
//        }
//    }
//    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundColor = [UIColor colorFromHexCode:@"eff0f2"];;
    
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor turquoiseColor];
    }
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor wetAsphaltColor];
    bgColorView.layer.cornerRadius = 3;
    bgColorView.layer.masksToBounds = YES;
    [cell setSelectedBackgroundView:bgColorView];
    
    UILabel* l = (UILabel*)[cell.contentView viewWithTag:101];
    l.highlightedTextColor = [UIColor turquoiseColor];
    
    cell.selectedBackgroundView.tintColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath != nil)
    {
        UIButton *b = (UIButton*)[[tableView cellForRowAtIndexPath:indexPath].contentView viewWithTag:100];
        b.tintColor = [UIColor turquoiseColor];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath != nil)
    {
        UIButton *b = (UIButton*)[[tableView cellForRowAtIndexPath:indexPath].contentView viewWithTag:100];
        b.tintColor = [UIColor midnightBlueColor];
    }
}

- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    cell.contentView.backgroundColor = color;
    cell.backgroundColor = color;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
    
}

@end
