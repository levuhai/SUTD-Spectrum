//
//  LPCView.m
//  Spectrum
//
//  Created by Hai Le on 29/9/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import "LPCView.h"
#import "LPCAudioController.h"
#import "ViewFrameAccessor.h"
#import <complex.h>
#include <math.h>
#import "NSMutableArray+Queue.h"
#import "UIColor+Flat.h"

#define kTopPadding 10
#define kBottomPadding 10

@interface LPCView () {
    LPCAudioController *lpcController;
    double* _savedData;
    double* _plotData;
    BOOL _isPractising;
}

@end

@implementation LPCView
{
    int decimatedEndIdx;
    int truncatedStartIdx, truncatedEndIdx;
    int strongStartIdx, strongEndIdx;
    short int *dataBuffer;
    int dataBufferLength;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        lpcController = [LPCAudioController sharedInstance];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // Setup LPC
        [[LPCAudioController sharedInstance] start];
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)saveData {
    [self clearSavedData];
    
    int bufferSize = lpcController.width;
    _savedData = new double[bufferSize];
    // Copy the buffer
    memcpy(_savedData,
           _plotData,
           (size_t)bufferSize*sizeof(double));
}

- (void)clearSavedData {
    if( _savedData != NULL ){
        delete []_savedData;
        _savedData = NULL;
    }
}



- (void)refresh
{
    //if (lpcController->drawing) {
    [self setNeedsDisplay];
    //}
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGPoint startPoint, endPoint;
    UIColor* lineColor;
    double maxFreqResp, minFreqResp, freqRespScale;
    float graphHeight = self.height - kBottomPadding;
    
    // =================================================================
    // DRAW VERTICAL LINES
    // Draw four dashed vertical lines at 1kHz, 2kHz, 3kHz, and 4 kHz.
//    CGFloat dashPattern[2];
//    lineColor = [[UIColor silverColor] colorWithAlphaComponent:0.8];
//    
//    dashPattern[0] = 3.0;
//    dashPattern[1] = 3.0;
//    CGContextSetLineWidth(ctx, 1);
//    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
//    
//    for (int k=1; k<5; k++) {
//        CGContextMoveToPoint(ctx, self.width/5*k - 1, 0);
//        CGContextAddLineToPoint(ctx, self.width/5*k - 1, self.height);
//        CGContextStrokePath(ctx);
//    }
    
    // =================================================================
    // DRAW SAVED GRAPH
    // Now plot the frequency response
    if (_savedData != NULL) {
        // Drawing code
        UIBezierPath *pathSave = [UIBezierPath
                              bezierPath];
        CGPoint startPoint, endPoint;
        double maxFreqResp, minFreqResp, freqRespScale;
        maxFreqResp = -100.0;
        minFreqResp = 100.0;
        
        for (int degIdx = 0; degIdx < lpcController.width; degIdx++) {
            maxFreqResp = MAX(maxFreqResp, _savedData[degIdx]);
            minFreqResp = MIN(minFreqResp, _savedData[degIdx]);
        }
        
        freqRespScale = graphHeight / (maxFreqResp - minFreqResp);
        
        lineColor = [UIColor colorFromHexCode:@"f1c40f"];
        CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        startPoint = CGPointMake(0, graphHeight-freqRespScale*(_savedData[0]-minFreqResp)+kTopPadding);
        [pathSave moveToPoint:CGPointMake(0, self.y + self.height)];
        for (int chunkIdx=0; chunkIdx<self.width; chunkIdx++) {
            endPoint = CGPointMake(chunkIdx, graphHeight-freqRespScale*(_savedData[chunkIdx]-minFreqResp)+kTopPadding);
            if (std::isnan(startPoint.y)) {
                startPoint.y = 0;
            }
            if (std::isnan(endPoint.y)) {
                endPoint.y = 0;
            }
            CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
            startPoint = endPoint;
            [pathSave addLineToPoint:endPoint];
        }
        [pathSave addLineToPoint:CGPointMake(self.x + self.width, self.y+self.height)];
        [pathSave addLineToPoint:CGPointMake(0, self.y + self.height)];
        if (_shouldFillColor) {
            UIColor *fillColor = [[UIColor colorFromHexCode:@"e74c3c"] colorWithAlphaComponent:0.5];
            [fillColor setFill];
            [pathSave fill];
        }
        
        CGContextStrokePath(ctx);
        
    } else {
        // get plot data from audio controller
        _plotData = lpcController->plotData;
        
        // =================================================================
        // DRAW REAL-TIME GRAPH
        // Now plot the frequency response
        UIBezierPath *pathRealTime = [UIBezierPath
                                  bezierPath];
        maxFreqResp = -100.0;
        minFreqResp = 100.0;
        
        for (int degIdx = 0; degIdx < lpcController.width; degIdx++) {
            maxFreqResp = MAX(maxFreqResp, _plotData[degIdx]);
            minFreqResp = MIN(minFreqResp, _plotData[degIdx]);
        }
        
        freqRespScale = graphHeight / (maxFreqResp - minFreqResp);
        
        lineColor = [UIColor colorFromHexCode:@"99FF00"];
        CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
        CGContextSetLineWidth(ctx, 2.0);
        
        startPoint = CGPointMake(0, graphHeight-freqRespScale*(_plotData[0]-minFreqResp)+kTopPadding);
    //    startPoint = CGPointMake(0, self.y + self.height);
        [pathRealTime moveToPoint:CGPointMake(0, self.y + self.height)];
        for (int chunkIdx=0; chunkIdx<self.width; chunkIdx++) {
            endPoint = CGPointMake(chunkIdx, graphHeight-freqRespScale*(_plotData[chunkIdx] - minFreqResp)+kTopPadding);
            if (std::isnan(startPoint.y)) {
                startPoint.y = self.height;
            }
            if (std::isnan(endPoint.y)) {
                endPoint.y = self.height;
            }
            CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
            [pathRealTime addLineToPoint:endPoint];
            startPoint = endPoint;
        }
        [pathRealTime addLineToPoint:CGPointMake(self.x + self.width, self.y + self.height)];
        [pathRealTime addLineToPoint:CGPointMake(0, self.y + self.height)];
        if (_shouldFillColor) {
            UIColor *fillColor = [[UIColor colorFromHexCode:@"1abc9c"] colorWithAlphaComponent:0.6];
            [fillColor setFill];
            [pathRealTime fill];
        }
        CGContextStrokePath(ctx);
        lpcController->needReset = YES;
    }
}

