//
//  LPCView.h
//  Spectrum
//
//  Created by Hai Le on 29/9/14.
//  Copyright (c) 2014 Earthling Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LPCDelegate;

@interface LPCView : UIView

@property (nonatomic,assign) id<LPCDelegate> delegate;
@property (nonatomic,assign) BOOL shouldFillColor;
@property (nonatomic,assign) BOOL isRecordMode;

- (void)startDrawing;
- (void)stopDrawing;
- (void)saveData;
- (void)clearData;
- (double)getDataAtIndex:(int)index;
- (double)getPlotDataAtIndex:(int)index;
- (double)getSaveDataAtIndex:(int)index;
- (NSArray *)getArrayDataAtIndex:(int)index;
- (void)loadData:(double *)data;
@end

@protocol LPCDelegate <NSObject>

@optional
- (void)calculateDidFinish;

@end
