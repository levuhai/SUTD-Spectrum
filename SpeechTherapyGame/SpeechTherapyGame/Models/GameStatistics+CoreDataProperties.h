//
//  GameStatistics+CoreDataProperties.h
//  SpeechTherapyGame
//
//  Created by Vit on 11/13/15.
//  Copyright © 2015 SUTD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GameStatistics.h"

NS_ASSUME_NONNULL_BEGIN

@interface GameStatistics (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *dateAdded;
@property (nullable, nonatomic, retain) NSNumber *gameId;
@property (nullable, nonatomic, retain) NSString *letter;
@property (nullable, nonatomic, retain) NSNumber *totalPlayedCount;
@property (nullable, nonatomic, retain) NSNumber *correctCount;

@end

NS_ASSUME_NONNULL_END
