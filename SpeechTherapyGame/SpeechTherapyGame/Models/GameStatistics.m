//
//  GameStatistics.m
//  SpeechTherapyGame
//
//  Created by Vit on 11/13/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "GameStatistics.h"

@implementation GameStatistics

// Insert code here to add functionality to your managed object subclass
+ (GameStatistics*) getGameStatFromWord:(NSString*) letter between:(NSArray*) dates {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(word == %@) AND (dateAdded >= %@) AND (dateAdded <= %@)",letter,dates[0],dates[1]];
    GameStatistics* stats = [GameStatistics MR_findFirstWithPredicate:predicate];
    return stats;
}

@end
