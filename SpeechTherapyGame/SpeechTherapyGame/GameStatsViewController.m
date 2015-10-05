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
    
    NSArray* _gameStatData;
    NSMutableArray* _lineBottomLabels;
    NSMutableArray* _barBottomLabels;
    
    IBOutlet UIButton* _playedTimeButton;
    IBOutlet UIButton* _pointButton;
}

@end

@implementation GameStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(47,139,193);
    
    _gameStatData = [GameStatistics MR_findAllSortedBy:@"statId" ascending:NO];
    [self loadDataForPlayedTimeLineChart:_gameStatData];
    [self loadDataForWordsBarChart:_gameStatData];
    
    
    
    // Line graph
    _lGraph = [[GKLineGraph alloc] initWithFrame:CGRectMake(0, 100 - 30, self.view.width, _lineGraphContainer.height - 100)];
    _lGraph.backgroundColor = [UIColor clearColor];
    _lGraph.dataSource = self;
    _lGraph.lineWidth = 8.0;
    _lGraph.valueLabelCount = 3;
    _lGraph.margin = 40;
    [_lineGraphContainer addSubview:_lGraph];
    _lineGraphContainer.layer.cornerRadius = 10;
    
    // Bar graph
    
    
    _bGraph = [[GKBarGraph alloc] initWithFrame:CGRectMake(0, 90 - 30, _barGraphContainer.width, _barGraphContainer.height - 90)];
    _bGraph.dataSource = self;
    _bGraph.backgroundColor = [UIColor clearColor];
    _bGraph.barWidth = 50;
    _bGraph.barHeight = 200;
    _bGraph.marginBar = 70;
    _bGraph.animationDuration = 2.0;
    
    _bGraph.centerX = _barGraphContainer.width/2 - 40;
    [_barGraphContainer addSubview:_bGraph];
    _barGraphContainer.layer.cornerRadius = 10;
    
    
    [self enableButton:_pointButton];
    [self disableButton:_playedTimeButton];
}

- (void)fetchData {
    
}

- (void) loadDataForPlayedTimeLineChart:(NSArray*)gameStatData {
    _lineBottomLabels = nil;
    _lineGraphData = nil;
    
    _lineBottomLabels = [NSMutableArray array];
    _lineGraphData = [NSMutableArray array];
    
    NSMutableArray* tmpLineDate = [NSMutableArray array];
    for (GameStatistics* gs in gameStatData) {
        
        [tmpLineDate addObject:[NSNumber numberWithInteger:arc4random_uniform(100)]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE"];
        NSString *dateString = [dateFormatter stringFromDate:gs.dateAdded];
        
        [_lineBottomLabels addObject:dateString];
    }
    
    
    [_lineGraphData addObject:tmpLineDate];
}

- (void) loadDataForPointsLineChart:(NSArray*)gameStatData {
    _lineBottomLabels = nil;
    _lineGraphData = nil;
    
    _lineBottomLabels = [NSMutableArray array];
    _lineGraphData = [NSMutableArray array];
    
    NSMutableArray* tmpLineDate = [NSMutableArray array];
    for (GameStatistics* gs in gameStatData) {
        [tmpLineDate addObject:@([GameStatistics getPointsFrom:(NSDictionary*)gs.statistics])];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE"];
        NSString *dateString = [dateFormatter stringFromDate:gs.dateAdded];
        
        [_lineBottomLabels addObject:dateString];
    }
    [_lineGraphData addObject:tmpLineDate];
}

- (void) loadDataForWordsBarChart:(NSArray*) gameStatData {
    _barBottomLabels = nil;
    _barGraphData = nil;
    _barBottomLabels = [NSMutableArray array];
    _barGraphData = [NSMutableArray array];
    
    for (GameStatistics* gs in gameStatData) {
        
        if (![_barBottomLabels containsObject:[gs.statistics allKeys][0]]) {
            [_barBottomLabels addObject:[gs.statistics allKeys][0]];
        }
    }
    
    
    for (NSString* letter in _barBottomLabels) {
        NSInteger sum = 0;
        NSInteger incorrect = 0;
        for (GameStatistics* gs in gameStatData) {
            
            if (![_barBottomLabels containsObject:[gs.statistics allKeys][0]]) {
                [_barBottomLabels addObject:[gs.statistics allKeys][0]];
            }
            
            if ([[gs.statistics allKeys][0] isEqualToString:letter]) {
                sum = sum + [[[gs.statistics valueForKey:letter] valueForKey:@"total"] integerValue];
                incorrect = incorrect + [[[gs.statistics valueForKey:letter] valueForKey:@"incorrect"] integerValue];
            }
        }
        [_barGraphData addObject:@(((sum - incorrect) / (float)sum) * 100)];
    }
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

-(IBAction) playedTimeButton_action {
    [self enableButton:_playedTimeButton];
    [self disableButton:_pointButton];
    // Reload data
//    [_lGraph reset];
//    [self loadDataForPlayedTimeLineChart:_gameStatData];
//    [_lGraph draw];
}

-(IBAction) pointButton_action {
    [self enableButton:_pointButton];
    [self disableButton:_playedTimeButton];
    // Reload data
//    [_lGraph reset];
//    [self loadDataForPointsLineChart:_gameStatData];
//    [_lGraph draw];
}

- (void) enableButton:(UIButton*) button {
    button.backgroundColor = RGB(47,139,193);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void) disableButton:(UIButton*) button {
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:RGB(47,139,193) forState:UIControlStateNormal];
}

#pragma mark - GKLineGraphDataSource

- (NSInteger)numberOfLines {
    return [_lineGraphData count];
}

- (UIColor *)colorForLineAtIndex:(NSInteger)index {
    id colors = @[ RGB(47,139,193) ];
    return [colors objectAtIndex:index];
}

- (NSArray *)valuesForLineAtIndex:(NSInteger)index {
    return [_lineGraphData objectAtIndex:index];
}

- (NSString *)titleForLineAtIndex:(NSInteger)index {
    return  [_lineBottomLabels objectAtIndex:index];
}


#pragma mark - GKBarGraphDataSource

- (NSInteger)numberOfBars {
    return [_barGraphData count];
}

- (NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return [_barGraphData objectAtIndex:index];
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
