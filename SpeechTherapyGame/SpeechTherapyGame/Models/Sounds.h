//
//  Sounds.h
//  SpeechTherapyGame
//
//  Created by Vit on 9/16/15.
//  Copyright (c) 2015 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Sounds : NSManagedObject

@property (nonatomic, retain) NSString * colorCode;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * soundId;

@end
