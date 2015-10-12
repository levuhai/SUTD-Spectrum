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
#import "PNChart.h"


@interface GameStatsViewController ()
{
    
    NSArray* _gameStatData;
    NSMutableArray* _lineBottomLabels;
    NSMutableArray* _barBottomLabels;
    
    PNLineChart * _lineChart;
    PNBarChart  * _barChart;
    
    IBOutlet UIButton* _playedTimeButton;
    IBOutlet UIButton* _pointButton;
}

@end

@implementation GameStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(47,139,193);
    
    _gameStatData = [GameStatistics MR_findAllSortedBy:@"statId" ascending:NO];
    // Get played time first
    [self enableButton:_playedTimeButton];
    [self disableButton:_pointButton];
    // First line data
    [self loadDataForPlayedTimeLineChart:_gameStatData];
    // Bar data
    [self loadDataForWordsBarChart:_gameStatData];
   
    // setup chart
    [self drawLineChart];
    _lineGraphContainer.layer.cornerRadius = 10;
    [self drawBarChart];
    _barGraphContainer.layer.cornerRadius = 10;
}

- (void)drawLineChart {
    //For Line Chart
    // Line Chart No.1
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = PNLightBlue;
    data01.itemCount = _lineBottomLabels.count;
    data01.inflexionPointStyle = PNLineChartPointStyleCircle;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [_lineGraphData[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    if (!_lineChart) {
        _lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 100 - 30, _lineGraphContainer.width, _lineGraphContainer.height - 100)];
        _lineChart.xLabelFont = [UIFont fontWithName:@"Helvetica" size:15];
        [_lineChart setXLabels:_lineBottomLabels];
        _lineChart.chartData = @[data01];
        [_lineChart strokeChart];
        [_lineGraphContainer addSubview:_lineChart];
    } else {
        [_lineChart setXLabels:_lineBottomLabels];
        [_lineChart updateChartData:@[data01]];
    }
    
}

- (void)drawBarChart {
    
    if (!_barChart) {
    _barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 90 - 30, _barGraphContainer.width - 100, _barGraphContainer.height - 90)];
    _barChart.yChartLabelWidth = 20;
    _barChart.barBackgroundColor = PNWhite;
    _barChart.labelTextColor = PNBlack;
    _barChart.isShowNumbers = NO;
    _barChart.xLabels = _barBottomLabels;
    _barChart.yValues = _barGraphData;
    
    [_barChart strokeChart];
    [_barGraphContainer addSubview:_barChart];
    } else {
        _barChart.xLabels = _barBottomLabels;
        [_barChart updateChartData:_barGraphData];
    }
}

- (void) loadDataForPlayedTimeLineChart:(NSArray*)gameStatData {
    _lineBottomLabels = nil;
    _lineGraphData = nil;
    
    _lineBottomLabels = [NSMutableArray array];
    _lineGraphData = [NSMutableArray array];
    
    for (GameStatistics* gs in gameStatData) {
        
        [_lineGraphData addObject:@([GameStatistics getPlayedTimeFrom:(NSDictionary*)gs.statistics])];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE"];
        NSString *dateString = [dateFormatter stringFromDate:gs.dateAdded];
        
        [_lineBottomLabels addObject:dateString];
    }
}

- (void) loadDataForPointsLineChart:(NSArray*)gameStatData {
    _lineBottomLabels = nil;
    _lineGraphData = nil;
    
    _lineBottomLabels = [NSMutableArray array];
    _lineGraphData = [NSMutableArray array];
    
    for (GameStatistics* gs in gameStatData) {
        [_lineGraphData addObject:@([GameStatistics getPointsFrom:(NSDictionary*)gs.statistics])];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE"];
        NSString *dateString = [dateFormatter stringFromDate:gs.dateAdded];
        
        [_lineBottomLabels addObject:dateString];
    }
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

}

-(IBAction) playedTimeButton_action {
    [self enableButton:_playedTimeButton];
    [self disableButton:_pointButton];
    // Reload data
    [self loadDataForPlayedTimeLineChart:_gameStatData];
    // Update line chart
    [self drawLineChart];
}

-(IBAction) pointButton_action {
    [self enableButton:_pointButton];
    [self disableButton:_playedTimeButton];
    // Reload data
    [self loadDataForPointsLineChart:_gameStatData];
    // Update line chart
    [self drawLineChart];

}

- (void) enableButton:(UIButton*) button {
    button.backgroundColor = RGB(47,139,193);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void) disableButton:(UIButton*) button {
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:RGB(47,139,193) forState:UIControlStateNormal];
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
