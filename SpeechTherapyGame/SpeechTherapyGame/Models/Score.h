//
//  Score.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/13/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "BaseModel.h"

@interface Score : BaseModel

@property(strong, nonatomic) NSString* sound;
@property(strong, nonatomic) NSString* phoneme;
@property(strong, nonatomic) NSDate* date;
@property(assign, nonatomic) float score;
@property(strong, nonatomic) NSString* recordPath;
@property(strong, nonatomic) NSString* dateString;

- (id)initRandomScore;
- (NSString *)filePath;

@end
