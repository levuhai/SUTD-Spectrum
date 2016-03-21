//
//  Word.h
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface Word : BaseModel

@property(readonly, nonatomic) NSString* phoneme;
@property(readonly, nonatomic) NSString* sound;
@property(readonly, nonatomic) NSString* phonetic;
@property(readonly, nonatomic) int position;

@property(readonly, nonatomic) NSString* fullPath;
@property(readonly, nonatomic) int fullLen;
@property(readonly, nonatomic) NSString* croppedPath;
@property(readonly, nonatomic) int croppedLen;

@property(readonly, nonatomic) int start;
@property(readonly, nonatomic) int end;
@property(readonly, nonatomic) int targetStart;
@property(readonly, nonatomic) int targetEnd;
@property(readonly, nonatomic) int type;

@property(readonly, nonatomic) NSString* imgPath;
@property(readonly, nonatomic) NSString* samplePath;
@property(readonly, nonatomic) NSString* speaker;

@end
