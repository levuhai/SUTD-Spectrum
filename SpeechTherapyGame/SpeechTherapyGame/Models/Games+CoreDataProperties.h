//
//  Games+CoreDataProperties.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/27/15.
//  Copyright © 2015 SUTD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Games.h"

NS_ASSUME_NONNULL_BEGIN

@interface Games (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *gameId;
@property (nullable, nonatomic, retain) NSString *name;

@end

NS_ASSUME_NONNULL_END
