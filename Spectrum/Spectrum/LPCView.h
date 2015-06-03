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

- (void)startDrawing;
- (void)stopDrawing;
- (void)saveGraph;
- (double)getDataAtIndex:(int)index;
- (void)setPractise:(BOOL)enable;
- (void)loadData:(double *)data;
@end

@protocol LPCDelegate <NSObject>

@optional
- (void)calculateDidFinish;

@end
