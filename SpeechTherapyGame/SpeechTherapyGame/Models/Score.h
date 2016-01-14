//
//  Score.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/13/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "BaseModel.h"

@interface Score : BaseModel

@property(readonly, nonatomic) NSString* sound;
@property(readonly, nonatomic) NSString* phoneme;
@property(readonly, nonatomic) NSDate* date;
@property(readonly, nonatomic) float score;

- (id)initRandomScore;

@end
