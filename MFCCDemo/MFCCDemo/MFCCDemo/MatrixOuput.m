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
    float _paddingLeft;
    CGRect _frameRect;
    int _size;
    float _maxVal;
}

- (void)inputMatrixW:(int)w matrixH:(int)h data:(float**)data rect:(CGRect)rect maxVal:(float)maxVal {
    _w = w;
    _h = h;
    _data = data;
    _frameRect = rect;
    _size = MAX((int)rect.size.width / w, 1);
    _maxVal = maxVal;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
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
    
}


@end
