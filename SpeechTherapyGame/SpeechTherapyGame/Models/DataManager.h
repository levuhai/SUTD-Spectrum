//
//  DataManager.h
//  MFCCDemo
//
//  Created by Hai Le on 12/21/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

// Singleton methods
+ (id) shared;

// Words
- (NSMutableArray*)getWords;
- (NSMutableArray*)getRandomWords;
- (NSMutableArray*)getWordsFromPhoneme:(NSString*)p;
- (NSMutableArray*)getUniquePhoneme;

@end