- (NSArray *)currentRawData {
    return [self _toNSArray:_plotData];
}

- (double)currentPlotDataAtIndex:(int)index {
    float graphHeight = self.height - kBottomPadding;
    double maxFreqResp, minFreqResp, freqRespScale;
    maxFreqResp = -100.0;
    minFreqResp = 100.0;
    
    for (int degIdx = 0; degIdx < lpcController.width; degIdx++) {
        maxFreqResp = MAX(maxFreqResp, _plotData[degIdx]);
        minFreqResp = MIN(minFreqResp, _plotData[degIdx]);
    }
    
    freqRespScale = graphHeight / (maxFreqResp - minFreqResp);
    double returnValue = graphHeight-freqRespScale*(_plotData[index]-minFreqResp)+kTopPadding;
    return returnValue;
}

- (double)savedPlotDataAtIndex:(int)index{
    float graphHeight = self.height - kBottomPadding;
    double maxFreqResp, minFreqResp, freqRespScale;
    maxFreqResp = -100.0;
    minFreqResp = 100.0;
    
    for (int degIdx = 0; degIdx < lpcController.width; degIdx++) {
        maxFreqResp = MAX(maxFreqResp, _savedData[degIdx]);
        minFreqResp = MIN(minFreqResp, _savedData[degIdx]);
    }
    
    freqRespScale = graphHeight / (maxFreqResp - minFreqResp);
    double returnValue = graphHeight-freqRespScale*(_savedData[index] - minFreqResp)+kTopPadding;
    return returnValue;
}
- (void)loadData:(double *)data{
    if (data) {
        int bufferSize = lpcController.width;
        if( _savedData != NULL ){
            delete []_savedData;
            _savedData = NULL;
        }
        _savedData = new double[bufferSize];
        // Copy the buffer
        memcpy(_savedData,
               data,
               (size_t)bufferSize*sizeof(double));
    }else{
        _savedData = nil;
    }
    
}
- (NSArray *)_toNSArray:(double *)data {
    
    NSMutableArray * arrayData = [[NSMutableArray alloc]init];
    for(int i = 0; i<lpcController.width ;i++){
        double b = data[i];
        [arrayData addObject:[NSNumber numberWithDouble:b]];
    }
    return [arrayData copy];
}

#pragma mark - LPC

@end
