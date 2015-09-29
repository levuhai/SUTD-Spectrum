//
//  GameStatistics.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/27/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameStatistics : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+(NSDictionary*)makeStatisticsFrom:(NSString*) letter totalPlayedTime:(NSNumber*) playedTimes incorrectTimes:(NSNumber*) incorrectTimes;
+ (NSInteger) getPointsFrom:(NSDictionary*) gameStat;

@end

NS_ASSUME_NONNULL_END

#import "GameStatistics+CoreDataProperties.h"
