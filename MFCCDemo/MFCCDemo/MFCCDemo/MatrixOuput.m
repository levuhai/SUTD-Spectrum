//
//  MatrixOuput.m
//  MFCCDemo
//
//  Created by Hai Le on 10/6/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "MatrixOuput.h"


@implementation MatrixOuput {
    int _w;
    int _h;
    float** _data;
    float* _fitData;
    float _paddingLeft;
    CGRect _frameRect;
    int _size;
    float _maxVal;
    BOOL _drawFit;
}

- (void)inputNormalizedDataW:(int)w matrixH:(int)h data:(float**)data rect:(CGRect)rect maxVal:(float)maxVal {
    _w = w;
    _h = h;
    _data = data;
    _frameRect = rect;
    _size = MAX((int)rect.size.height / 2/h, 1);
    _maxVal = maxVal;
    _drawFit = NO;
}

- (void)inputFitQualityW:(int)w data:(float *)data rect:(CGRect)rect maxVal:(float)maxVal {
    _w = w;
    _fitData = data;
    _size = MAX((int)rect.size.width / w, 1);
    _maxVal = maxVal;
    _drawFit = YES;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (!_drawFit) {
        _size = MAX(self.bounds.size.width/_w, 1);
        // Drawing code
        for (int i = 0; i <_h; i++) {
            for (int j = 0; j<_w; j++) {
                float temp = _data[i][j]/_maxVal;
                CGRect rectangle = CGRectMake(j*_size, i*_size , _size, _size);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 0.1 + temp);   //this is the transparent color
                CGContextFillRect(context, rectangle);
            }
        }
    } else {
        float maxH = self.bounds.size.height - 20;
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        [aPath moveToPoint:CGPointMake(0.0, maxH)];
        for (int i = 0; i<_w; i++) {
            [aPath addLineToPoint:CGPointMake(i*_size, maxH-(_fitData[i]/_maxVal*maxH)+10)];
        }
        [aPath moveToPoint:CGPointMake((_w-1)*_size, maxH-(_fitData[(_w-1)]/_maxVal*maxH)+10)];
        [aPath closePath];
        [[UIColor redColor] setStroke];
        [aPath stroke];
    }
}


@end
