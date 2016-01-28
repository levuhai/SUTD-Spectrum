//
//  LPCNode.m
//  SpeechTherapyGame
//
//  Created by Hai Le on 1/28/16.
//  Copyright © 2016 SUTD. All rights reserved.
//

#import "LPCNode.h"
#import "LPCAudioController.h"

@implementation LPCNode {
    LPCAudioController *_lpcController;
//    SKShapeNode *_lineNode;
    CGMutablePathRef _pathToDraw;
    double* _plotData;
    
    int decimatedEndIdx;
    int truncatedStartIdx, truncatedEndIdx;
    int strongStartIdx, strongEndIdx;
    short int *dataBuffer;
    int dataBufferLength;
}

//- (id)initWithColor:(UIColor *)color size:(CGSize)size {
//    self = [super initWithColor:color size:size];
//    if (self) {
//        //[self _init];
//    }
//    return self;
//}
//
//- (id)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        //[self _init];
//    }
//    return self;
//}

- (void)setupWithSize:(CGSize)size {
    _size = size;
    _lpcController = [[LPCAudioController alloc] initWithSize:self.size];
    _lpcController.width = self.size.width;
    _lpcController.height = self.size.height;
    [_lpcController start];
    
    //_lineNode = [SKShapeNode node];
    [self setStrokeColor:[UIColor flatYellowColor]];
    //[self addChild:_lineNode];
}

- (void)draw {
    // Release path
    CGPathRelease(_pathToDraw);
    _pathToDraw = CGPathCreateMutable();
    
    CGPoint endPoint;
    double maxFreqResp, minFreqResp, freqRespScale;
    float gHeight = self.size.height;
    float gWidth = self.size.width;
    
    // get plot data from audio controller
    _plotData = _lpcController->plotData;
    
    // =================================================================
    // DRAW REAL-TIME GRAPH
    // Now plot the frequency response
    maxFreqResp = -100.0;
    minFreqResp = 100.0;
    
    for (int degIdx = 0; degIdx < _lpcController.width; degIdx++) {
        maxFreqResp = MAX(maxFreqResp, _plotData[degIdx]);
        minFreqResp = MIN(minFreqResp, _plotData[degIdx]);
    }
    
    freqRespScale = gHeight / (maxFreqResp - minFreqResp);
    
    endPoint = CGPointMake(0, freqRespScale*(_plotData[0]-minFreqResp));
    //    startPoint = CGPointMake(0, self.y + self.height);
    CGPathMoveToPoint(_pathToDraw, NULL, endPoint.x, endPoint.y);
    for (int chunkIdx=0; chunkIdx < gWidth; chunkIdx++) {
        endPoint = CGPointMake(chunkIdx, freqRespScale*(_plotData[chunkIdx] - minFreqResp));
        if (std::isnan(endPoint.y)) {
            endPoint.y = 0;
        }

        //CGPathMoveToPoint(pathRealTime, NULL, startPoint.x, startPoint.y);
        CGPathAddLineToPoint(_pathToDraw, NULL, endPoint.x, endPoint.y);
    }
    //CGPathAddLineToPoint(_pathToDraw, NULL, gWidth, endPoint.y);

    self.path = _pathToDraw;
    // Reset controller
    _lpcController->needReset = YES;
}

@end
