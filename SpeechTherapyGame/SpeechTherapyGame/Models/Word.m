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
        _wLength = [dict intForKey:@"w_length"];
        _pLength = [dict intForKey:@"p_length"];
        _start = [dict intForKey:@"start"];
        _end = [dict intForKey:@"end"];
        _wText = [dict stringForKey:@"w_text"];
        _pText = [dict stringForKey:@"p_text"];
        _wPhonetic = [dict stringForKey:@"w_phonetic"];
        _pPhonetic = [dict stringForKey:@"p_phonetic"];
        _wFile = [dict stringForKey:@"w_file"];
        _pFile = [dict stringForKey:@"p_file"];
        _speaker = [dict stringForKey:@"speaker"];
        
    }
    return self;
}

@end
