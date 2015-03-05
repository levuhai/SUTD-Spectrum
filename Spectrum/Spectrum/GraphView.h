//
//  GraphView.h
//  Spectrum
//
//  Created by Hai Le on 28/6/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZAudio/EZAudio.h>

@interface GraphView : UIView

@property (nonatomic, strong) NSMutableArray *dataLow;
@property (nonatomic, strong) NSMutableArray *dataBand;
@property (nonatomic, strong) NSMutableArray *dataHigh;

- (void)addLowPass:(float)low bandPass:(float)band highPass:(float)high;
- (void)saveData;

@end
