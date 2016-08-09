//
//  AppService.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 2/7/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppService : NSObject

/**
 * gets singleton object.
 * @return singleton
 */
+ (AppService*)sharedInstance;

@end
