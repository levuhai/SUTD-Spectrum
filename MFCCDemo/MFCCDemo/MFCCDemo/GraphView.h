//
//  GraphView.h
//  MFCCDemo
//
//  Created by Hai Le on 11/23/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "MFCCProcessor.hpp"
#include "MFCCUtils.h"
#include "WordMatch.h"

@interface GraphView : UIView

- (void)inputMFCC:(FeatureTypeDTW::Features)feature start:(int)start end:(int)end;

@end
