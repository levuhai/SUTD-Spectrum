//
//  GameStatistics.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/16/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GameStatistics : NSManagedObject

@property (nonatomic, retain) NSNumber * correctTimesCount;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * incorrectTimesCount;
@property (nonatomic, retain) NSNumber * statId;
@property (nonatomic, retain) NSNumber * soundId;
@property (nonatomic, retain) NSNumber * gameId;

@end
