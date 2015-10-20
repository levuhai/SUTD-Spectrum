//
//  MatrixOuput.h
//  MFCCDemo
//
//  Created by Hai Le on 10/6/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MatrixOuput : UIView

- (void)inputNormalizedDataW:(int)w matrixH:(int)h data:(float**)data rect:(CGRect)rect maxVal:(float)maxVal;
- (void)inputFitQualityW:(int)w data:(float*)data rect:(CGRect)rect maxVal:(float)maxVal;

@end
