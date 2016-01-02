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

@property(readonly, nonatomic) NSString* wText;
@property(readonly, nonatomic) NSString* wPhonetic;
@property(readonly, nonatomic) NSString* pText;
@property(readonly, nonatomic) NSString* pPhonetic;
@property(readonly, nonatomic) NSString* wFile;
@property(readonly, nonatomic) NSString* pFile;
@property(readonly, nonatomic) int start;
@property(readonly, nonatomic) int end;
@property(readonly, nonatomic) int wLength;
@property(readonly, nonatomic) int pLength;
@property(readonly, nonatomic) NSString* speaker;

@end
