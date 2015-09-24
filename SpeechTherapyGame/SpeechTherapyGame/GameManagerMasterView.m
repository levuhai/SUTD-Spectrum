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
}
@end

@implementation GameManagerMasterView

- (void)viewDidLoad {
    
    // Side menu settings
    [[NGSplitViewManager sharedInstance]setDefaultOptions:@{kNGMenuBackgroundColorKey : RGB(47, 139, 193),
                                                            kNGMenuItemFontKey             : [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f],
                                                            kNGMenuItemFontColorKey     :[UIColor whiteColor],
                                                            kNGMenuitemSelectionColorKey        : [UIColor colorWithRed:0.890f green:0.494f blue:0.322f alpha:1.00f],
                                                            kNGMenuSeperatorColorKey  : RGB(47, 139, 193),
                                                            kNGMenuLineSeperatorKey     : @(YES),
                                                            }];
    
    [super viewDidLoad];
    
    _detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GameManagerDetailViewController"];

    [[NGSplitViewManager sharedInstance]setRootViewController:self masterViewController:_detailViewController detailViewController:[[UIViewController alloc] init]];
    [[NGSplitViewManager sharedInstance]setMenuItems:[self menuItems]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuItemSelected:) name:kMenuItemSelectesNotification object:nil];
    
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
    menuItem2.itemImage = [UIImage imageNamed:@"nav-icons-email2x.png"];
    [menuItem addObject:menuItem2];
    
    NGMenuItem *menuItem3 = [[NGMenuItem alloc]init];
    menuItem3.itemDescription = @"";
    menuItem3.itemImage = [UIImage imageNamed:@"nav-icons-home2x.png.png"];
    [menuItem addObject:menuItem3];
    
    
    return menuItem;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
