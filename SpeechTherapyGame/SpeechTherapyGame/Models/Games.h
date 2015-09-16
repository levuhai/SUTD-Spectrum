//
//  Games.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/16/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Games : NSManagedObject

@property (nonatomic, retain) NSString * dataFolderPath;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * playedTimesCount;
@property (nonatomic, retain) NSNumber * gameId;

@end
