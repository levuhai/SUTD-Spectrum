//
//  Score.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/13/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "Score.h"
#import "NSDictionary+ES.h"

@implementation Score

- (id)initRandomScore {
    self = [super init];
    if (self) {
        NSInteger randomIndex = arc4random() % 3;
        NSInteger randomIndex1 = arc4random() % 2;
        NSArray *p = @[@"b",@"d",@"ð"];
        NSArray *s = @[@"banana",@"əbə",@"dog",@"ədəu",@"ðʊə",@"ɛəð"];
        _phoneme = p[randomIndex];
        _sound = s[randomIndex*2+randomIndex1];
        NSInteger randomNumber = arc4random() % 5000000;
        _date = [NSDate dateWithTimeIntervalSinceNow:randomNumber-4999999+40000];
        randomNumber = arc4random() % 100;
        _score = randomNumber / 120.0f;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        // ID
        self.ID = [dict intForKey:@"id"];
        _phoneme = [dict stringForKey:@"phoneme"];
        _sound = [dict stringForKey:@"sound"];
        _score = [dict floatForKey:@"score"];
        _date = [dict dateForKey:@"date"];
    }
    return self;
}

@end
