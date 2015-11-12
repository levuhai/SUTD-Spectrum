//
//  AppDelegate.m
//  SpeechTherapyGame
//
//  Created by Vit on 8/31/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MagicalRecord cleanUp];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"DataModel"];
    [Games MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"gameId != 0"]];
    
    /*
#warning Demo data
    Games* game = [Games MR_createEntity];
    game.gameId = @(1);
    game.name = [NSString stringWithFormat:@"Fishing"];
    
    
    NSArray* sounds = @[@"a",@"b",@"c",@"d",@"e",@"f",@"g"];
    for (int i = 1; i <= sounds.count; i++) {
        Sounds* sound = [Sounds MR_createEntity];
        sound.soundId = @(i);
        sound.name = sounds[i-1];
        sound.dateAdded = [NSDate date];
    }
    
    
    for (int i = 0; i < 7; i++) {
        GameStatistics* gameStat = [GameStatistics MR_createEntity];
        gameStat.statId  = @(i+1);
        gameStat.gameId  = @(1);
        NSInteger playedTime = arc4random_uniform(50);
        gameStat.statistics = [GameStatistics makeStatisticsFrom:sounds[arc4random_uniform((int)sounds.count)] totalPlayedTime:@(playedTime) incorrectTimes:@(arc4random_uniform(playedTime))];
        
        NSDate *now = [NSDate date];
        NSDate *newDate1 = [now dateByAddingTimeInterval:60*60*24*i];
        gameStat.dateAdded = newDate1;
    }
     */
    
    // Got star
    [[NSUserDefaults standardUserDefaults] setObject:@[[NSDate date]] forKey:kAchievementDays];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
