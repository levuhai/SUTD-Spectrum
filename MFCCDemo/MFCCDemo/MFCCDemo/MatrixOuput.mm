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
    std::vector< std::vector<float> > _dataV;
    std::vector<float> _fitDataV;
    float _paddingLeft;
    CGRect _frameRect;
    int _size;
    float _maxVal;
    BOOL _drawFit;
}

- (void)awakeFromNib {
    _graphColor = [UIColor redColor];
}

- (void)inputNormalizedDataW:(int)w
                     matrixH:(int)h
                        data:(std::vector< std::vector<float> >)data
                        rect:(CGRect)rect
                      maxVal:(float)maxVal {
    _w = w;
    _h = h;
    _dataV = data;
    _frameRect = rect;
    _size = 1;
    _maxVal = maxVal;
    _drawFit = NO;
    
    [self setNeedsDisplay];
}

- (void)inputFitQualityW:(int)w data:(std::vector<float>)data rect:(CGRect)rect maxVal:(float)maxVal {
    _w = w;
    _fitDataV = data;
    _size = w==0?1:MAX((int)rect.size.width / w, 1);
    _maxVal = maxVal;
    _drawFit = YES;
   
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if (!_drawFit) {
        _size = MAX(self.bounds.size.width/_w, 1);
        // Drawing code
        for (int i = 0; i <_h; i++) {
            for (int j = 0; j<_w; j++) {
                float temp = _dataV[i][j]/_maxVal;
                CGRect rectangle = CGRectMake(j*_size, i*_size , _size, _size);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
                [_graphColor getRed:&red green:&green blue:&blue alpha:&alpha];
                CGContextSetRGBFillColor(context, red, green, blue, 0.1 + temp);   //this is the transparent color
                CGContextFillRect(context, rectangle);
            }
        }
    } else {
        float maxH = self.bounds.size.height - 20;
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        [aPath moveToPoint:CGPointMake(0.0, maxH)];
        for (int i = 0; i<_w; i++) {
            [aPath addLineToPoint:CGPointMake(i*_size, maxH-(_fitDataV[i]/_maxVal*maxH)+10)];
        }
        [aPath moveToPoint:CGPointMake((_w-1)*_size, maxH-(_fitDataV[(_w-1)]/_maxVal*maxH)+10)];
        [aPath closePath];
        [_graphColor setStroke];
        [aPath stroke];
    }
}


@end
