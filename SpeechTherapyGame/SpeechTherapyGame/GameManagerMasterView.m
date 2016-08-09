//
//  GameManagerViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/21/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "GameManagerMasterView.h"
#import "GameManagerDetailViewController.h"

@interface GameManagerMasterView ()
{
    GameManagerDetailViewController* _detailViewController;
    NGSplitViewManager* _splitViewManager;
}
@end

@implementation GameManagerMasterView

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Side menu settings
    
    _splitViewManager = [[NGSplitViewManager alloc] init];
    [_splitViewManager setDefaultOptions:@{kNGMenuBackgroundColorKey : RGB(47, 139, 193),
                                          kNGMenuItemFontKey             : [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f],
                                          kNGMenuItemFontColorKey     :[UIColor whiteColor],
                                          kNGMenuitemSelectionColorKey        : [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4f],
                                          kNGMenuSeperatorColorKey  : RGB(47, 139, 193),
                                          kNGMenuLineSeperatorKey     : @(YES),
                                           }];
    
    
    _detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameManagerDetailViewController"];

    // Bind detail view into master view
    [_splitViewManager setRootViewController:self masterViewController:_detailViewController detailViewController:[[UIViewController alloc] init]];
    // Add left menu
    [_splitViewManager setMenuItems:[self menuItems]];
    // Menu actions
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuItemSelected:) name:kMenuItemSelectesNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Menu items selected

- (void)menuItemSelected:(NSNotification*)notification{
    NSDictionary *userInfo = notification.userInfo;
    NGMenuItem *menuItem = [userInfo objectForKey:kNGMenuItemKey];
    NSLog(@"%@",menuItem);
    if (menuItem.menuIndex == 0) {
        [_detailViewController showGameStatsViewController];
    } else if (menuItem.menuIndex == 1) {
        [_detailViewController showSoundMngViewController];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - Side menu
- (NSArray*)menuItems{
    NSMutableArray *menuItem = [NSMutableArray array];
    
    NGMenuItem *menuItem1 = [[NGMenuItem alloc]init];
    menuItem1.itemDescription = @"";
    menuItem1.itemImage = [UIImage imageNamed:@"chart-icon"];
    [menuItem addObject:menuItem1];
    
    NGMenuItem *menuItem2 = [[NGMenuItem alloc]init];
    menuItem2.itemDescription = @"";
    menuItem2.itemImage = [UIImage imageNamed:@"schedule-icon"];
    [menuItem addObject:menuItem2];
    
    NGMenuItem *menuItem3 = [[NGMenuItem alloc]init];
    menuItem3.itemDescription = @"";
    menuItem3.itemImage = [UIImage imageNamed:@"home-icon"];
    [menuItem addObject:menuItem3];
    
    
    return menuItem;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
