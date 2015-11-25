//
//  GameStatistics.h
//  SpeechTherapyGame
//
//  Created by Vit on 11/13/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameStatistics : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (GameStatistics*) getGameStatFromLetter:(NSString*) letter between:(NSArray*) dates;
@end

NS_ASSUME_NONNULL_END

#import "GameStatistics+CoreDataProperties.h"
