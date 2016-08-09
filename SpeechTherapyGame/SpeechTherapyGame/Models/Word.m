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
    }
    return self;
}

- (NSString *)fullFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *file = [NSString stringWithFormat:@"sounds/%@",self.fullPath];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:file];
    return [filePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

- (NSString *)filteredFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *file = [[NSString stringWithFormat:@"sounds/%@",self.fullPath] stringByReplacingOccurrencesOfString:@"_full" withString:@"_filtered"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:file];
    return [filePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

- (NSString *)sampleFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *file = [NSString stringWithFormat:@"sounds/%@",self.samplePath];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:file];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return self.fullFilePath;
    }
    return [filePath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

- (NSString *)imgFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *file = [NSString stringWithFormat:@"sounds/%@",self.imgPath];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:file];
    return [filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
