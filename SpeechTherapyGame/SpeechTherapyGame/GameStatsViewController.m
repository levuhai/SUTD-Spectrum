//
//  GameStatsViewController.m
//  SpeechTherapyGame
//
//  Created by Vit on 9/23/15.
//  Copyright © 2015 SUTD. All rights reserved.
//

#import "GameStatsViewController.h"
#import "ActionSheetPicker.h"
#import "Games.h"
#import "Sounds.h"
#import "GameStatistics.h"



@interface GameStatsViewController () <GKLineGraphDataSource, GKBarGraphDataSource>
{
    GKLineGraph* _lGraph;
    GKBarGraph* _bGraph;
    NSMutableArray* _lineBottomLabels;
    NSMutableArray* _barBottomLabels;
}

@end

@implementation GameStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(47,139,193);
    
    _lineBottomLabels = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7"];
    self.lineGraphData = @[ @[@20, @40, @20, @60, @40, @140, @80] ];
    
//    _barBottomLabels = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g"];
    _barBottomLabels = [NSMutableArray array];
    self.barGraphData = [NSMutableArray array];
    
    NSArray* gameStatData = [GameStatistics MR_findAllSortedBy:@"statId" ascending:NO];
    for (GameStatistics* gs in gameStatData) {
        if (![_barBottomLabels containsObject:[gs.statistics allKeys][0]]) {
            [_barBottomLabels addObject:[gs.statistics allKeys][0]];
        }
    }
    
    for (NSString* letter in _barBottomLabels) {
        NSInteger sum = 0;
        NSInteger incorrect = 0;
        for (GameStatistics* gs in gameStatData) {
            if ([[gs.statistics allKeys][0] isEqualToString:letter]) {
                sum = sum + [[[gs.statistics valueForKey:letter] valueForKey:@"total"] integerValue];
                incorrect = incorrect + [[[gs.statistics valueForKey:letter] valueForKey:@"incorrect"] integerValue];
            }
        }
        
        [self.barGraphData addObject:@(((sum - incorrect) / (float)sum) * 100)];
        
    }
    
    
    // Line graph
    _lGraph = [[GKLineGraph alloc] initWithFrame:CGRectMake(0, 100 - 30, self.view.width, self.lineGraphContainer.height - 100)];
    _lGraph.backgroundColor = [UIColor clearColor];
    _lGraph.dataSource = self;
    _lGraph.lineWidth = 8.0;
    _lGraph.valueLabelCount = 3;
    _lGraph.margin = 40;
    [self.lineGraphContainer addSubview:_lGraph];
    self.lineGraphContainer.layer.cornerRadius = 10;
    
    // Bar graph
    
    
    _bGraph = [[GKBarGraph alloc] initWithFrame:CGRectMake(0, 90 - 30, self.barGraphContainer.width, self.barGraphContainer.height - 90)];
    _bGraph.dataSource = self;
    _bGraph.backgroundColor = [UIColor clearColor];
    _bGraph.barWidth = 50;
    _bGraph.barHeight = 200;
    _bGraph.marginBar = 70;
    _bGraph.animationDuration = 2.0;
    
    _bGraph.centerX = self.barGraphContainer.width/2 - 40;
    [self.barGraphContainer addSubview:_bGraph];
    self.barGraphContainer.layer.cornerRadius = 10;
}

- (void)fetchData {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_lGraph draw];
    [_bGraph draw];
}

#pragma mark - GKLineGraphDataSource

- (NSInteger)numberOfLines {
    return [self.lineGraphData count];
}

- (UIColor *)colorForLineAtIndex:(NSInteger)index {
    id colors = @[[UIColor gk_turquoiseColor],
                  [UIColor gk_peterRiverColor],
                  [UIColor gk_alizarinColor],
                  [UIColor gk_sunflowerColor]
                  ];
    return [colors objectAtIndex:index];
}

- (NSArray *)valuesForLineAtIndex:(NSInteger)index {
    return [self.lineGraphData objectAtIndex:index];
}

- (NSString *)titleForLineAtIndex:(NSInteger)index {
    return  [_lineBottomLabels objectAtIndex:index];
}


#pragma mark - GKBarGraphDataSource

- (NSInteger)numberOfBars {
    return [self.barGraphData count];
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return [self.barGraphData objectAtIndex:index];
}

- (UIColor *)colorForBarAtIndex:(NSInteger)index {
    id colors = @[[UIColor gk_turquoiseColor],
                  [UIColor gk_peterRiverColor],
                  [UIColor gk_alizarinColor],
                  [UIColor gk_amethystColor],
                  [UIColor gk_emerlandColor],
                  [UIColor gk_sunflowerColor],
                  [UIColor gk_belizeHoleColor]
                  ];
    return [colors objectAtIndex:index];
}

- (UIColor *)colorForBarBackgroundAtIndex:(NSInteger)index {
    return [UIColor whiteColor];
}

- (CFTimeInterval)animationDurationForBarAtIndex:(NSInteger)index {
    CGFloat percentage = [[self valueForBarAtIndex:index] doubleValue];
    percentage = (percentage / 100);
    return (_bGraph.animationDuration * percentage);
}

- (NSString *)titleForBarAtIndex:(NSInteger)index {
    return [_barBottomLabels objectAtIndex:index];
}


#pragma mark - Action methods
- (IBAction) timeRange_pressed:(id)sender {
    NSArray *rangeData = [NSArray arrayWithObjects:@"Last 7 days", @"Last 2 weeks", @"Last month", @"All time", nil];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Date ranges"
                                            rows:rangeData
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [(UIButton*)sender setTitle:selectedValue forState:UIControlStateNormal];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     }
                                          origin:sender];
}



@end
