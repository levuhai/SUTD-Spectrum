//
//  Word.m
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "Word.h"
#import "NSDictionary+ES.h"

@implementation Word

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        // ID
        self.ID = [dict intForKey:@"id"];
        _phoneme = [dict stringForKey:@"phoneme"];
        _sound = [dict stringForKey:@"sound"];
        _phonetic = [dict stringForKey:@"phonetic"];
        _fullPath = [dict stringForKey:@"full_path"];
        _filterPath = [_fullPath stringByReplacingOccurrencesOfString:@"_full" withString:@"_filtered"];
        _croppedPath = [dict stringForKey:@"cropped_path"];
        _imgPath = [dict stringForKey:@"img_path"];
        _samplePath = [dict stringForKey:@"sample_path"];
        
        _fullLen = [dict intForKey:@"full_len"];
        _croppedLen = [dict intForKey:@"cropped_len"];
        _type = [dict intForKey:@"type"];
        _position = [dict intForKey:@"position"];
        _start = 0;
        _end = _fullLen;
        _targetStart = [dict intForKey:@"cropped_start"];
        _targetEnd = [dict intForKey:@"cropped_end"];
        NSArray* rr = [[_fullPath stringByReplacingOccurrencesOfString:@"_full.wav" withString:@""] componentsSeparatedByString:@"_"];
        _speaker = [rr lastObject];
    }
    return self;
}

@end
