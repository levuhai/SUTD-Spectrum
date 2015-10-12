//
//  GameStatistics.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/27/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "GameStatistics.h"

@implementation GameStatistics

// Insert code here to add functionality to your managed object subclass
+ (NSDictionary*) makeStatisticsFrom:(NSString*) letter totalPlayedTime:(NSNumber*) playedTimes incorrectTimes:(NSNumber*) incorrectTimes {
    return @{letter : @{ @"incorrect" : incorrectTimes , @"total" : playedTimes}};
}

+ (NSInteger) getPointsFrom:(NSDictionary*) gameStat {
    return [[[[gameStat allValues] objectAtIndex:0] objectForKey:@"total"] integerValue] - [[[[gameStat allValues] objectAtIndex:0] objectForKey:@"incorrect"] integerValue];
}

+ (NSInteger) getPlayedTimeFrom:(NSDictionary*) gameStat {
    return [[[[gameStat allValues] objectAtIndex:0] objectForKey:@"total"] integerValue];
}

@end
