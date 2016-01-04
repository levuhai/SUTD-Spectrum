//
//  ActiveWord+CoreDataProperties.h
//  SpeechTherapyGame
//
//  Created by Vit on 1/4/16.
//  Copyright © 2016 SUTD. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ActiveWord.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActiveWord (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *word;
@property (nullable, nonatomic, retain) NSString *phoneme;
@property (nullable, nonatomic, retain) NSString *fileName;

@end

NS_ASSUME_NONNULL_END
