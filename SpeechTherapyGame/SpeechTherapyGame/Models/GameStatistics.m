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
+ (GameStatistics*) getGameStatFromLetter:(NSString*) letter andDate:(NSDate*) date {
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"letter == %@ AND dateAdded == %@",letter,date];
    GameStatistics* stats = [GameStatistics MR_findFirstWithPredicate:predicate];
    return stats;
}

@end
