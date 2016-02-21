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
#define kKeySoundVol        @"f171bfd96ce7bbed7465d1fca7cc87d5"
#define kKeyMusicVol        @"b9b4c06e123dc58daa346998d5153c56"
#define kKeyDifficulty      @"e69523758d94fc38ab2e3366bdc5fc2f"
#define kKeyWordLevel       @"167094b034ca94cd99966dcae931fcc0"
#define kKeySyllableLevel   @"13d443903bb94c355293c906126c2f52"

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
#define fileFish "fish1.png"
#define fishAwidth 104.0
#define fishAheight 72.0
#define fishAContactSizeRatio 0.3

#define fishSize0 0.5
#define fishSize1 0.65
#define fishSize2 0.8
#define fishSize3 1.0
#define fishSize4 1.15
#define turtleWidth 132.0
#define turtleHeight 102.0

#define yHookStart 480
#define hookRaiseSpeed 120.0f
#define hookDropSpeed 120.0f
#define hookMovementDeltaY 1.0f


#endif /* Constants_h */
