//
//  Sounds+CoreDataProperties.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/27/15.
//  Copyright © 2015 SUTD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Sounds.h"

NS_ASSUME_NONNULL_BEGIN

@interface Sounds (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *active;
@property (nullable, nonatomic, retain) NSString *colorCode;
@property (nullable, nonatomic, retain) NSDate *dateAdded;
@property (nullable, nonatomic, retain) NSDate *dateModified;
@property (nullable, nonatomic, retain) NSString *filePath;
@property (nullable, nonatomic, retain) id graphData;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *soundId;

@end

NS_ASSUME_NONNULL_END
