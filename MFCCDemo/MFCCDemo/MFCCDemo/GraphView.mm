//
//  GraphView.m
//  MFCCDemo
//
//  Created by Hai Le on 11/23/15.
//  Copyright © 2015 Hai Le. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView {
    FeatureTypeDTW::Features _feature;
    std::vector<float> _normalisedData;
    float _max;
    float _min;
    int _start, _end;
}

- (void)inputMFCC:(FeatureTypeDTW::Features)feature start:(int)start end:(int)end {
    _feature = feature;
    _start = start;
    _end = end;
    
    // Init Normalised Vector
    _normalisedData.clear();
    _normalisedData.resize(feature.size());
    
    // Finding max & calculating normalised data
    _max = 0.0f;
    for (int j = 0; j<feature.size(); j++) {
        float sum = 0;
        for (int k = 0; k<12; k++) {
            sum += fabsf(feature[j][k]);
            if (feature[j][k] > _max) {
                _max = feature[j][k];
            }
            if (feature[j][k] < _min) {
                _min = feature[j][k];
            }
        }
        sum /= 12;
        
        _normalisedData[j] = sum;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (_feature.size() > 0) {
        
        float maxH = 0.0;
        float sectionH = self.bounds.size.height/12;
        for (float k = 0; k < 12.0; k++) {
            maxH += sectionH;
            UIBezierPath *aPath = [UIBezierPath bezierPath];
            [aPath moveToPoint:CGPointMake(0.0, maxH)];
            for (int i = 0; i<_feature.size(); i++) {
                [aPath addLineToPoint:CGPointMake(i, maxH-((_feature[i][k]-_min)/(_max-_min)*sectionH))];
            }
            [aPath moveToPoint:CGPointMake((_feature.size()-1), maxH-((_feature[(_feature.size()-1)][k]-_min)/(_max-_min)*sectionH))];
            [aPath closePath];
            [[UIColor colorWithRed:k/12.0f green:1-(k/12.0f) blue:.5f alpha:1] setStroke];
            [aPath stroke];
        }
        
        if (_start != 0 && _end != 0) {
            CGRect start = CGRectMake(0.0f, 0.0f, _start, self.bounds.size.height);
            [[UIColor colorWithWhite:0.2f alpha:0.2f] setFill];
            UIRectFillUsingBlendMode(start, kCGBlendModeNormal);
            NSLog(@"%d %d",_start, _end);
            
            CGRect end = CGRectMake(_end,
                                    0.0f,
                                    self.bounds.size.width-_end,
                                    self.bounds.size.height);
            [[UIColor colorWithWhite:0.2f alpha:0.2f] setFill];
            UIRectFillUsingBlendMode(end, kCGBlendModeNormal);
        }
    }
}

@end
