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

- (void)refresh;
- (NSArray*)currentRawData;
- (double)currentPlotDataAtIndex:(int)index;
- (double)savedPlotDataAtIndex:(int)index;

- (void)saveData;
- (void)clearSavedData;
- (void)loadData:(double *)data;
@end

@protocol LPCDelegate <NSObject>

@optional
- (void)calculateDidFinish;

@end
