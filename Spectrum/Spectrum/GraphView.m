//
//  GraphView.m
//  Spectrum
//
//  Created by Hai Le on 28/6/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import "GraphView.h"
#import "UIColor+Flat.h"
#import "AudioController.h"
#import "FrameAccessor.h"
#import "NSMutableArray+QueueStack.h"

@implementation GraphView {
    UInt32   _plotLength;
    UInt32   _plotMaxLength;
    
    UIBezierPath *_pathLP;
    UIBezierPath *_pathBP;
    UIBezierPath *_pathHP;
    
    UIBezierPath *_pathSavedLP;
    UIBezierPath *_pathSavedBP;
    UIBezierPath *_pathSavedHP;
    
    float _lastLow, _lastBand, _lastHigh;
    float _savedLow, _savedBand, _savedHigh;
    float _smooth;
    
    BOOL _isDrawing;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

#pragma mark - Public Category
- (void)saveData {
    float avgL=0, avgB=0, avgH=0;
    for (int i = 0; i < 15; i++) {
        avgL += [_dataLow[0] floatValue];
        avgB += [_dataBand[0] floatValue];
        avgH += [_dataHigh[0] floatValue];
    }
    _savedBand = avgB/15;
    _savedHigh = avgH/15;
    _savedLow = avgL/15;
}

- (void)addLowPass:(float)low bandPass:(float)band highPass:(float)high {
    if (_isDrawing == NO) {
        // Start drawing
        _isDrawing = YES;
        
        low *= 1;
        band *= 1;
        high *= 1;
        
        low = _smooth * low + (1.0 - _smooth) * _lastLow;
        _lastLow = low;
        
        band = _smooth * band + (1.0 - _smooth) * _lastBand;
        _lastBand = band;
        
        high = _smooth * high + (1.0 - _smooth) * _lastHigh;
        _lastHigh = high;
        
        // Data Lowpass FIFO
        if (self.dataLow.count >= _plotMaxLength) {
            [self.dataLow stackPop];
        }
        [self.dataLow stackPush:[NSNumber numberWithFloat:low]];
        
        // Data Bandpass FIFO
        if (self.dataBand.count >= _plotMaxLength) {
            [self.dataBand stackPop];
        }
        [self.dataBand stackPush:[NSNumber numberWithFloat:low+band]];
        
        // Data Highpass FIFO
        if (self.dataHigh.count >= _plotMaxLength) {
            [self.dataHigh stackPop];
        }
        [self.dataHigh stackPush:[NSNumber numberWithFloat:low+band+high]];
        
        // Plot lenght
        _plotLength = (UInt32)self.dataHigh.count;
        
        [_pathHP removeAllPoints];
        [_pathBP removeAllPoints];
        [_pathLP removeAllPoints];
        
        [_pathHP moveToPoint:CGPointMake(0, self.height)];
        [_pathBP moveToPoint:CGPointMake(0, self.height)];
        [_pathLP moveToPoint:CGPointMake(0, self.height)];
        
        for (int k = 0; k < _plotLength; k += 1) {
            [_pathHP addLineToPoint:CGPointMake(k, -[_dataHigh[k] floatValue]+self.height)];
            
            [_pathBP addLineToPoint:CGPointMake(k, -[_dataBand[k] floatValue]+self.height)];
            
            [_pathLP addLineToPoint:CGPointMake(k, -[_dataLow[k] floatValue]+self.height)];
            
        }
        [_pathHP addLineToPoint:CGPointMake(_plotLength, self.height)];
        [_pathHP closePath];
        
        [_pathBP addLineToPoint:CGPointMake(_plotLength, self.height)];
        [_pathBP closePath];
        
        [_pathLP addLineToPoint:CGPointMake(_plotLength, self.height)];
        [_pathLP closePath];
        
        if (_savedBand > 0 || _savedLow > 0 || _savedBand > 0) {
            [_pathSavedLP removeAllPoints];
            [_pathSavedLP moveToPoint:CGPointMake(0, self.height)];
            [_pathSavedLP addLineToPoint:CGPointMake(0, -_savedLow+self.height)];
            [_pathSavedLP addLineToPoint:CGPointMake(_plotLength, -_savedLow+self.height)];
            [_pathSavedLP addLineToPoint:CGPointMake(_plotLength, self.height)];
            [_pathSavedLP closePath];
            
            [_pathSavedBP removeAllPoints];
            [_pathSavedBP moveToPoint:CGPointMake(0, -_savedLow+self.height)];
            [_pathSavedBP addLineToPoint:CGPointMake(0, -_savedBand+self.height)];
            [_pathSavedBP addLineToPoint:CGPointMake(_plotLength, -_savedBand+self.height)];
            [_pathSavedBP addLineToPoint:CGPointMake(_plotLength, -_savedLow+self.height)];
            [_pathSavedBP closePath];
            
            [_pathSavedHP removeAllPoints];
            [_pathSavedHP moveToPoint:CGPointMake(0, -_savedBand+self.height)];
            [_pathSavedHP addLineToPoint:CGPointMake(0, -_savedHigh+self.height)];
            [_pathSavedHP addLineToPoint:CGPointMake(_plotLength, -_savedHigh+self.height)];
            [_pathSavedHP addLineToPoint:CGPointMake(_plotLength, -_savedBand+self.height)];
            [_pathSavedHP closePath];
        }
    }
}

#pragma mark - Private Category

- (void)_init {
    _smooth = 0.6;
    // Create low pass history buffer
    _plotMaxLength = self.width;
    
    self.dataLow = [[NSMutableArray alloc] initWithCapacity:_plotMaxLength];
    self.dataBand = [[NSMutableArray alloc] initWithCapacity:_plotMaxLength];
    self.dataHigh = [[NSMutableArray alloc] initWithCapacity:_plotMaxLength];
    
    _pathLP = [UIBezierPath bezierPath];
    _pathBP = [UIBezierPath bezierPath];
    _pathHP = [UIBezierPath bezierPath];
    
    _pathSavedLP = [UIBezierPath bezierPath];
    _pathSavedBP = [UIBezierPath bezierPath];
    _pathSavedHP = [UIBezierPath bezierPath];
    
    _isDrawing = NO;
    
    _savedLow = -1;
    _savedHigh = -1;
    _savedBand = -1;
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Draw saved rect
    if (_savedBand > 0 || _savedLow > 0 || _savedBand > 0) {
        [[[AudioController sharedInstance] highPassGraphColor] setStroke];
        [_pathSavedHP stroke];
        [[[AudioController sharedInstance].highPassGraphColor colorWithAlphaComponent:0.3] setFill];
        [_pathSavedHP fill];
        
        [[AudioController sharedInstance].bandPassGraphColor setStroke];
        [_pathSavedBP stroke];
        [[[AudioController sharedInstance].bandPassGraphColor colorWithAlphaComponent:0.3] setFill];
        [_pathSavedBP fill];
        
        [[[AudioController sharedInstance] lowPassGraphColor] setStroke];
        [_pathSavedLP stroke];
        [[[[AudioController sharedInstance] lowPassGraphColor] colorWithAlphaComponent:0.3] setFill];
        [_pathSavedLP fill];
    }
    
    // Drawing code
    // HIGH PASS
    [[[AudioController sharedInstance] highPassGraphColor] setFill];
    [_pathHP fill];
    
    [[[AudioController sharedInstance] bandPassGraphColor] setFill];
    [_pathBP fill];
    
    [[[AudioController sharedInstance] lowPassGraphColor] setFill];
    [_pathLP fill];
    
    
    
    
    
    _isDrawing = NO;
}


@end
