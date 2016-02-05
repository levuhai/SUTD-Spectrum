//
//  Constants.h
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/21/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define kScore 0.4

#define kKeySound @"soundOn"
#define kKeyBgm @"bgmOn"

#define kNotificationShowParentsMode @"showParentsMode"
#define kNotificationShowSchedule @"showSchedule"

#define bitmaskCategoryNeutral 32
#define bitmaskCategoryCreature 1
#define bitmaskCategoryHook 2
#define bitmaskCategoryChum 3
#define bitmaskCategoryTuna 4
#define bitmaskCategorySeaTurtle 5

#define kTileWidth 20.0
#define zCard 1000
#define zOcean 2
#define zOceanBackground zOcean-0.5
#define zOceanForeground zOcean+0.5

#define zBoat 0
#define zBoatForeground zBoat+0.5
#define zBoatBackground zBoat-0.5

#define nodeNameHook "hook"
#define nodeNameFish "fish"
#define nodeNameTurtle "turtle"
#define fileTurtle "seaturtle1.png"
#define turtleWidth 132.0
#define turtleHeight 102.0

#define yHookStart 480
#define hookRaiseSpeed 120.0f
#define hookDropSpeed 120.0f
#define hookMovementDeltaY 1.0f


#endif /* Constants_h */
